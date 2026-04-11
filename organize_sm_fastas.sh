# Concatenate SM Fasta files from all samples

sm_old_path1='/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/sm_old/SM-8328318_Run1_TS/fastqs'
sm_old_path2='/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/sm_old/SM-8328318_Run2/fastqs'
sm_new_path1='/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/sm_new/SM_redo/Run1'
sm_new_path2='/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/sm_new/SM_redo/Run2'
sm_merged_path='/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/sm_merged'

for sample in $(ls $sm_old_path1); 
do 
echo $sample

echo "Catted Files (Run 1):" $sm_old_path1/$sample/*_R1_001.fastq.gz $sm_old_path2/$sample/*_R1_001.fastq.gz $sm_new_path1/$sample/${sample}_R1.fastq.gz $sm_new_path1/$sample/${sample}_R1.fastq.gz
cat $sm_old_path1/$sample/*_R1_001.fastq.gz $sm_old_path2/$sample/*_R1_001.fastq.gz $sm_new_path1/$sample/${sample}_R1.fastq.gz $sm_new_path1/$sample/${sample}_R1.fastq.gz > $sm_merged_path/${sample}_R1.fastq.gz

echo "Catted Files (Run 2):" $sm_old_path1/$sample/*_R2_001.fastq.gz $sm_old_path2/$sample/*_R2_001.fastq.gz $sm_new_path1/$sample/${sample}_R2.fastq.gz $sm_new_path1/$sample/${sample}_R2.fastq.gz
cat $sm_old_path1/$sample/*_R2_001.fastq.gz $sm_old_path2/$sample/*_R2_001.fastq.gz $sm_new_path1/$sample/${sample}_R2.fastq.gz $sm_new_path1/$sample/${sample}_R2.fastq.gz > $sm_merged_path/${sample}_R2.fastq.gz
done