# Get Tajima's D Difference between populations

source params_base.sh

TAJIMADIR=/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/analyses/tajima
POP1=ccgp_jays_pre
POP2=ccgp_jays_post
WIN=500000
OUTPREFIX=ccgp_diff

(echo -e "chromo\tposition\tTajima"; awk 'BEGIN {OFS="\t"} NR==FNR && FNR>1 {data[$2,$3] = $9; next} FNR>1 && ($2,$3) in data {print $2, $3, $9 - data[$2,$3]}' ${TAJIMADIR}/${POP1}/${POP1}.Tajima.${WIN}.Ztransformed.csv ${TAJIMADIR}/${POP2}/${POP2}.Tajima.${WIN}.Ztransformed.csv) \
| grep -v 'NW' | grep -v 'Z' >> ${TAJIMADIR}/${OUTPREFIX}.txt


COLOR1="#4EAFAF"
COLOR2="#FF817E"
# Run R script for plotting
echo "Generating Manhattan plot from ${OUTPREFIX}..."
Rscript "${SCRIPTDIR}/Genomics-Main/general_scripts/manhattanplot.r" \
    "${OUTDIR}" "${COLOR1}" "${COLOR2}" "${CUTOFF}" "${TAJIMADIR}/${OUTPREFIX}.txt" "${WIN}" "Tajima" "${OUTPREFIX}"

echo "Script completed successfully!"