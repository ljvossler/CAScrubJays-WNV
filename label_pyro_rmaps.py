import pandas as pd
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--scaffolds", type=str, help="scaffolds list file")
parser.add_argument("--popname", type=str, help="pop name of rmaps")
parser.add_argument("--outdir", type=str, help="path of searching directory and output")
args = parser.parse_args()

with open(args.scaffolds, 'r') as f:
    scaffolds = f.readlines()
scaffolds = [line.strip() for line in scaffolds]

for s in scaffolds:
    df = pd.read_csv(f'{args.popname}_{s}.rmap', sep='\t')
    df.insert(0, '', s)
    df.to_csv(f'{args.popname}_{s}.rmap', header=False, index=False, sep='\t')