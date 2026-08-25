#!/bin/bash

# An outline of how to generate some required files containing average statistics for depth and mapability

source params_base.sh


# Generate Depthstats Averages
RAW_DEPTH=${OUTDIR}/datafiles/bamstats/chrom_depthstats.txt
AVG_DEPTH=${OUTDIR}/datafiles/bamstats/chrom_avg_depthstats.txt

if [ -f "${RAW_DEPTH}" ]
    then 
        echo "Raw Depth file found, proceeding..."
    else
        echo "Raw Depth file not found, generating..."
        BAMLIST=${OUTDIR}/referencelists/alljays.bamlist.txt
        samtools depth -f ${BAMLIST} >> ${RAW_DEPTH}
fi


if [ -f "${AVG_DEPTH}" ]
    then 
        echo "Avg Depth file found, proceeding..."
    else
        echo "Avg Depth file not found, generating from ${RAW_DEPTH}..."
        awk 'NR==1 {next} { 
        sum = 0; 
        for (i = 3; i <= NF; i++) sum += $i; 
        avg = sum / (NF - 2); 
        print $1, $2, avg;
        }' ${RAW_DEPTH}  > ${AVG_DEPTH}
fi 

# Generate Mapability Averages
FASTA_MASK="${OUTDIR}/datafiles/snpable/${REF_ACC}_revised_mask.150.50.fa"
OUT_MASK="${OUTDIR}/datafiles/bamstats/chrom_site_mapstats.txt"

if [ -f "${OUT_MASK}" ]
    then 
        echo "Mask file found, proceeding..."
    else
        echo "Mask file not found, generating from ${FASTA_MASK}..."
        awk '
        /^>/ {
            chrom = $1
            sub(/^>/, "", chrom)
            pos = 0
            next
        }
        {
            for (i = 1; i <= length($0); i++) {
            pos++
            base = substr($0, i, 1)
            print chrom, pos, (base == "3" ? 1 : 0)
            }
        }
        ' ${FASTA_MASK} > ${OUT_MASK}

        # compute average mapability just for autosomes
        grep "${CHRLEAD}" "${OUT_MASK}"| grep -v "${MTCODE}" > "${OUT_MASK}.autosomes"
fi 


# Set some key variables
POP1=alljays_pre
POP2=alljays_post
POPS=${POP1}_${POP2}
WIN=50000


# Making BED files for computing stat averages over windows

# First using some python to generate windowed FST file containing just autosomes (With chromosomes labeled by ID, not number)
AUTOSOME_LIST=${OUTDIR}/referencelists/SCAFFOLDS.txt
FST_FILE=${OUTDIR}/analyses/fst/${POPS}/${WIN}/${POPS}.${WIN}.fst.chrom
python3 - "$AUTOSOME_LIST" "$FST_FILE" << 'EOF'
import pandas as pd
import os, sys

autosomes = sys.argv[1]
fst_file = sys.argv[2]

with open(autosomes, 'r') as f:
    autosomes = [s.strip() for s in f.readlines()]

fst_df = pd.read_csv(fst_file, sep='\t', header=None)
fst_autosomes = fst_df[fst_df[1].isin(autosomes)]

outdir = os.path.split(fst_file)[0]
outprefix = os.path.split(fst_file)[1]

fst_autosomes.to_csv(os.path.join(outdir, f'{outprefix}.autosomes'), sep='\t', index=None, header=None)
EOF
# Make a file containing windows for FST
awk 'BEGIN {OFS="\t"} {print $2, ($3-25000), $3+2500}' ${OUTDIR}/analyses/fst/${POPS}/${WIN}/${POPS}.${WIN}.fst.chrom.autosomes > ${OUTDIR}/datafiles/bamstats/windowed_bamfiles/${WIN}win.fst.bam



# Now use one of your populations to make a file containing windows from both your pre/post populations for Tajima/Theta
awk 'BEGIN { OFS="\t" } NR>1 {print $2, ($3-25000), ($3+25000)}' ${OUTDIR}/analyses/thetas/${POP1}/${WIN}/${POP1}.theta.thetasWindow.pestPG > "${OUTDIR}/datafiles/bamstats/windowed_bamfiles/${WIN}win.thetas.bam.numchrom"
awk -v chr_file="$CHR_FILE" '
BEGIN {
    FS = OFS = "\t"
    while ((getline < chr_file) > 0) {
        split($0, a, ",")
        map[a[1]] = a[2]
    }
}
{
    if ($1 in map) $1 = map[$1]
    print
}
' "${OUTDIR}/datafiles/bamstats/windowed_bamfiles/${WIN}win.thetas.bam.numchrom" | grep "NC_" | grep -v ${MTCODE} > "${OUTDIR}/datafiles/bamstats/windowed_bamfiles/${WIN}win.thetas.bam" 


# You can now run statavg_over_bedwindows.sh for both depth and mapability. You should do so in slurm jobs
DEPTH_FILE="${OUTDIR}/datafiles/bamstats/chrom_avg_depthstats.txt"

WIN_FST_FILE="${OUTDIR}/datafiles/bamstats/windowed_bamfiles/${WIN}win.fst.bam"
WIN_THETA_FILE="${OUTDIR}/datafiles/bamstats/windowed_bamfiles/${WIN}win.thetas.bam"

AVGDEPTH_FST="${OUTDIR}/datafiles/bamstats/avgdepth_windowed/${WIN}win.fst.depth.csv"
AVGDEPTH_THETA="${OUTDIR}/datafiles/bamstats/avgdepth_windowed/${WIN}win.thetas.depth.csv"

AVGMAP_FST="${OUTDIR}/datafiles/bamstats/avgmap_windowed/${WIN}win.fst.map.csv"
AVGMAP_THETA="${OUTDIR}/datafiles/bamstats/avgmap_windowed/${WIN}win.thetas.map.csv"

chmod +x ${SCRIPTDIR}/Genomics-Main/general_scripts/statavg_over_bedwindows.sh

# Run for FST example
${SCRIPTDIR}/Genomics-Main/general_scripts/statavg_over_bedwindows.sh -d "${DEPTH_FILE}" -w "${WIN_FST_FILE}" -a "${AVGDEPTH_FST}" -t 94 -p params_base.sh
${SCRIPTDIR}/Genomics-Main/general_scripts/statavg_over_bedwindows.sh -d "${DEPTH_FILE}" -w "${WIN_FST_FILE}" -a "${AVGMAP_FST}" -t 94 -p params_base.sh
# Run for Tajima example
${SCRIPTDIR}/Genomics-Main/general_scripts/statavg_over_bedwindows.sh -d "${DEPTH_FILE}" -w "${WIN_THETA_FILE}" -a "${AVGDEPTH_THETA}" -t 94 -p params_base.sh
${SCRIPTDIR}/Genomics-Main/general_scripts/statavg_over_bedwindows.sh -d "${DEPTH_FILE}" -w "${WIN_THETA_FILE}" -a "${AVGMAP_THETA}" -t 94 -p params_base.sh
