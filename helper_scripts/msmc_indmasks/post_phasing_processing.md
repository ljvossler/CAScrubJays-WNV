## Make merged bcf
```
module load bcftools

cd /xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/rephased_bcf/allsites/bcfs
ls * .bcf > ordered_bcf_list.txt

bcftools concat -f ordered_bcf_list.txt -O b -o allsites_rephased_merged.bcf
bcftools index allsites_rephased_merged.bcf
```