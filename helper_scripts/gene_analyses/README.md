# pipeline overview
1. Run DIAMOND reciprocal best hit protein search (diamondp) to map jay and human refseqs together
2. Go through `build_master_genelist.sh` to calculate all selection stats and such
3. Go through `make_go_background_genelist.sh` to create gene symbol files for GO analysis
4. Run `go_analysis.r` and `gsea.r`