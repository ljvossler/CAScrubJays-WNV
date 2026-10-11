# CA Scrubjays Genomic Analysis Results
===========================================

Overview of analysis results from analyses. More extended descriptions of pipelines used can be found in PIPELINE.md

===========================================
# GONE Demography

## Intial 2-Binned Pre/Post Analyses:

## Multi-Binned Pre/Post Analyses (Testing for effects of variable sample size):
![Multi-Binned Tests](../output_files/prelim/demography/gone/gone_5bins.png)

## 16-Binned Pre/Post Analyses (5 Samples and 1-6 year timespan per bin):
![16-Binned Tests](../output_files/prelim/demography/gone/gone_binned_big.png)



===========================================
# Selection Analyses

## Manhattan Plots:
*Initial Pre-Post Runs*

Initial Pre-Post FST
![Initial Pre-Post: FST](../output_files/prelim/FST_TD/alljays_pre_alljays_post.50000.fst.depthmapfiltered.headered.numchrom.Ztransformed.csv.sigline.png)
Initial Pre Tajima
![Initial Pre: Tajima](../output_files/prelim/FST_TD/alljays_pre.Tajima.50000.sigline.png)
Initial Post Tajima
![Initial Post: Tajima](../output_files/prelim/FST_TD/alljays_post.Tajima.50000.sigline.png)
Initial Pre-Post Composite Score
![Initial Pre-Post: Composite Score](../output_files/prelim/FST_TD/alljays_pre_alljays_post.composite_score.additive.with_chrnum.tsv.sigline.png)

-----------------------------------------------------------

*Pre-Post2015 Runs*

Pre-Post2015 FST
![Pre-Post2015: FST](../output_files/prelim/FST_TD/alljays_pre_alljays_post2015.50000.fst.depthmapfiltered.headered.numchrom.Ztransformed.csv.sigline.png)
Pre Tajima
![Pre: Tajima](../output_files/prelim/FST_TD/alljays_pre.Tajima.50000.sigline.png)
Post2015 Tajima
![Post2015: Tajima](../output_files/prelim/FST_TD/alljays_post2015.Tajima.50000.sigline.png)
Pre-Post2015 Composite Score
![Pre-Post2015: Composite Score](../output_files/prelim/FST_TD/alljays_pre_alljays_post2015.composite_score.additive.with_chrnum.tsv.sigline.png)



## Top Windows:

*Initial Pre-Post Runs*

`Top 0.1%:` 32 total genes present in overlapping high-CS windows

`Top 1%:` 201 total genes present in overlapping high-CS windows

*Pre-Post2015 Runs*

`Top 0.1%:` 20 total genes present in overlapping high-CS windows

`Top 1%:` 196 total genes present in overlapping high-CS windows



## GO and GSEA:

*Initial Pre-Post Runs*

Top 0.1% enrichGO Analysis at p-value cutoff 0.05 `(11 Terms Found)`

| ONTOLOGY | ID         | Description                                         | GeneRatio | BgRatio   | RichFactor         | FoldEnrichment   | zScore           | pvalue               | p.adjust           | qvalue             | geneID            | Count |
| -------- | ---------- | --------------------------------------------------- | --------- | --------- | ------------------ | ---------------- | ---------------- | -------------------- | ------------------ | ------------------ | ----------------- | ----- |
| MF       | GO:0005254 | chloride channel activity                           | 3/23      | 54/11168  | 0.0555555555555556 | 26.975845410628  | 8.69207598831524 | 0.000176733619478591 | 0.013907211638703  | 0.0108878827960898 | ANO3/SLC17A6/ANO5 | 3     |
| MF       | GO:0015386 | potassium:proton antiporter activity                | 2/23      | 10/11168  | 0.2                | 97.1130434782609 | 13.8127862358328 | 0.00018075635716476  | 0.013907211638703  | 0.0108878827960898 | SLC17A6/SLC9A3    | 2     |
| MF       | GO:0005253 | monoatomic anion channel activity                   | 3/23      | 66/11168  | 0.0454545454545455 | 22.0711462450593 | 7.79922873174388 | 0.000320837287562438 | 0.013907211638703  | 0.0108878827960898 | ANO3/SLC17A6/ANO5 | 3     |
| MF       | GO:0022821 | solute:potassium antiporter activity                | 2/23      | 14/11168  | 0.142857142857143  | 69.3664596273292 | 11.6274352005089 | 0.000363701318299275 | 0.013907211638703  | 0.0108878827960898 | SLC17A6/SLC9A3    | 2     |
| MF       | GO:0035613 | RNA stem-loop binding                               | 2/23      | 16/11168  | 0.125              | 60.695652173913  | 10.8547156668313 | 0.000478405576800947 | 0.013907211638703  | 0.0108878827960898 | RC3H1/DHX9        | 2     |
| MF       | GO:0015108 | chloride transmembrane transporter activity         | 3/23      | 79/11168  | 0.0379746835443038 | 18.4391854705559 | 7.06619617125931 | 0.000544854002910272 | 0.013907211638703  | 0.0108878827960898 | ANO3/SLC17A6/ANO5 | 3     |
| MF       | GO:0051139 | metal cation:proton antiporter activity             | 2/23      | 18/11168  | 0.111111111111111  | 53.951690821256  | 10.2134105773464 | 0.000608440509193255 | 0.013907211638703  | 0.0108878827960898 | SLC17A6/SLC9A3    | 2     |
| MF       | GO:0008509 | monoatomic anion transmembrane transporter activity | 3/23      | 100/11168 | 0.03               | 14.5669565217391 | 6.19070340602693 | 0.00108315148527903  | 0.0216630297055807 | 0.0169598719405533 | ANO3/SLC17A6/ANO5 | 3     |
| MF       | GO:0015103 | inorganic anion transmembrane transporter activity  | 3/23      | 108/11168 | 0.0277777777777778 | 13.487922705314  | 5.9240219074252  | 0.00135294480285254  | 0.0240523520507119 | 0.0188304598291758 | ANO3/SLC17A6/ANO5 | 3     |
| MF       | GO:0061980 | regulatory RNA binding                              | 2/23      | 30/11168  | 0.0666666666666667 | 32.3710144927536 | 7.81587713389172 | 0.00170408142839407  | 0.0247866389584591 | 0.0194053291845831 | RC3H1/DHX9        | 2     |
| MF       | GO:0140828 | metal cation:monoatomic cation antiporter activity  | 2/23      | 30/11168  | 0.0666666666666667 | 32.3710144927536 | 7.81587713389172 | 0.00170408142839407  | 0.0247866389584591 | 0.0194053291845831 | SLC17A6/SLC9A3    | 2     |


Top 0.1% GSEA at p-value cutoff 0.05 using MSIGDB geneset C5

| ID                           | Description                  | setSize                      | enrichmentScore | NES               | pvalue           | p.adjust             | qvalue             | rank               | leading_edge | core_enrichment               |                               |
| ---------------------------- | ---------------------------- | ---------------------------- | --------------- | ----------------- | ---------------- | -------------------- | ------------------ | ------------------ | ------------ | ----------------------------- | ----------------------------- |
| HP_ABNORMAL_ILEUM_MORPHOLOGY | HP_ABNORMAL_ILEUM_MORPHOLOGY | HP_ABNORMAL_ILEUM_MORPHOLOGY | 41              | 0.822653393600574 | 2.17683829345125 | 3.77339988065706e-06 | 0.0372925110205338 | 0.0372925110205338 | 142          | tags=12%, list=1%, signal=12% | DOCK11/FANCF/GPC4/SLC9A3/GPC3 |




*Pre-Post2015 Runs*

Top 0.1% enrichGO Analysis at p-value cutoff 0.05 `(6 Terms Found)`

| ONTOLOGY   | ID  | Description | GeneRatio                                          | BgRatio | RichFactor | FoldEnrichment     | zScore           | pvalue           | p.adjust             | qvalue             | geneID             | Count          |     |
| ---------- | --- | ----------- | -------------------------------------------------- | ------- | ---------- | ------------------ | ---------------- | ---------------- | -------------------- | ------------------ | ------------------ | -------------- | --- |
| GO:0015386 | MF  | GO:0015386  | potassium:proton antiporter activity               | 2/23    | 10/11168   | 0.2                | 97.1130434782609 | 13.8127862358328 | 0.00018075635716476  | 0.0252502811315201 | 0.0204948382044044 | SLC17A6/SLC9A3 | 2   |
| GO:0022821 | MF  | GO:0022821  | solute:potassium antiporter activity               | 2/23    | 14/11168   | 0.142857142857143  | 69.3664596273292 | 11.6274352005089 | 0.000363701318299275 | 0.0252502811315201 | 0.0204948382044044 | SLC17A6/SLC9A3 | 2   |
| GO:0035613 | MF  | GO:0035613  | RNA stem-loop binding                              | 2/23    | 16/11168   | 0.125              | 60.695652173913  | 10.8547156668313 | 0.000478405576800947 | 0.0252502811315201 | 0.0204948382044044 | RC3H1/DHX9     | 2   |
| GO:0051139 | MF  | GO:0051139  | metal cation:proton antiporter activity            | 2/23    | 18/11168   | 0.111111111111111  | 53.951690821256  | 10.2134105773464 | 0.000608440509193255 | 0.0252502811315201 | 0.0204948382044044 | SLC17A6/SLC9A3 | 2   |
| GO:0061980 | MF  | GO:0061980  | regulatory RNA binding                             | 2/23    | 30/11168   | 0.0666666666666667 | 32.3710144927536 | 7.81587713389172 | 0.00170408142839407  | 0.0471462528522358 | 0.0382670917253404 | RC3H1/DHX9     | 2   |
| GO:0140828 | MF  | GO:0140828  | metal cation:monoatomic cation antiporter activity | 2/23    | 30/11168   | 0.0666666666666667 | 32.3710144927536 | 7.81587713389172 | 0.00170408142839407  | 0.0471462528522358 | 0.0382670917253404 | SLC17A6/SLC9A3 | 2   |


Top 0.1% GSEA at p-value cutoff 0.05 using MSIGDB genesets: `No enriched terms found`


## Flexsweep 2:

No progress. Have emailed Jesus about continued VCF errors. Will likely forego recombination map in analysis. Sometimes on VCF subsets, it will run fine. So I wonder if this is a Flexsweep issue, not a me issue.


===========================================
# Additional Summary Stats

## Mean Heterozygosity per-individual

| sample_id   | mean_het   |
| ----------- | ---------- |
| FMNH334041  | 0.0034251  |
| FMNH333857  | 0.00357196 |
| FMNH334134  | 0.00321777 |
| FMNH333955  | 0.00341934 |
| MVZ195408   | 0.0039266  |
| FMNH333953  | 0.00359585 |
| FMNH333949  | 0.00332106 |
| MVZ191252   | 0.00309181 |
| MVZ189425   | 0.00401739 |
| MVZ190932   | 0.00345176 |
| FMNH334039  | 0.00343915 |
| MVZ195406   | 0.00400894 |
| MVZ190939   | 0.00323181 |
| MVZ193682   | 0.00307715 |
| MVZ196595   | 0.003589   |
| MVZ188705   | 0.00297206 |
| MVZ190135   | 0.0034992  |
| MVZ190136   | 0.00322915 |
| MVZ182218   | 0.00307784 |
| FMNH333950  | 0.00335915 |
| MVZ193683   | 0.00315104 |
| FMNH342072  | 0.00317627 |
| MVZ193722   | 0.00339552 |
| MVZ180498   | 0.0033711  |
| MVZ195404   | 0.00341358 |
| MVZ196594   | 0.00315788 |
| MVZ195401   | 0.00325539 |
| MVZ195403   | 0.00352494 |
| MVZ195400   | 0.00337763 |
| MVZ195402   | 0.00342577 |
| FMNH333957  | 0.00345142 |
| MVZ193641   | 0.00332011 |
| FMNH333971  | 0.00336133 |
| MVZ193628   | 0.00337023 |
| MVZ195411   | 0.00348649 |
| FMNH333958  | 0.00345266 |
| FMNH342022  | 0.00336135 |
| MVZ193629   | 0.00331583 |
| FMNH342053  | 0.00332429 |
| MVZ193497   | 0.00338276 |
| MVZ190138   | 0.00333532 |
| FMNH333954  | 0.00365916 |
| FMNH333951  | 0.00335898 |
| FMNH343436  | 0.00311983 |
| MVZ193627   | 0.00343081 |
| FMNH333956  | 0.00354686 |
| MVZ193979   | 0.00348098 |
| FMNH333952  | 0.00344728 |
| MLZ68995A   | 0.00331303 |
| MLZ70247A   | 0.00312726 |
| UWBM46816A  | 0.00322621 |
| UWBM58664A  | 0.00329433 |
| UWBM46824A  | 0.00315554 |
| UWBM127042A | 0.00300085 |
| MVZ193723A  | 0.00316537 |
| MVZ195826A  | 0.00328076 |
| MVZ193679A  | 0.00340106 |
| UWBM125069A | 0.00318503 |
| MVZ195824A  | 0.00315187 |
| UWBM107528A | 0.00294746 |
| MVZ179571A  | 0.00338175 |
| MVZ193742A  | 0.00341918 |
| UWBM126863A | 0.00311674 |
| MVZ177580A  | 0.00334589 |
| MVZ177584A  | 0.00325649 |
| MVZ195825A  | 0.00330042 |
| MVZ178459A  | 0.0032594  |
| UWBM124123A | 0.00303778 |
| MVZ193675A  | 0.00347001 |
| MVZ178454A  | 0.00310702 |
| MVZ195718A  | 0.00324277 |
| MVZ177581A  | 0.00321626 |
| MVZ195719A  | 0.00298378 |
| MVZ177567A  | 0.00328661 |
| UWBM124563A | 0.0032374  |
| UWBM107261A | 0.00309959 |
| UWBM125034A | 0.00327689 |
| MVZ179097A  | 0.00345212 |
| UWBM124665A | 0.00332559 |
| UWBM125386A | 0.00331182 |
| MVZ194938A  | 0.00323703 |


