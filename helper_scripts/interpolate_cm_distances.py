import pandas as pd
import numpy as np
import argparse

parser=argparse.ArgumentParser()
parser.add_argument("-s", "--scaffold", type=str, help='scaffold id')
args = parser.parse_args()

raw_plink_map = f'/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/recombination_map/alljays_plink_{args.scaffold}.map'
final_plink_map = f'/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/recombination_map/alljays_plink_{args.scaffold}.map'
ref_linkage_map = '/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/ref_linkage_map.txt'

plink_map = pd.read_csv(raw_plink_map, header=None, names=['chrom_id', 'var_id', 'cm', 'bp'], dtype={"chrom_id": str, "var_id": str, "cm": np.float64, "bp": np.int64})
ref_map = pd.read_csv(ref_linkage_map, sep='\t', header=None, names=['chrom_id', 'bp', 'cm'], dtype={"chrom_id": str, "bp": np.int64, "cm": np.float64})
ref_chrom_map = ref_map[ref_map["chrom_id"] == args.scaffold].sort_values(by="bp")

# Interpolate cm values for one scaffold
interpolated_cms = np.interp(plink_map['bp'].values, ref_chrom_map['bp'].values, ref_chrom_map['cm'].values, 
                             left=ref_chrom_map['cm'].values[0], right=ref_chrom_map['cm'].values[-1])     

plink_map['cm'] = interpolated_cms

plink_map.to_csv(final_plink_map, sep='\t', index=False, header=False)
print('done')