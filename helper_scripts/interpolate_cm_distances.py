# Interpolates CM distances in chromosome-split PLINK .map files using a user-provided reference map

import pandas as pd
import numpy as np
import argparse
import os

parser=argparse.ArgumentParser()
parser.add_argument("-p", "--plinkmap", type=str, help='path to chromosome plink .map file (Standard PLINK format)')
parser.add_argument("-r", "--refmap", type=str, help='path to reference recombination map. Should have 3 tab-delimited columns [chrom_id, bp_location, cm_distance]. Can be a full genome map or chromosome-split')
args = parser.parse_args()

outdir, fname = os.path.split(args.plinkmap)
fprefix = os.path.splitext(fname)[0]
final_plink_map = os.path.join(outdir, f'{fprefix}_cm.map')

print('reading map data')
plink_map = pd.read_csv(args.plinkmap, sep='\t', header=None, names=['chrom_id', 'var_id', 'cm', 'bp'], dtype={"chrom_id": str, "var_id": str, "cm": np.float64, "bp": np.int64})
ref_map = pd.read_csv(args.refmap, sep='\t', header=None, names=['chrom_id', 'bp', 'cm'], dtype={"chrom_id": str, "bp": np.int64, "cm": np.float64})
ref_chrom_map = ref_map[ref_map["chrom_id"] == args.scaffold].sort_values(by="bp")

print('interpolating cms')
# Interpolate cm values for one scaffold
interpolated_cms = np.interp(plink_map['bp'].values, ref_chrom_map['bp'].values, ref_chrom_map['cm'].values, 
                             left=ref_chrom_map['cm'].values[0], right=ref_chrom_map['cm'].values[-1])     

plink_map['cm'] = interpolated_cms
print('saving to ' + final_plink_map)
plink_map.to_csv(final_plink_map, sep='\t', index=False, header=False)
print('done')