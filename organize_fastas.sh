#!/bin/sh

# Concatenate SM Fasta files from all samples across all runs based on Read Number, standardize the names, and place merged fastq in fastqs_all directory
FASTA_DIR=/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/fastqs_test
sm_path_run1='/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/sm_sequences/SM-8328318_Run1_TS/fastqs'
for sample in $sm_path_run1/*; 
do 
echo $sample
cat $sample/*_R1_001.fastq.gz > $FASTA_DIR/$(basename $sample)_R1_run1.fastq.gz
cat $sample/*_R2_001.fastq.gz > $FASTA_DIR/$(basename $sample)_R2_run1.fastq.gz; 
done

sm_path_run2='/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/sm_sequences/SM-8328318_Run2/fastqs'
for sample in $sm_path_run2/*; 
do 
echo $sample
cat $sample/*_R1_001.fastq.gz > $FASTA_DIR/$(basename $sample)_R1_run2.fastq.gz
cat $sample/*_R2_001.fastq.gz > $FASTA_DIR/$(basename $sample)_R2_run2.fastq.gz; 
done

cat $FASTA_DIR/$(basename $sample)_R1_run1.fastq.gz $FASTA_DIR/$(basename $sample)_R1_run2.fastq.gz > $FASTA_DIR/$(basename $sample)_R1.fastq.gz && rm $FASTA_DIR/$(basename $sample)_R1_run1.fastq.gz $FASTA_DIR/$(basename $sample)_R1_run2.fastq.gz
cat $FASTA_DIR/$(basename $sample)_R2_run1.fastq.gz $FASTA_DIR/$(basename $sample)_R2_run2.fastq.gz > $FASTA_DIR/$(basename $sample)_R2.fastq.gz && rm $FASTA_DIR/$(basename $sample)_R2_run1.fastq.gz $FASTA_DIR/$(basename $sample)_R2_run2.fastq.gz

# Standardize the names of CCGP fasta files, and move to fastqs_all directory
python3 <<'EOF'
/
import os
ccgp_path='/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/ccgp_sequences/public.hoffman2.idre.ucla.edu/aguillon/BHEMT'
FASTA_DIR='/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/fastqs_all'
for file in os.listdir(ccgp_path):
    print(file)
    split_fname = file.split('_')
    clean_fname = f'{split_fname[0]}-{split_fname[1]}_{split_fname[2]}'
    os.rename(os.path.join(ccgp_path, file), os.path.join(FASTA_DIR, clean_fname))
EOF


# create list of samples, assumes fastas are all formated with sample names as first term in an underscore separated string
ls ${FASTA_DIR} | awk -F "_" '{print $1}' | sort -u > "/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/test_sampleids.txt"