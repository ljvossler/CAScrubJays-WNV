#!/bin/bash

# An outline of how to filter FST and Tajima outputs by depth and mapability. To be referenced after generate_avg_depthstats.sh.

POP1=alljays_pre
POP2=alljays_post
WIN=50000

species=( "alljays" )
pops=( "${POP1}" "${POP2}" )

source params_base.sh

# Some functions
filter_outputs() {
    local outputfile="$1"
    local inputfile="$2"

    grep "${CHRLEAD}" ${inputfile} | grep -v "${MTCODE}" > "${inputfile}.autosomes"
    Rscript ${SCRIPTDIR}/Genomics-Main/general_scripts/filter_statavg_output.r "${inputfile}.autosomes" "${outputfile}.unsorted"
    sort -k1,1 -k2,2n "${outputfile}.unsorted" > "${outputfile}"
    rm "${outputfile}.unsorted"
}

# Filter windowed bams by depth
#=================================================================
# FST
#========
AVGDEPTH_FST="${OUTDIR}/datafiles/bamstats/avgdepth_windowed/${WIN}win.fst.depth.csv"
OUTPUT_DEPTH_FST="${OUTDIR}/datafiles/bamstats/windowed_bamfiles/${WIN}win.fst.depth.filtered.bam"

filter_outputs "${OUTPUT_DEPTH_FST}" "${AVGDEPTH_FST}" 

# Filter FST files
BAMFILE="${OUTPUT_DEPTH_FST}"
awk '{print $1, ($2+25000)}' "${BAMFILE}" > "${BAMFILE}.midpos"

for sp in "${species[@]}"; do
    FSTFILE="${OUTDIR}/analyses/fst/${sp}_pre_${sp}_post/${WIN}/${sp}_pre_${sp}_post.${WIN}.fst"
    OUTFILE="${OUTDIR}/analyses/fst/${sp}_pre_${sp}_post/${WIN}/${sp}_pre_${sp}_post.${WIN}.fst.depthfiltered"
    grep "${CHRLEAD}" ${FSTFILE} | grep -v "${MTCODE}" > "${FSTFILE}.autosomes"

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
    ' "$BAMFILE.midpos" "$FSTFILE" > "$OUTFILE"
done


# Tajima
#========
AVGDEPTH_THETA="${OUTDIR}/datafiles/bamstats/avgdepth_windowed/${WIN}win.thetas.depth.csv"
OUTPUT_DEPTH_THETA="${OUTDIR}/datafiles/bamstats/windowed_bamfiles/${WIN}win.thetas.depth.filtered.bam"
BAMFILE="${OUTDIR}/datafiles/bamstats/avgdepth_windowed/${WIN}win.thetas.depth.filtered.bam.midpos"

filter_outputs "${OUTPUT_DEPTH_THETA}" "${AVGDEPTH_THETA}" 

awk '{print $1, ($2+25000)}' "${OUTPUT_DEPTH_THETA}" > "${BAMFILE}"

# Filter thetas file
for pop in "${pops[@]}"; do
  
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

    grep "${CHRLEAD}" ${THETAFILE}.txtchrom | grep -v "${MTCODE}" > "${THETAFILE}.autosomes"

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
done
#=================================================================





# Filter windowed bams by mapability
#=================================================================
# FST
#========
AVGMAP_FST="${OUTDIR}/datafiles/bamstats/avgmap_windowed/${WIN}win.fst.map.csv"
OUTPUT_MAP_FST="${OUTDIR}/datafiles/bamstats/windowed_bamfiles/${WIN}win.fst.map.filtered.bam"

filter_outputs "${OUTPUT_MAP_FST}" "${AVGMAP_FST}"

# Filter FST files
BAMFILE="${OUTPUT_MAP_FST}"
awk '{print $1, ($2+25000)}' "${BAMFILE}" > "${BAMFILE}.midpos"

for sp in "${species[@]}"; do
    FSTFILE="${OUTDIR}/analyses/fst/${sp}_pre_${sp}_post/${WIN}/${sp}_pre_${sp}_post.${WIN}.fst.depthfiltered"
    OUTFILE="${OUTDIR}/analyses/fst/${sp}_pre_${sp}_post/${WIN}/${sp}_pre_${sp}_post.${WIN}.fst.depthmapfiltered"
    grep "${CHRLEAD}" ${FSTFILE} | grep -v "${MTCODE}" > "${FSTFILE}.autosomes"

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
    ' "$BAMFILE.midpos" "$FSTFILE" > "$OUTFILE"
    
done


# Tajima
#========
AVGMAP_THETA="${OUTDIR}/datafiles/bamstats/avgmap_windowed/${WIN}win.thetas.map.csv"
OUTPUT_MAP_THETA="${OUTDIR}/datafiles/bamstats/windowed_bamfiles/${WIN}win.thetas.map.filtered.bam"
BAMFILE="${OUTDIR}/datafiles/bamstats/avgmap_windowed/${WIN}win.thetas.map.filtered.bam.midpos"

filter_outputs "${OUTPUT_MAP_THETA}" "${AVGMAP_THETA}"

awk '{print $1, ($2+25000)}' "${OUTPUT_MAP_THETA}" > "${BAMFILE}"


# Filter thetas file

for pop in "${pops[@]}"; do
    THETAFILE="${OUTDIR}/analyses/thetas/${pop}/${WIN}/${pop}.theta.thetasWindow.pestPG.depthfiltered"

    OUTFILE="${OUTDIR}/analyses/thetas/${pop}/${WIN}/${pop}.theta.thetasWindow.pestPG.depthmapfiltered"

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
    ' "$BAMFILE" "$THETAFILE" > "$OUTFILE"

done



# Manhattan Plotting
#==========================

# FST
for sp in "${species[@]}"; do 
    input="${OUTDIR}/analyses/fst/${sp}_pre_${sp}_post/${WIN}/${sp}_pre_${sp}_post.${WIN}.fst.depthmapfiltered"
    echo -e "region\tchromo\tposition\tNsites\tfst" | cat - ${input} > ${input}.headered
    source ${SCRIPTDIR}/Genomics-Main/C_SelectionAnalysis/fst/fst.filteredfiles.sh -p params_fst.sh -f ${input}.headered
done


# Tajima
CUTOFF=0.01
COLOR1="#4EAFAF"
COLOR2="#FF817E"
preinput="${OUTDIR}/analyses/thetas/${POP1}/${WIN}/${POP1}.theta.thetasWindow.pestPG.depthmapfiltered"
postinput="${OUTDIR}/analyses/thetas/${POP2}/${WIN}/${POP2}.theta.thetasWindow.pestPG.depthmapfiltered"
filtered_diff_file="${OUTDIR}/analyses/tajima/${species[0]}_tajimadiff.depthmapfiltered.txt"
(echo -e "chromo\tposition\tTajima"; awk 'BEGIN {OFS="\t"} NR==FNR && FNR>1 {data[$2,$3] = $9; next} FNR>1 && ($2,$3) in data {print $2, $3, $9 - data[$2,$3]}' ${preinput} ${postinput}) >> $filtered_diff_file
cp ${filtered_diff_file} "${filtered_diff_file}.numchrom" 
# Replace chromosome names if conversion file is provided
if [ -n "$CHR_FILE" ]; then
    echo "Replacing chromosome names based on conversion file..."
    while IFS=',' read -r first second; do
        sed -i "s/$second/$first/g" "${filtered_diff_file}.numchrom" 
    done < "$CHR_FILE"
fi
# z transform windowed data
Rscript "${SCRIPTDIR}/Genomics-Main/general_scripts/ztransform_windows.filteredfiles.r" \
"${OUTDIR}" "${CUTOFF}" "${filtered_diff_file}.numchrom" 
Z_OUT="${filtered_diff_file}.numchrom.Ztransformed.csv"
# Run R script for plotting
echo "Generating Manhattan plot from ${Z_OUT}..."
Rscript "${SCRIPTDIR}/Genomics-Main/general_scripts/manhattanplot.filteredfiles.tajimadiff.r" \
    "${OUTDIR}" "${COLOR1}" "${COLOR2}" "${CUTOFF}" "${Z_OUT}" "Tajima" 

echo "Script completed successfully!"


# Violin Plotting
#==========================