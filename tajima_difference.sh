# Get Tajima's D Difference between populations

TAJIMADIR=/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/analyses/tajima
POP1=ccgp_jays_pre
POP2=ccgp_jays_post
WIN=500000
OUTPREFIX=ccgp_diff

(echo -e "chromo\tposition\tTajima"; awk 'BEGIN {OFS="\t"} NR==FNR && FNR>1 {data[$2,$3] = $9; next} FNR>1 && ($2,$3) in data {print $2, $3, $9 - data[$2,$3]}' ${TAJIMADIR}/${POP1}/${POP1}.Tajima.${WIN}.Ztransformed.csv ${TAJIMADIR}/${POP2}/${POP2}.Tajima.${WIN}.Ztransformed.csv) \
| grep -v 'NW' | grep -v 'Z' >> ${TAJIMADIR}/${OUTPREFIX}.txt