#!/bin/sh
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
#ls ${FASTA_DIR} | awk -F "_" '{print $1}' | sort -u > "/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/ccgp_sampleids.txt"