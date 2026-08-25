#!/bin/sh

if [ $# -lt 1 ]; then
    echo "Usage: $0 -p <parameter_file> -f <fst_file> -t <tajimadiff_file> -o <output_directory_path>

This script computes the composite statistic for FST/Tajima D

Required argument:
  -p  Path to the parameter file (e.g., params_base.sh in the GitHub repository).
  -f  Path to FST file.
  -t  Path to Tajima Diff file.
  -o  Output directory path for composite stat files"
    exit 1
fi

# Parse command-line arguments
while getopts p:f:t:o: option; do
    case "${option}" in
        p) PARAMS=${OPTARG};;
		i) FST_FILE=${OPTARG};;
        m) TAJIMA_FILE=${OPTARG};;
        o) STAT_DIR=${OPTARG};;
        *) echo "Invalid option: -${OPTARG}" >&2; exit 1;;
    esac
done

if [ -z "${PARAMS}" ]; then
    echo "Error: No parameter file provided." >&2
    exit 1
fi

# Load parameters
source "${PARAMS}"

printf "\n\n\n\n"
date
echo "Current script: fst_tajima_composite.sh"

if [ -d "${STAT_DIR}" ];
        then
            echo "Output directory ${STAT_DIR} already exists, moving on!"
        else
            echo "Output directory ${STAT_DIR} does not exist, creating..."
            mkdir -p "${STAT_DIR}"
fi


# Prep Files
#=========================================

# Temporary sorted files
FST_SORTED="${STAT_DIR}/fst.sorted.tmp"
TAJIMA_SORTED="${STAT_DIR}/tajima.sorted.tmp"

# Prepare FST: extract chr and midPos and fst
awk 'NR > 1 {print $2, $3, $5}' "$FST" | sort -k1,1 -k2,2n > "$FST_SORTED"

# Prepare TAJIMA: chromo, position, Tajima
awk 'NR > 1 {print $1, $2, $3}' "$TAJIMA" | sort -k1,1 -k2,2n > "$TAJIMA_SORTED"

awk '
FILENAME == ARGV[1] {
    key = $1 FS $2
    fst[key] = $3
    keys[key] = 1
    next
}
FILENAME == ARGV[2] {
    key = $1 FS $2
    tajima[key] = $3
    keys[key] = 1
    next
}
END {
    print "chromo\tposition\tfst\ttajima"
    PROCINFO["sorted_in"] = "@ind_str_asc"
    for (k in keys) {
        split(k, a, FS)
        print a[1], a[2], (k in fst ? fst[k] : "NA"), (k in tajima ? tajima[k] : "NA")
    }
}
'  "$FST_SORTED" "$TAJIMA_SORTED" | sort -k1,1 -k2,2n | tr ' ' '\t' > ${STAT_DIR}/combined_stats.tsv

# Clean up
rm "$FST_SORTED" "$TAJIMA_SORTED" 
wc -l ${STAT_DIR}/combined_stats.tsv
grep -v 'NA' ${STAT_DIR}/combined_stats.tsv | wc -l
sed -i '2d' ${STAT_DIR}/combined_stats.tsv # Remove weird extra header


# Combine FST and Tajima
#=========================================
Rscript "${SCRIPTDIR}/Genomics-Main/general_scripts/generate_composite_stat.r" "${STAT_DIR}/combined_stats.tsv"

# Manhattan Plotting
#=========================================
echo -e 'chromo\tchrom_std\tposition\tcomposite_score\thighest_composite' > ${STAT_DIR}/composite_score.additive.with_chrnum.tsv
awk -F'\t' 'BEGIN {
    FS=OFS="\t"
    while ((getline < "'$CHR_FILE'") > 0) {
        split($0, a, ",")
        map[a[2]] = a[1]
    }
}
NR==1 {
    print "chromo", $0
    next
}
{
    print map[$1], $0
}' "${STAT_DIR}/composite_score.additive.tsv" | tail -n +2 | awk '{print $1, $2, $3, $9, $10}' | tr ' ' '\t'  >> ${STAT_DIR}/composite_score.additive.with_chrnum.tsv

Rscript "${SCRIPTDIR}/Genomics-Main/general_scripts/plot_composite_stat.r" \
    "${STAT_DIR}/composite_score.additive.with_chrnum.tsv" "#4EAFAF" "#082B64" "0.001"


# Window Filtering and Gene List
#=========================================
# top 0.1 %
awk 'BEGIN { FS=OFS="\t" }
NR==1 { print "chromo", "position"; next }
$10 == "TRUE" { print $1, $2-25000, $2+25000 }' ${STAT_DIR}/composite_score.additive.tsv | tail -n +2 > ${STAT_DIR}/composite_score.additive.0.1perc.bed

BEDFILE="${STAT_DIR}/composite_score.additive.0.1perc.bed"
GENEFILE="${STAT_DIR}/composite_score.additive.0.1perc.genelist.txt"
GENENAMES="${STAT_DIR}/composite_score.additive.0.1perc.genenames.txt"
GENEMAPS="${STAT_DIR}/composite_score.additive.0.1perc.genecoords.txt"

bedtools intersect -a ${GFF} -b ${BEDFILE} -wa > ${GENEFILE}
grep 'ID\=gene' ${GENEFILE} | awk '{OFS = "\t"} {split($9, arr, ";"); print(arr[1])}' | sed 's/ID\=gene\-//g' | sort -u > ${GENENAMES}

grep 'ID\=gene' ${GENEFILE} | awk '{OFS = "\t"} {split($9, arr, ";"); print($1, $4, $5, arr[1])}' | sed 's/ID\=gene\-//g' | sort -uk4 > ${GENEMAPS}

# top 1%
awk 'BEGIN { FS=OFS="\t" }
NR==1 { print "chromo", "position"; next } { print $1, $2-25000, $2+25000 }' cra.composite_score.additive.1perc.tsv | tail -n +2 > cra.composite_score.additive.1perc.bed

BEDFILE="${STAT_DIR}/composite_score.additive.1perc.bed"
GENEFILE="${STAT_DIR}/composite_score.additive.1perc.genelist.txt"
GENENAMES="${STAT_DIR}/composite_score.additive.1perc.genenames.txt"
GENEMAPS="${STAT_DIR}/composite_score.additive.1perc.genecoords.txt"

bedtools intersect -a ${GFF} -b ${BEDFILE} -wa > ${GENEFILE}
grep 'ID\=gene' ${GENEFILE} | awk '{OFS = "\t"} {split($9, arr, ";"); print(arr[1])}' | sed 's/ID\=gene\-//g' | sort -u > ${GENENAMES}

grep 'ID\=gene' ${GENEFILE} | awk '{OFS = "\t"} {split($9, arr, ";"); print($1, $4, $5, arr[1])}' | sed 's/ID\=gene\-//g' | sort -uk4 > ${GENEMAPS}


