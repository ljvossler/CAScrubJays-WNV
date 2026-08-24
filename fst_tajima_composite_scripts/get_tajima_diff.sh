# Get Tajima's D Difference between populations

source ../params_base.sh

TAJIMADIR=${OUTDIR}/analyses/tajima
POP1=alljays_pre
POP2=alljays_post
WIN=50000
OUTPREFIX=alljays_tajimadiff

echo "Calculating differences"
(echo -e "chromo\tposition\tTajima"; awk 'BEGIN {OFS="\t"} NR==FNR && FNR>1 {data[$2,$3] = $9; next} FNR>1 && ($2,$3) in data {print $2, $3, $9 - data[$2,$3]}' ${TAJIMADIR}/${POP1}/${POP1}.Tajima.${WIN}.Ztransformed.csv ${TAJIMADIR}/${POP2}/${POP2}.Tajima.${WIN}.Ztransformed.csv) \
| grep -v "${SCAF_LEAD}" | grep -v "${MTCODE}" >> ${TAJIMADIR}/${OUTPREFIX}.txt

# Replace num_id with chrom_id
echo "Replacing chromosome names based on conversion file..."
while IFS=',' read -r first second; do
    echo "Replacing $first with $second..."
    #sed "s/$first/$second/g" "${TAJIMADIR}/${OUTPREFIX}.txt" >> "${TAJIMADIR}/${OUTPREFIX}.chrom.txt" 
    cat "${TAJIMADIR}/${OUTPREFIX}.txt" | awk -v var1="$first" -v var2="$second" '{ if ($1 == var1) {$1 = var2}; print $1, $2, $3 }' >> "${TAJIMADIR}/${OUTPREFIX}_${second}.chrom.txt"
done < "$CHR_FILE"
cat $(ls ${TAJIMADIR}/*.chrom.txt) > "${TAJIMADIR}/${OUTPREFIX}.chrom.txt"