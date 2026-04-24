# Merge chromosome-specific recombination maps into single file (for bealge phasing)

source params_base.sh

pop_prefix=ccgp_jays_subset
rmap_lst=()
for chr in $(cat ${OUTDIR}/referencelists/SCAFFOLDS.txt); do
    echo $chr
    rmap_lst+=("${OUTDIR}/datafiles/linkage_map/${pop_prefix}_${chr}.rmap");
done

echo $rmap_lst

cat $rmap_lst > ${OUTDIR}/datafiles/linkage_map/${pop_prefix}_all.rmap