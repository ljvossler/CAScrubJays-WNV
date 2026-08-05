#!/bin/bash

# I did an oopsie and got too excited when I finally recieved all my genome sequences. 
# I didn't fully standardize the sample ids between my sequencing datasets. Now its starting to be a painful mistake

# The following is some code or descriptions of actions taken in Aug 2026 to fix this issue with the headers of critical existing datafiles
# None of this should change the underlying data, just moving forward, I used these cleaned files where possible. Original files were temporarily kept

source ../params_base.sh
OLDNEW_MAP=${OUTDIR}/referencelists/old_new_sampleid_map.tsv # File mapping old names to new/standardized ones

#=====================
# Combined & Filtered VCF
#=====================
ORIGINAL_VCF=${OUTDIR}/datafiles/genotype_calls/alljays_tagfilled.vcf.gz
REHEADER_VCF=${OUTDIR}/datafiles/genotype_calls/alljays_renamed.vcf.gz
bcftools reheader -s ${OLDNEW_MAP} -o ${REHEADER_VCF} ${ORIGINAL_VCF}
bcftools index ${REHEADER_VCF}

# Verify header change
#bcftools query -l ${ORIGINAL_VCF}
#bcftools query -l ${REHEADER_VCF}

# NOTES:
# SMC++ and ADMIXTURE analyses used the ORIGINAL_VCF (But I may redo ADMIXTURE anyways, and samplenames do not affect utility of SMC outputs)
# All other analyses requiring this VCF will use REHEADER_VCF



#=====================
# IndelRealigned BAM Files
#=====================
# Sample ID files and Bamlists already updated with desired standardized names

mkdir ${BAMDIR}/old

for sample in $(cat ${OUTDIR}/referencelists/alljays_sampleids.txt);
do
    # Save old files to safe location
    mv ${BAMDIR}/${sample}.realigned.bam mv ${BAMDIR}/old/${sample}.realigned.bam.old
    mv ${BAMDIR}/${sample}.realigned.bai mv ${BAMDIR}/old/${sample}.realigned.bai.old
    old_id=$(echo $(samtools samples ${BAMDIR}/old/${sample}.realigned.bam.old) | awk '{print $1}') # Extract old id. Requires samtools v1.19 on HPC
    # Generate reheadered bams
    samtools view -H ${BAMDIR}/old/${sample}.realigned.bam.old | sed "s/SM:${old_id}/SM:${sample}/g" | samtools reheader - ${BAMDIR}/old/${sample}.realigned.bam.old > ${BAMDIR}/${sample}.realigned.bam
    samtools index ${BAMDIR}/${sample}.realigned.bam
    samtools samples ${BAMDIR}/${sample}.realigned.bam

# NOTES:
# All CRAM files regenerated from reheadered bams
# Decided to also regenerate individual vcf/masks (A2.4_individual_mask_vcf.sh) using these reheadered bams (since there are just so many of them...)
# All ANGSD outputs for SNPID, genotype likelihoods, and SAF generation are currently still generated from old bams since FST and TD analyses are global (not at resolution of samples), so I won't be dealing with samplenames.