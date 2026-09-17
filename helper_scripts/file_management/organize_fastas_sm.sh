#!/bin/sh
# Concatenate and standardize the names of sm_novogene fasta files, and move to fastqs_all directory



FASTADIR=/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/fastqs_all
PARENTDIR=/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/fastqs_novogene/01.RawData
SAMPLES=${PARENTDIR}/sample_lst.txt

#for sample in $(cat ${SAMPLES}); do

#SAMPLEDIR=${PARENTDIR}/${sample}
#cd ${SAMPLEDIR}

#find -type f -name "*_1.fq.gz" | xargs cat > ${FASTADIR}/${sample}_R1.fastq.gz
#find -type f -name "*_2.fq.gz" | xargs cat > ${FASTADIR}/${sample}_R2.fastq.gz

#cd ../

#done

# The above loop sometimes concatenated fastq files in different orders between forward and reverse reads (duh, because find isn't really good about that), obviously leading to alignment read errors after trimming. 
# It worked about 2/3 the time, but below is code used to fix the files for which this was an issue. Some are explicitly stated since they used different lane numbers or have extra files.

cd ${PARENTDIR}

for sample in $(cat ${PARENTDIR}/err_samples_lanes7_1.txt); do

SAMPLEDIR=${PARENTDIR}/${sample}
cd ${SAMPLEDIR}

echo ${sample}

Fread1=$(find -type f -name "*_L7_1.fq.gz")
Fread2=$(find -type f -name "*_L1_1.fq.gz")

Rread1=$(find -type f -name "*_L7_2.fq.gz")
Rread2=$(find -type f -name "*_L1_2.fq.gz")

cat ${Fread1} ${Fread2} > ${FASTADIR}/${sample}_R1.fastq.gz
cat ${Rread1} ${Rread2} > ${FASTADIR}/${sample}_R2.fastq.gz

cd ../

done


echo UWBM107528A
cat UWBM107528A/UWBM107528A_CKDN260011252-1A_23K7VKLT4_L7_1.fq.gz UWBM107528A/UWBM107528A_CKDN260011252-1A_23KG7CLT4_L5_1.fq.gz UWBM107528A/UWBM107528A_CKDN260011252-1A_23KH3FLT4_L3_1.fq.gz > ${FASTADIR}/UWBM107528A_R1.fastq.gz
cat UWBM107528A/UWBM107528A_CKDN260011252-1A_23K7VKLT4_L7_2.fq.gz UWBM107528A/UWBM107528A_CKDN260011252-1A_23KG7CLT4_L5_2.fq.gz UWBM107528A/UWBM107528A_CKDN260011252-1A_23KH3FLT4_L3_2.fq.gz > ${FASTADIR}/UWBM107528A_R2.fastq.gz


echo UWBM125069A
cat UWBM125069A/UWBM125069A_CKDN260011257-1A_23K7VGLT4_L7_1.fq.gz UWBM125069A/UWBM125069A_CKDN260011257-1A_23KG7VLT4_L5_1.fq.gz UWBM125069A/UWBM125069A_CKDN260011257-1A_23KH3JLT4_L7_1.fq.gz > ${FASTADIR}/UWBM125069A_R1.fastq.gz
cat UWBM125069A/UWBM125069A_CKDN260011257-1A_23K7VGLT4_L7_2.fq.gz UWBM125069A/UWBM125069A_CKDN260011257-1A_23KG7VLT4_L5_2.fq.gz UWBM125069A/UWBM125069A_CKDN260011257-1A_23KH3JLT4_L7_2.fq.gz > ${FASTADIR}/UWBM125069A_R2.fastq.gz
