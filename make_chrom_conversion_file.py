# Small helper script to make the chromosome conversion file built in base_setup.sh

import argparse
parser=argparse.ArgumentParser()
parser.add_argument("-i", "--input", type=str, help='The path to the tab-separated chrom name map file generated from the NCBI dataset/dataformat commands')
parser.add_argument("-o", "--output", type=str, help='The path for the chrom_conversion file')
parser.add_argument("-e", "--exclusions", type=str, help='Strings to exclude, comma seperated, no spaces (usually portions of NCBI accession codes for incomplete scaffolds or sex chromosomes)')
args = parser.parse_args()


with open(args.input, 'r') as f:
    input = f.readlines()


# Store scaffold/chromosome codes we want to exclude in a list
exclusion_lst = args.exclusions.split(',')

# Iterate over each line and format string.
line_lst = []
for line in input[1:]: # Skipping first header line here
    split_line = line.split()
    mapped_line = split_line[1] + ',' + split_line[0]
    if not any(code in mapped_line for code in exclusion_lst): # Only append to list if accession code is NOT in our exclusion list
        line_lst.append(mapped_line+'\n')


with open(args.output, 'w') as f:   
    f.writelines(line_lst)