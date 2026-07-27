#!/bin/bash

# An outline of how to filter FST and Tajima outputs by depth and mapability. To be referenced after generate_avg_depthstats.sh.

species=( "jays" )
pops=( "${POP1}" "${POP2}" )

source params_base.sh

# Some functions
filter_outputs() {
    local outputfile="$1"
    local depthfile="$2"

    grep "${CHR_LEAD}" ${depthfile} | grep -v "${SEXCHR}" > "${depthfile}.autosomes"
    Rscript ${SCRIPTDIR}/Genomics-Main/general_scripts/filter_statavg_output.r "${depthfile}.autosomes" "${outputfile}.unsorted"
    sort -k1,1 -k2,2n "${outputfile}.unsorted" > "${outputfile}"
    rm "${outputfile}.unsorted"
}



# Filter windowed bams by depth and mapability
# FST
OUTPUT_DEPTH_FST="${OUTDIR}/datafiles/bamstats/depthstats/avgdepth_windowed/${WIN}win.fst.depth.filtered.bam"

filter_outputs "${OUTPUT_DEPTH_FST}" "${AVGDEPTH_FST}" 

# Filter FST files
BAMFILE="${OUTPUT_DEPTH_FST}"
awk '{print $1, ($2+25000)}' "${BAMFILE}" > "${BAMFILE}.midpos"

for sp in ${species}; do
    FSTFILE="${OUTDIR}/analyses/fst/${sp}_pre_${sp}_post/${WIN}/${sp}_pre_${sp}_post.${WIN}.fst"
    OUTFILE="${OUTDIR}/analyses/fst/${sp}_pre_${sp}_post/${WIN}/${sp}_pre_${sp}_post.${WIN}.fst.depthfiltered"
    grep "${CHR_LEAD}" ${FSTFILE} | grep -v "${SEXCHR}" > "${FSTFILE}.autosomes"

    awk '
    # Load BAMFILE: store all (chrom, midpoint) pairs
    FNR==NR {
        bam[$1, $2] = 1
        next
    }

    # For each line in FSTFILE, keep only if the (chrom, midpoint) pair is in BAMFILE
    {
        chrom = $2
        midpoint = $3
        if ((chrom, midpoint) in bam) {
            print
        }
    }
    ' "$BAMFILE" "$FSTFILE" > "$OUTFILE"

    # sort -k1,1 -k2,2n "${OUTPUT_FILE}.unsorted" > "${OUTPUT_FILE}"
    # rm "${OUTPUT_FILE}.unsorted"
done


# Filter windowed bams by depth and mapability
# Tajima
OUTPUT_DEPTH_THETA="${OUTDIR}/datafiles/bamstats/depthstats/avgdepth_windowed/${WIN}win.thetas.depth.filtered.bam"
BAMFILE="${OUTDIR}/datafiles/bamstats/depthstats/avgdepth_windowed/${WIN}win.thetas.depth.filtered.bam.midpos"

filter_outputs "${OUTPUT_DEPTH_THETA}" "${AVGDEPTH_THETA}" 

awk '{print $1, ($2+25000)}' "${OUTPUT_DEPTH_THETA}" > "${BAMFILE}"

# Filter thetas file
for pop in $pops; do
  
    OUTFILE="${OUTDIR}/analyses/thetas/${pop}/${WIN}/${pop}.theta.thetasWindow.pestPG.depthfiltered"

    THETAFILE="${OUTDIR}/analyses/thetas/${pop}/${WIN}/${pop}.theta.thetasWindow.pestPG"


    awk -v chr_file="$CHR_FILE" '
    BEGIN {
        FS = OFS = "\t"
        while ((getline < chr_file) > 0) {
            split($0, a, ",")
            map[a[1]] = a[2]
        }
    }
    {
        if ($2 in map) $2 = map[$2]
        print
    }
    ' "${THETAFILE}" | grep 'NC_' > "${THETAFILE}.txtchrom" 

    grep "${CHR_LEAD}" ${THETAFILE}.txtchrom | grep -v "${SEXCHR}" > "${THETAFILE}.autosomes"

    awk '
    # Load BAMFILE: store all (chrom, midpoint) pairs
    FNR==NR {
        bam[$1, $2] = 1
        next
    }

    # For each line in THETAFILE, keep only if the (chrom, midpoint) pair is in BAMFILE
    {
        chrom = $2
        midpoint = $3
        if ((chrom, midpoint) in bam) {
            print
        }
    }
    ' "$BAMFILE" "$THETAFILE.autosomes" > "$OUTFILE"

    # sort -k1,1 -k2,2n "${OUTPUT_FILE}.unsorted" > "${OUTPUT_FILE}"
    # rm "${OUTPUT_FILE}.unsorted"

done