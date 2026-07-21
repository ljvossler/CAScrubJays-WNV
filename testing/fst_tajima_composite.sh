source params_base.sh

OUTPREFIX=ccgp_jays

FST="${OUTDIR}/analyses/fst/ccgp_jays_pre_ccgp_jays_post/500000/ccgp_jays_pre_ccgp_jays_post.500000.fst.chrom.txt" # This should be the fst file within numerical chromosome labels (matching tajima output)
TAJIMA="${OUTDIR}/analyses/tajima/ccgp_diff.txt"


# Temporary sorted files
FST_SORTED="${OUTDIR}/analyses/fst/fst.sorted.tmp"
TAJIMA_SORTED="${OUTDIR}/analyses/tajima/tajima.sorted.tmp"

# Prepare FST: extract chr and midPos and fst
awk 'NR > 1 {print $2, $3, $5}' "$FST" | sort -k1,1 -k2,2n > "$FST_SORTED"

# Prepare TAJIMA: chromo, position, Tajima
awk 'NR > 1 {print $1, $2, $3}' "$TAJIMA" | sort -k1,1 -k2,2n > "$TAJIMA_SORTED"


# try a different approach
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
'  ${FST_SORTED} ${TAJIMA_SORTED} | sort -k1,1 -k2,2n | tr ' ' '\t' > combined_stats.tsv


# Clean up
#rm "$FST_SORTED" "$TAJIMA_SORTED" 

wc -l combined_stats.tsv
grep -v 'NA' combined_stats.tsv | wc -l


<<'EOF'
echo "Generating composite stat from ${OUTDIR}/analyses/fst_tajima_combined_stats.tsv..."
Rscript "generate_composite_stat.r" \
    "${OUTDIR}" "${OUTDIR}/analyses/fst_tajima_combined_stats.tsv" "${OUTPREFIX}"

echo -e 'chromo\tchrom_std\tposition\tcomposite_score\thighest_composite' > ${OUTDIR}/analyses/${OUTPREFIX}.composite_score.additive.with_chrnum.tsv

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
}' "${OUTDIR}/analyses/${OUTPREFIX}.composite_score.additive.tsv" | tail -n +2 | awk '{print $1, $2, $3, $10, $11}' | tr ' ' '\t'  >> ${OUTDIR}/analyses/${OUTPREFIX}.composite_score.additive.with_chrnum.tsv



source ~/programs/DarwinFinches/param_files/cra_params_fst.sh


echo "Plotting composite stat..."
Rscript "plot_composite_stat.r" \
    "${OUTDIR}" "${OUTDIR}/analyses/fst_tajima_combined_stats.tsv" "${OUTPREFIX}"

cat("Script completed successfully!\n")
EOF
