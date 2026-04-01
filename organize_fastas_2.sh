#!/bin/sh

FASTA_DIR=/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/sm_new/merged
SM_DIR=/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/sm_new/SM_redo
for sample in $(ls $SM_DIR/Run2/); 
do 
echo $sample
cat $SM_DIR/Run1/$sample/${sample}_R1.fastq.gz $SM_DIR/Run2/$sample/${sample}_R1.fastq.gz > $FASTA_DIR/${sample}_R1.fastq.gz
cat $SM_DIR/Run1/$sample/${sample}_R2.fastq.gz $SM_DIR/Run2/$sample/${sample}_R2.fastq.gz > $FASTA_DIR/${sample}_R2.fastq.gz
done