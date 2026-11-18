# Get Gene List containing all selection-statistics across ALL mapped genes
# Can be run interactively
#=========================================
source ../../params_base.sh

OUTNAME=alljays_pre_alljays_post_nomaf
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

# Merge buffered genecoords and stats
bedtools intersect -wa -wb -b ${STATS}.intervals -a ${BUFFERED_GENEMAPS} > ${STAT_DIR}/${OUTNAME}.stats_genecoords.bed
sort -k1,1 -k2,2n ${STAT_DIR}/${OUTNAME}.stats_genecoords.bed > ${STAT_DIR}/${OUTNAME}.stats_genecoords.sorted.bed

# remove some columns and make headered version
awk 'BEGIN { OFS="\t" } { print $1, $2, $3, $4, $6, $7, $8, $9, $10 }' ${STAT_DIR}/${OUTNAME}.stats_genecoords.sorted.bed > ${STAT_DIR}/${OUTNAME}.stats_genecoords.cleaned.bed
(echo -e "chrom\tgene_start\tgene_end\tgene_name\twin_start\twin_end\twin_fst\twin_tajima_diff\twin_comp_score" && cat "${STAT_DIR}/${OUTNAME}.stats_genecoords.cleaned.bed") > ${STAT_DIR}/${OUTNAME}.stats_genecoords.headered.bed
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
avg_df = stat_df.groupby('gene_name', as_index=False)[['win_fst', 'win_tajima_diff', 'win_comp_score']].mean()

# Merge and cleanup dataframe
merged_df = avg_df.merge(genemap_df, on='gene_name')
merged_df = merged_df[['chrom', 'gene_start', 'gene_end', 'gene_name', 'win_fst', 'win_tajima_diff', 'win_comp_score']]
merged_df.rename(columns={'win_fst':'avg_fst', 'win_tajima_diff':'avg_tajima_diff', 'win_comp_score':'avg_comp_score'}, inplace=True)

# Output
outdir, fname = os.path.split(stat_file)
outname = fname.split('.')[0]
merged_df.to_csv(os.path.join(outdir, f'{outname}.avg_gene_stats.bed'), sep='\t', index=None) # Keeping header
EOF
sort -k1,1 -k2,2n ${STAT_DIR}/${OUTNAME}.avg_gene_stats.bed > ${STAT_DIR}/${OUTNAME}.avg_gene_stats.sorted.bed


# Add Haplotype Selection Stats to Master File

# Selection Stat Candidate Marker Files
PRE_IHS=${OUTDIR}/analyses/rehh/pre_ihs_allsites.tsv
POST_IHS=${OUTDIR}/analyses/rehh/post_ihs_allsites.tsv
RSB=${OUTDIR}/analyses/rehh/pre_post_rsb_allsites.tsv
XPEHH=${OUTDIR}/analyses/rehh/pre_post_xpehh_allsites.tsv

# Convert haplo-stat files from position to small intervals for intersect
awk 'BEGIN { OFS="\t" } NR > 1 { print $1, $2-1, $2, $3, $4 }' ${PRE_IHS} > ${PRE_IHS}.intervals
awk 'BEGIN { OFS="\t" } NR > 1 { print $1, $2-1, $2, $3, $4 }' ${POST_IHS} > ${POST_IHS}.intervals
awk 'BEGIN { OFS="\t" } NR > 1 { print $1, $2-1, $2, $3, $4 }' ${RSB} > ${RSB}.intervals
awk 'BEGIN { OFS="\t" } NR > 1 { print $1, $2-1, $2, $3, $4 }' ${XPEHH} > ${XPEHH}.intervals

tail -n +2 ${STAT_DIR}/${OUTNAME}.avg_gene_stats.sorted.bed > ${STAT_DIR}/${OUTNAME}.avg_gene_stats.sorted.bed.noheader
# Intersect each stat file with MASTER and get average stat value per gene (grouby)
bedtools intersect -wa -wb -b ${PRE_IHS}.intervals -a ${STAT_DIR}/${OUTNAME}.avg_gene_stats.sorted.bed.noheader > ${PRE_IHS}.intersect.tmp
bedtools intersect -wa -wb -b ${POST_IHS}.intervals -a ${STAT_DIR}/${OUTNAME}.avg_gene_stats.sorted.bed.noheader > ${POST_IHS}.intersect.tmp
bedtools intersect -wa -wb -b ${RSB}.intervals -a ${STAT_DIR}/${OUTNAME}.avg_gene_stats.sorted.bed.noheader > ${RSB}.intersect.tmp
bedtools intersect -wa -wb -b ${XPEHH}.intervals -a ${STAT_DIR}/${OUTNAME}.avg_gene_stats.sorted.bed.noheader > ${XPEHH}.intersect.tmp

# Obtain chrom-averaged tables for haplotype stats
python3 - "${PRE_IHS}.intersect.tmp" "${POST_IHS}.intersect.tmp" "${RSB}.intersect.tmp" "${XPEHH}.intersect.tmp" "${STAT_DIR}/${OUTNAME}.avg_gene_stats.sorted.bed" "${STAT_DIR}/${OUTNAME}.avg_gene_stats.sorted.hhstats.bed" << 'EOF'
import pandas as pd
import os, sys

pre_ihs = sys.argv[1]
post_ihs = sys.argv[2]
rsb = sys.argv[3]
xpehh = sys.argv[4]
prelim_master = sys.argv[5]
output_master = sys.argv[6]

# Load data
print('loading data')
pre_ihs_df = pd.read_csv(pre_ihs, sep='\t', header=None)
post_ihs_df = pd.read_csv(post_ihs, sep='\t', header=None)
rsb_df = pd.read_csv(rsb, sep='\t', header=None)
xpehh_df = pd.read_csv(xpehh, sep='\t', header=None)
prelim_master_df = pd.read_csv(prelim_master, sep='\t')

# Grouby gene name and get avg stats
print('calculating chromosome-level averaged stats')
avg_pre_ihs_df = pre_ihs_df.groupby(pre_ihs_df.columns[3], as_index=False)[[pre_ihs_df.columns[10], pre_ihs_df.columns[11]]].mean()
avg_post_ihs_df = post_ihs_df.groupby(post_ihs_df.columns[3], as_index=False)[[post_ihs_df.columns[10], post_ihs_df.columns[11]]].mean()
avg_rsb_df = rsb_df.groupby(rsb_df.columns[3], as_index=False)[[rsb_df.columns[10], rsb_df.columns[11]]].mean()
avg_xpehh_df = xpehh_df.groupby(xpehh_df.columns[3], as_index=False)[[xpehh_df.columns[10], xpehh_df.columns[11]]].mean()

# Name columns
print('finishing')
avg_pre_ihs_df.columns = ['gene_name', 'avg_pre_ihs', 'avg_pre_ihs_logpval']
avg_post_ihs_df.columns = ['gene_name', 'avg_post_ihs', 'avg_post_ihs_logpval']
avg_rsb_df.columns = ['gene_name', 'avg_rsb', 'avg_rsb_logpval']
avg_xpehh_df.columns = ['gene_name', 'avg_xpehh', 'avg_xpehh_logpval']

merged_df = prelim_master_df.merge(avg_pre_ihs_df, on='gene_name').merge(avg_post_ihs_df, on='gene_name').merge(avg_rsb_df, on='gene_name').merge(avg_xpehh_df, on='gene_name')

# Output
merged_df.to_csv(output_master, sep='\t', index=None)

print('done')
EOF

rm "${PRE_IHS}.intersect.tmp" "${POST_IHS}.intersect.tmp" "${RSB}.intersect.tmp" "${XPEHH}.intersect.tmp" "${STAT_DIR}/${OUTNAME}.avg_gene_stats.sorted.bed.noheader"



FINAL_MASTER="${OUTDIR}/analyses/${OUTNAME}_master_genelist.bed"

# Prep VIP Data
#=========================================
DIAMOND_OUT=${OUTDIR}/datafiles/diamond/rec_best_hits.tsv
WNV_ENSEMBL=${OUTDIR}/referencelists/vip_genelists/wnv_vip_list.txt # output of clean_wnv_vip_lst.py
WNV_HUMAN_JAY_HOMOLOGS=${OUTDIR}/referencelists/vip_genelists/wnv_human_to_jay_homolog.map
WNV_SYMBOL_REFSEQS="${OUTDIR}/referencelists/vip_genelists/${OUTNAME}.wnv.generefseqs.txt"

# First get Reciprocal Best Hits for human refgenome in slurm job
# sbatch ${SCRIPTDIR}/helper_scipts/diamond.sh
# Pause until diamond is done

# Convert hit-ids to refseq accession ids and filter by WNV VIPs
Rscript ${SCRIPTDIR}/helper_scripts/gene_analyses/map_wnv_refseqs.r ${WNV_ENSEMBL} ${DIAMOND_OUT} ${OUTDIR}/referencelists/vip_genelists

# Grab mapped scrub jay refseqs
WNV_JAY_REFSEQS=$(awk 'NR > 1 { print $3 }' $WNV_HUMAN_JAY_HOMOLOGS)

# Map the scrub jay refseq protein ids to their associated genes
for refseq in echo ${WNV_JAY_REFSEQS}; do     
    symbol=$(grep -w "${refseq//\"}" ${GENEFILE} | awk '{split($0, arr, ";"); print arr[6] }' | awk '!seen[$0]++' | sed 's/^gene=//')
    if [[ -n "$symbol" ]]; then
    echo $symbol,"${refseq//\"}" >> $WNV_SYMBOL_REFSEQS
    fi  
done
# Remove some parsing errors
sed -i '/exception=unclassified translation discrepancy/d' $WNV_SYMBOL_REFSEQS
sed -i '/gbkey=CDS/d' $WNV_SYMBOL_REFSEQS

# Outlier genelists
PERC01=${STAT_DIR}/${OUTNAME}.composite_score.additive.0.1perc.genenames.txt
PERC1=${STAT_DIR}/${OUTNAME}.composite_score.additive.1perc.genenames.txt

# Add binary VIP and CS Outlier Data and human homolog genes
python3 - "${STAT_DIR}/${OUTNAME}.avg_gene_stats.sorted.hhstats.bed" "${WNV_SYMBOL_REFSEQS}" "${WNV_HUMAN_JAY_HOMOLOGS}" "${PERC01}" "${PERC1}" "${FINAL_MASTER}" << 'EOF'
import pandas as pd
import os, sys

# Load data
stat_file = sys.argv[1]
wnv_symbol2refseqs = sys.argv[2]
wnv_homologs = sys.argv[3]
top_01 = sys.argv[4]
top_1 = sys.argv[5]
final_master = sys.argv[6]

stat_df=pd.read_csv(stat_file, sep='\t')
wnv_sym2refseqs_df=pd.read_csv(wnv_symbol2refseqs, header=None)
wnv_sym2refseqs_df.columns = ['scrubjays_SYMBOL', 'scrubjays_REFSEQ']
top_01_df=pd.read_csv(top_01, sep='\t', header=None)
top_1_df=pd.read_csv(top_1, sep='\t', header=None)
wnv_homologs_df = pd.read_csv(wnv_homologs, sep='\t')

# Merge VIP mapping data
merged_mapping_df = pd.merge(wnv_homologs_df, wnv_sym2refseqs_df, on='scrubjays_REFSEQ')
merged_mapping_df = merged_mapping_df.drop_duplicates(subset=['scrubjays_SYMBOL'])
merged_mapping_df.set_index('scrubjays_SYMBOL', inplace=True)

# Add binary WNV-VIP columns
binary_col = []
symbol_col = []
for row in stat_df.index:
    if stat_df.loc[row, 'gene_name'] in list(merged_mapping_df.index):
        binary_col.append(1)
        symbol_col.append(merged_mapping_df.loc[stat_df.loc[row, 'gene_name'], 'human_SYMBOL'])
    else:
        binary_col.append(0)
        symbol_col.append(None)
stat_df['has_wnv_vip'] = binary_col
stat_df['wnv_homolog'] = symbol_col

# Add CS Outlier columns
stat_df['top_0.1_cs'] = stat_df['gene_name'].isin(top_01_df[0]).astype(int)
stat_df['top_1_cs'] = stat_df['gene_name'].isin(top_1_df[0]).astype(int)

# Output
stat_df.to_csv(final_master, sep='\t', index=None) # Keeping header
EOF