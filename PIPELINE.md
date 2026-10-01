# CA Scrubjays Genomic Analysis Pipeline
===========================================

An description of the bioinformatic pipeline implemented for the analysis of California Scrub Jays (scrubjays) genomes over time in response to West Nile Virus (WNV) exposure.

Uses and expands upon the existing pipeline for time-series genomic analyses built by Danny Jackson in the Genomics-Main repo

===========================================
# Sampling and Sequencing

This study used whole genome illumina-short read data from 80 total A. californica individuals from across the species’ range within along the west coast of the United States. 50 individuals were provided by the California Conservation Genomes Project (CCGP). Additional 30 tissue samples provided by multiple Mueseum collections were whole-genome sequenced by novogene (find specific procedure). Our final sample dataset contained 80 individuals sequenced to an average of about 15x, with minimum acceptable coverage of ~7x. 50 samples are "Post-WNV", collected between ~2015-present. 30 samples are "Pre-WNV", collected between ~1990-2000.

__CCGP__: WGS scrubjay data for 50 individuals provided by Devon DeRaad from the California Conservation Genomes Project. This data was sequenced using short-read Illumina sequencing (*follow up with Devon later on more specifics*)

__Collections__: Raw scrubjay tissue samples for 62 individuals provided by multiple Mueseum collections (hereafter referred to as SM samples). 33 of these samples were sucessfully whole genome sequenced using Illumina short-read methods (*need to review specifics*).


*Sampling Info and coverage stats:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/programs/CAScrubJays-WNV/sample_info/`


===========================================
# Alignment

Raw read data for CCGP samples were paired-end adapter-trimmed using Heng Li's `Trimmomatic` software under a minimum read length of 90bp and window length of 40 bp. Leading and Trailing strand were trimmed by 20 bp. Additional Mueseum read data were paired-end trimmed using `FASTP` with minimum acceptable PHRED-score of 5 and base-limit of 15.

All samples were aligned to the Florida Scrub Jay Reference Genome (NCBI RefSeq Accession: `GCF_041296385.1`) using `BWA MEM`, with subsequent read-group assignment and duplicate marking with `Picard`. Prior to downstream variant calling and SAF/genotype likelihood analyses, these alignments were realigned around indels using `GATK v3.7.0` indelrealignment.


*Raw FASTQs:* `NAS`:`/volume1/homes/mcnew/ljvossler/scrub_jay_data/fastqs/`

*IndelRealigned BAM Files:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/indelrealignment/`

*Relevant Scripts:* `Gen-Main:devel`:`A_Preprocessing (A0.1 - A0.5)`



===========================================
# Site Allele Frequencies and Genotype Likelihoods

I used `ANGSD` for SNP identification and site allele frequency (SAF) generation. Sites were considered for SNPs under a minimum depth and minor allele frequency of 4x and 30 respectively. Sites were also filtered by quality, with minimum mapping score and overall quality both set to 30. All sites present in at least one individual with a maximum p-value of 1e-6 were classified as significantly likely to be SNPs and were used to generate genotype likelihoods. 

SAFs for both the `pre` and `post` populations were estimated using `ANGSD -dosaf` with the same SNP ID parameters used prior.


*SNP Sites:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/alljays/`

*Genotype Likelihoods:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/geno_likelihoods/`

*Site Allele Frequencies:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/safs/`

*Relevant Scripts:* `Gen-Main:devel`:`A_Preprocessing (A1.1 - A1.3)`


===========================================
# Variant Calling and Phasing

Alignments from all 80 samples were used in chromosome-split variant calling using `bcftools mpileup | call`. All unplaced scaffolds were called together. VCFs were filtered by quality and depth using `bcftools` and `vcftools`. All sites with QUAL<100 and read depth<4 were rejected. Non-SNP sites with MAF<0.01 were removed using `plink`.

I used `Plink v1.9` to generate a .map file from this filtered VCF. This map file was missing important information about genetic distance (cM) for each SNP. Using the most recent linkage map for the Florida Scrub Jay reference genome, I linearly interpolated these distances for each SNP using a custom script.

All VCFs wer phased using `BEAGLEv5.5` under default parameters, with the interpolated recombination map data.

Since `BEAGLE` uses a statistics-based approach to phasing, it neglects the information present in the raw read data, which may be helpful to improving the phasing of low-confidence sites. Therefore, I used `SAPPHIRE`, a read-based phasing approach for additional rephasing of low-confidence sites. 

*Raw and Filtered VCF Outputs:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/genotype_calls/`

*Recombination Maps (No CM values):* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/recombination_map/plink_raw/`

*Recombination Maps (CM values populated):* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/recombination_map/plink_cm/`

*Phased VCFs:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/split_vcf/phased/`

*Rephased VCFs:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/rephased_vcf/`

*Relevant Scripts:* 
1. `Gen-Main:devel`:`A_Preprocessing (A2.1, A2.2, A2.6.2, A2.7)`
2. `CA-Scrubjays`: `helper_scripts/interpolate_cm_distances.py`


===========================================
# FST / Tajima's D
The hitchhiking theory predicts that selective sweeps may reduce the genetic diversity in low-recombination regions of a genome that are under selection. This characteristic decrease in genetic diversity across a time-series can serve as a useful indicator of a possible sweep.

## FST
FST computation between `pre` and `post` scrubjay populations was performed using `ANGSD realSFS fst` using genotype likelihood estimates. Sliding window FST calculated using window size and step size of 50000.

## Tajima's D
Theta computation for both `pre` and `post` scrubjay populations performed using `ANGSD realSFS saf2theta` using genotype likelihood estimates. Sliding window Theta calculated using window size and step size of 50000.

## Quality Filtering
To account for the potential bias induced by any remaining low-depth or poorly-mapped reads, both FST and Tajima D windows were filtered for high quality depth / mappability reads. The genome-wide mappability mask was generated using Heng Li's `SNPable` pipeline and average depth statistics per site were obtained using `samtools depth`. These data were used to filter out low quality windows that could introduce spurious outliers.

## Composite Statistic (CS) and Candidate Genelists
Our combined selection statistic is calculated by summing the FST and inverse-Tajima's D value for each 50000 bp window. We extract the windows containing both the top 1% and 0.1% highest composite stat scores as the most likely potential indicators of selection in the genome. We use `bedtools intersect` with the FL Scrub Jay ref-genome to identify genes present within these top windows. We identified 32 genes/loci present in the top 0.1% of windows, and 227 genes represented in the top 1%.

*Raw and Filtered FST:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/analyses/fst/`

*Raw and Filtered Tajima:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/analyses/tajima/`

*Composite Stat:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/analyses/composite_stat/`

*Relevant Scripts:* 
1. `Gen-Main:devel`:`general_scripts (filter_statavg_output.r, and manhattan plotting scripts)`, `A_Preprocessing (A2.3)`
2. `CA-Scrubjays`: `helper_scripts/fst_tajima/`


===========================================
# Flexsweep Selection Analysis
Although analysis of genetic diversity through statistics such as FST and Tajima's D is a valuable proxy indicator of a selective sweep, it is also beneficial to employ other, more direct selection analysis tools for WGS data. 

We use `Flexsweep 2.0` as our primary selection analysis tool. Flexsweep calculates a wide range of commonly used selective sweep statistics (nsl, iHS, DIND, etc) and employs them all in a convolutional neural network to estimate the likelihood of a sweep.

Demographic histories estimated by SMC++ were were used in the flexsweep simulation of demographic histories.



===========================================
# Identifying Candidate Genes for WNV Selection

It is valuable to understand whether estimates of FST, Tajima's D difference, and our Composite Stat fluctuate significantly per gene. This can help us understand whether these high-CS windows are indicative of a significant overrepresentation of WNV-related genes among scrub jays.

We used `bedtools intersect` to identify windows that overlapped with known genes in the FL scrub jay reference genome. To try accounting for regulatory regions beyond each gene location, the intervals were extended by 1kb on each end. We recorded the mean statistics from all windows that overlapped with a gene's interval.

## WNV VIP Identification
We inferred WNV-related candidate genes based on internal lists of known WNV-VIPs in humans. Homologous human and scrubjay genes were identified via `DIAMOND` reciprocal best hit search using the `reciprologs` python package (Human NCBI Accession: `GCF_000001405.40`). We found ~20k homologous regions under an `ultra-sensitive` search. These homologous regions were filtered by our WNV-VIP lists. 205 homologous regions were successfully mapped to human WNV VIPs.

## Gene Ontology Analysis
We used the R package, `clusterProfiler` for basic Gene Ontology analyses. We tested whether our top 0.1% and 1% CS genes were overrepresented compared to our full list of genes. There are no annotated gene databases for the California Scrub Jay. Therefore, we ran our gene ontology analyses in `clusterProfiler` referencing human GO databases (`org.Hs.eg.db`), searching for enriched gene symbol ids across all GO classifications under default parameters. We found 11 enriched GO terms across our top 0.1% CS genes under a p-value cutoff of 0.05.

## Gene Set Enrichment Analysis
We also performed a GSEA of all genes identified from our windows, ranking our genes by their composite FST/Tajima's D score. No significantly enriched GO terms were found among our top-CS genes at or below a p-value of 0.05. We performed this analysis across multiple human gene sets (Molecular Signatures Database and OrgDB).


## Are WNV-relevant genes disproportionally represented in our 0.1% of CS windows?
Only two WNV-VIP genes were present among our 227 top-1% of CS windows, indicating little evidence of overrepresentation of WNV-VIPs in our top windows.

*Master Genelist:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/scrubjays_master_genelist.revised.bed`

*GO Analysis:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/enrichGO_top0.1_p0.05.csv`

*Reciprocal Best Hits:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/diamond/rec_best_hits.txt`

*Relevant Scripts:* 
1. `CA-Scrubjays`:`build_master_genelist.sh`, `diamond.sh`, `go_analysis.r`
2. `reciprologs`: `https://github.com/glarue/reciprologs.git`

===========================================
# Demography
Understanding the demographic histories of the scrub jay population pre and post-WNV introduction is critical to discern whether our measures of genetic diversity truly represent sweeps of advantageous mutations or if they are only indicative of demographic events such as bottlenecks or expansions. Additionally, major environmental shifts or demographic events can result in significant differences in estimates of effective population size (Ne) between populations at different timepoints.

## SMC++

## MSMC2: Ancient Demography Analysis
Mask and Individual VCF files per scaffold were generated using `vcfAllSiteParser.py` in `msmc-tools` and used to generate MSMC inputs using `generate_multihetsep.py`. The inputted chromosome-VCFs were called using `bcftools`, and filtered and phased under the same parameters prior variant calling. These VCFs were called ensuring that homozygous reference sites were kept. 

The required genome-wide mappability mask for input-generation was generated using Heng Li's `SNPable` pipeline and converted to bed format using `msmc-tools`: `makeMappabilityMask.py`.

MSMC analyses were run with default parameters incorporating data from 8 haplotype pairs (4 individuals) for each population.

I performed additional analyses on 20 bootstrapped haplotype datasets for each population. All bootstrapped inputs were generated using `msmc-tools`: `multihetsep_bootstrap.py`. MSMC analyses were performed with same parameters as original runs.

## GONE2: Recent Demography Analysis
MSMC2's Markovian coalescent approach is often more appropriate for ancient demographic predictions due to the slow accumulation of mutations. Therefore, we also use GONE2, a linkage disequilibrium-based tool designed to more reliably predict recent demography (within 200-300 generations) from genomic data. We performed our analysis using our interpolated recombination map and phased called-variant data for each sample subset. Due to computational limitations, we only incorporated variant data from the first 12 chromosomes, each being at least 20cM in genetic distance (a requirement by GONE2). Each run was performed using a maximum of 2 million SNPs and default parameters.

We ran GONE2 on 30 Pre-WNV samples spanning 1987-1999 using the parameters described above. Our Post-WNV sampling spans a much broader timespan, so we ran GONE2 separately for two Post-WNV bins spanning 2001-2011 and 2015-2023, with 17 and 33 samples respectively. We aimed to have our bins span roughly 10 years and with as many samples as possible.

We notice a significant decrease in estimated effective population size of scrub jays in bin2 (between 2001-2011), followed by a return to estimated Pre-WNV Ne in Post-WNV bin3 (2015-2023). This demographic trend displayed by GONE2 is reflective of the known population decrease recorded by breeding bird survery data among scrubjays immediately following the introduction of WNV along the west coast of the US. This demonstrates both power of genomic data in estimating demography over recent evolutionary timespans and shows that exposure to WNV coincides with a significant decrease in genetic diversity in scrubjays. However, this does not necessarily indicate that WNV has had a selective effect on the population's genome.

After equally subsampling across all pre and post bins, there is no significant difference in Ne. Sample size is the primary reason for fluctuating Ne estimates. Larger sample sizes consistently result in higher Ne trends.

*SMC++ Outputs:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/demography/`

*MSMC2 Outputs:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/analyses/msmc/`

*GONE2 Outputs:* `HPC`:`/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/analyses/gone2/`

*Relevant Scripts:* 
1. `Gen-Main:devel`:`B_Phylogenetics/gone/`, `B_Phylogenetics/msmc/`
2. `msmc-tools`: `https://github.com/stschiff/msmc-tools.git`



===========================================
# Additional Notes

- CA-Scrubjays: https://github.com/ljvossler/CAScrubJays-WNV.git
- Genomics-Main: https://github.com/dannyjackson/Genomics-Main.git
- FL Scrub Jay Ref Genome Publication : https://doi-org.ezproxy1.library.arizona.edu/10.1093/jhered/esad047

===========================================