# Converts Pyrho recombination map to Flexweep-format (as outlined in map example on flexweep-github)
# 1. Labels chromosome location of interval
# 2. Adds interpolated cM position of interval end
# 3. Calculates cM recombination rate per Mb across interval using interpolated start and end cMs

import pandas as pd
import numpy as np
import argparse
import os

parser=argparse.ArgumentParser()
parser.add_argument("-p", "--pyrhomap", type=str, help='path to single-chromosome pyrho map file. Do not pass a FULL genome-wide map')
parser.add_argument("-r", "--refmap", type=str, help='path to reference recombination map. Should have 3 tab-delimited columns [chrom_id, bp_location, cm_distance]. Usually can be a full genome map or chromosome-split')
parser.add_argument("-s", "--scaffold", type=str, help='scaffold id to work on')
args = parser.parse_args()

pyrho_file = args.pyrhomap
ref_file = args.refmap
scaffold = args.scaffold

outdir, fname = os.path.split(pyrho_file)
fprefix = os.path.splitext(fname)[0]
flexsweep_fpath = os.path.join(outdir, f'{fprefix}.fs.map')

print('reading map data')
pyrho_map = pd.read_csv(pyrho_file, sep='\t', header=None, names=['Begin', 'End', 'bp_rate'], dtype={"Begin": int, "End": int, "bp_rate": np.float64})
ref_map = pd.read_csv(ref_file, sep='\t', header=None, names=['chrom_id', 'bp', 'cm'], dtype={"chrom_id": str, "bp": np.int64, "cm": np.float64})
ref_chrom_map = ref_map[ref_map["chrom_id"] == scaffold].sort_values(by="bp")

print('interpolating cMs')
interp_cm_ends = np.interp(pyrho_map['End'].values, ref_chrom_map['bp'].values, ref_chrom_map['cm'].values, 
                             left=ref_chrom_map['cm'].values[0], right=ref_chrom_map['cm'].values[-1])  
interp_cm_starts = np.interp(pyrho_map['Begin'].values, ref_chrom_map['bp'].values, ref_chrom_map['cm'].values, 
                             left=ref_chrom_map['cm'].values[0], right=ref_chrom_map['cm'].values[-1])  

print('calculating intervals')
cm_intervals = interp_cm_ends - interp_cm_starts
bp_intervals = pyrho_map['End'] - pyrho_map['Begin']
cm_per_mb = cm_intervals / (bp_intervals / 1000000)

print('cleaning up')
pyrho_map['Chr'] = scaffold
pyrho_map['cMperMb'] = cm_per_mb
pyrho_map['cM'] = interp_cm_ends
flexsweep_map = pyrho_map[['Chr', 'Begin', 'End' , 'cMperMb', 'cM']]
flexsweep_map = flexsweep_map[flexsweep_map['cMperMb'] > 0]

print('saving to ' + flexsweep_fpath)
flexsweep_map.to_csv(flexsweep_fpath, index=False, header=False)
print('done')