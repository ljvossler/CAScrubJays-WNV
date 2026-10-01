#!/bin/bash

cd /xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/rephased_vcf/chr_split/reinfoed

INPUT_VCF="alljays_merged.reinfo.vcf.gz"
WINDOW=100000

# Extract chrom lengths
bcftools view -h "$INPUT_VCF" | grep "^##contig=" | sed -e 's/##contig=<ID=//' -e 's/,length=/\t/' -e 's/>//' > genome.txt #maunully removed unplaced scaffolds

# Find all coordinate gaps larger than threshold
bcftools query -f '%CHROM\t%POS\n' "$INPUT_VCF" | python3 -c "
import sys
prev_chrom, prev_pos = None, None
threshold = $WINDOW

for line in sys.stdin:
    chrom, pos_str = line.strip().split('\t')
    pos = int(pos_str)
    if chrom == prev_chrom and (pos - prev_pos) >= threshold:
        print(f'{chrom}\t{prev_pos}\t{pos - 1}')
    prev_chrom, prev_pos = chrom, pos
" > deserts.bed

# Get complement map of valid regions
bedtools complement -i deserts.bed -g genome.txt > valid_chunks.bed

# Chunk the vcf
chunk_num=1
while read -r chrom start end; do
    # Skip processing lines if the file returns empty bounds
    [ -z "$chrom" ] && continue
    
    echo "Processing chunk #${chunk_num} -> ${chrom}:${start}-${end}"
    
    # Extract coordinates chunk
    bcftools view -r "${chrom}:${start}-${end}" "$INPUT_VCF" -O z -o "chunked/fs_chunk${chunk_num}_${chrom}.vcf.gz"
    tabix -p vcf "chunked/fs_chunk${chunk_num}_${chrom}.vcf.gz"
    
    ((chunk_num++))
done < valid_chunks.bed