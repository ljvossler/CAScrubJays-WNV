# Get Gene List across ALL windows
#=========================================
source ../../params_base.sh

OUTNAME=alljays_pre_alljays_post
WIN=50000
STAT_DIR="${OUTDIR}/analyses/composite_stat/${OUTNAME}"

ALL_WINDOWS="${STAT_DIR}/${OUTNAME}.composite_score.additive.tsv"
BEDFILE="${STAT_DIR}/${OUTNAME}.composite_score.additive.all_windows.bed"
GENEFILE="${STAT_DIR}/${OUTNAME}.composite_score.additive.all_windows.genelist.txt"
GENENAMES="${STAT_DIR}/${OUTNAME}.composite_score.additive.all_windows.genenames.txt"
GENEMAPS="${STAT_DIR}/${OUTNAME}.composite_score.additive.all_windows.genecoords.txt"

awk 'BEGIN { FS=OFS="\t" }
NR==1 { print "chromo", "position"; next } { print $1, $2-25000, $2+25000 }' ${ALL_WINDOWS} | tail -n +2 > ${BEDFILE}

bedtools intersect -a ${GFF} -b ${BEDFILE} -wa > ${GENEFILE}
grep 'ID\=gene' ${GENEFILE} | awk '{OFS = "\t"} {split($9, arr, ";"); print(arr[1])}' | sed 's/ID\=gene\-//g' | sort -u > ${GENENAMES}

grep 'ID\=gene' ${GENEFILE} | awk '{OFS = "\t"} {split($9, arr, ";"); print($1, $4, $5, arr[1])}' | sed 's/ID\=gene\-//g' | sort -uk4 > ${GENEMAPS}

# Make buffered genecoordinate file. Attempting to account for regulatory regions. Increase intervals by 1kb each side
BUFFERED_GENEMAPS="${STAT_DIR}/${OUTNAME}.composite_score.additive.all_windows.genecoords.buffered.txt"
awk 'BEGIN { FS=OFS="\t" } { print $1, $2-1000, $3+1000, $4 }' ${GENEMAPS} > ${BUFFERED_GENEMAPS}


# Add FST, Tajima D, and Composite stats
#=========================================
STATS=${STAT_DIR}/${OUTNAME}.composite_stats

# Change to intervals
awk 'BEGIN { FS=OFS="\t" } NR>1 {print $1, $2-25000, $2+25000, $3, $4, $8}' ${ALL_WINDOWS} > ${STATS}.intervals

# Label top windows
PERC01=${STAT_DIR}/${OUTNAME}.composite_score.additive.0.1perc.bed
PERC1=${STAT_DIR}/${OUTNAME}.composite_score.additive.1perc.bed

python3 - "$STATS.intervals" "$PERC01" "$PERC1" << 'EOF'
import pandas as pd
import os, sys

stat_file = sys.argv[1]
top_01 = sys.argv[2]
top_1 = sys.argv[3]
stat_df=pd.read_csv(stat_file, sep='\t', header=None)
top_01_df=pd.read_csv(top_01, sep='\t', header=None)
top_1_df=pd.read_csv(top_1, sep='\t', header=None)

stat_df['top_0.1'] = stat_df[1].isin(top_01_df[1]).astype(int)
stat_df['top_1'] = stat_df[1].isin(top_1_df[1]).astype(int)

stat_df.to_csv(f'{stat_file}.toplabeled', sep='\t', index=None, header=None)
EOF
# Note that last two columns represent top 0.1 and top 1 percent windows respectively (clearing headers)

# Merge buffered genecoords and stats
bedtools intersect -wa -wb -b ${STATS}.intervals.toplabeled -a ${BUFFERED_GENEMAPS} > ${STAT_DIR}/${OUTNAME}.stats_genecoords.bed
sort -k1,1 -k2,2n ${STAT_DIR}/${OUTNAME}.stats_genecoords.bed > ${STAT_DIR}/${OUTNAME}.stats_genecoords.sorted.bed

# remove some columns and make headered version
awk 'BEGIN { OFS="\t" } { print $1, $2, $3, $4, $6, $7, $8, $9, $10, $11, $12 }' ${STAT_DIR}/${OUTNAME}.stats_genecoords.sorted.bed > ${STAT_DIR}/${OUTNAME}.stats_genecoords.cleaned.bed
(echo -e "chrom\tgene_start\tgene_end\tgene_name\twin_start\twin_end\twin_fst\twin_tajima_diff\twin_comp_score\ttop_0.1\ttop_1" && cat "${STAT_DIR}/${OUTNAME}.stats_genecoords.cleaned.bed") > ${STAT_DIR}/${OUTNAME}.stats_genecoords.headered.bed
rm ${STAT_DIR}/${OUTNAME}.stats_genecoords.cleaned.bed


# Obtain Groub-by Stats
#=========================================
python3 - "${STAT_DIR}/${OUTNAME}.stats_genecoords.headered.bed" "${BUFFERED_GENEMAPS}" << 'EOF'
import pandas as pd
import os, sys

# Load data
stat_file = sys.argv[1]
gene_map = sys.argv[2]
stat_df=pd.read_csv(stat_file, sep='\t')
genemap_df=pd.read_csv(gene_map, sep='\t', header=None)
genemap_df.columns = ['chrom', 'gene_start', 'gene_end', 'gene_name']


# Grouby gene name and get avg stats
avg_df = stat_df.groupby('gene_name', as_index=False)[['win_fst', 'win_tajima_diff', 'win_comp_score', 'top_0.1', 'top_1']].mean()

# Merge and cleanup dataframe
merged_df = avg_df.merge(genemap_df, on='gene_name')
merged_df = merged_df[['chrom', 'gene_start', 'gene_end', 'gene_name', 'win_fst', 'win_tajima_diff', 'win_comp_score', 'top_0.1', 'top_1']]
merged_df.rename(columns={'win_fst':'avg_fst', 'win_tajima_diff':'avg_tajima_diff', 'win_comp_score':'avg_comp_score'}, inplace=True)
merged_df['top_0.1'] = (merged_df['top_0.1'] > 0).astype(int)
merged_df['top_1'] = (merged_df['top_1'] > 0).astype(int)

# Output
outdir, fname = os.path.split(stat_file)
outname = fname.split('.')[0]
merged_df.to_csv(os.path.join(outdir, f'{outname}.avg_gene_stats.bed'), sep='\t', index=None) # Keeping header
EOF
sort -k1,1 -k2,2n ${STAT_DIR}/${OUTNAME}.avg_gene_stats.bed > ${STAT_DIR}/${OUTNAME}.avg_gene_stats.sorted.bed


# Add VIP Data
#=========================================
DIAMOND_OUT=${OUTDIR}/datafiles/diamond/rec_best_hits.txt
WNV_ENSEMBL=${OUTDIR}/referencelists/vip_genelists/temp_inter_wnv_may2020
WNV_HUMAN_JAY_REFSEQS=${OUTDIR}/referencelists/vip_genelists/wnv_human_to_scrubjay_refseq_ids.txt
WNV_GENEREFSEQS="${OUTDIR}/referencelists/vip_genelists/${OUTNAME}.wnv.generefseqs.txt"

# First get Reciprocal Best Hits for human refgenome
sbatch ${SCRIPTDIR}/helper_scipts/diamond.sh
# Pause until diamond is done

# Convert hit-ids to refseq accession ids and filter by WNV VIPs
cd ${OUTDIR}/referencelists/vip_genelists
Rscript ${SCRIPTDIR}/helper_scripts/map_refseqs.r ${WNV_ENSEMBL} ${DIAMOND_OUT}


WNV_JAY_REFSEQS=$(awk 'NR > 1 { print $2 }' $WNV_HUMAN_JAY_REFSEQS)

# Map the refseq protein ids to their associated genes
for refseq in echo ${WNV_JAY_REFSEQS}; do     
    symbol=$(grep -w "${refseq//\"}" ${GENEFILE} | awk '{split($0, arr, ";"); print arr[6] }' | awk '!seen[$0]++' | sed 's/^gene=//')
    if [[ -n "$symbol" ]]; then
    echo $symbol,"${refseq//\"}" >> $WNV_GENEREFSEQS
    fi  
done
# Remove some parsing errors
sed -i '/exception=unclassified translation discrepancy/d' ${WNV_GENEREFSEQS}

# Add binary VIP column to master genelist
python3 - "${STAT_DIR}/${OUTNAME}.avg_gene_stats.sorted.bed" "${WNV_GENEREFSEQS}" << 'EOF'
import pandas as pd
import os, sys

# Load data
stat_file = sys.argv[1]
wnv_generefseqs = sys.argv[2]
stat_df=pd.read_csv(stat_file, sep='\t')
wnv_refseqs_df=pd.read_csv(wnv_generefseqs, header=None)
wnv_refseqs_df.columns = ['gene_name', 'refseq_vip']

# Add vip column
stat_df['has_wnv_vip'] = stat_df['gene_name'].isin(wnv_refseqs_df['gene_name']).astype(int)

# Output
stat_df.to_csv("/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/scrubjays_master_genelist.bed", sep='\t', index=None) # Keeping header
EOF
