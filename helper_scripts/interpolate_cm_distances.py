import pandas as pd
import numpy as np

raw_plink_map = '/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/recombination_map/alljays_plink_raw.map'
final_plink_map = '/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/recombination_map/alljays_plink_final.map'
ref_linkage_map = '/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/ref_linkage_map.txt'

plink_map = pd.read_csv(raw_plink_map, header=None, names=['chrom_id', 'var_id', 'cm', 'bp'])
ref_map = pd.read_csv(ref_linkage_map, sep='\t', header=None, names=['chrom_id', 'bp', 'cm'])

# Interpolate cm values for each identified chromosome
updated_rows = []
for chrom, group in plink_map.groupby('chrom_id'):
    ref_sub = ref_map[ref_map['chrom_id'] == chrom]
    
    if ref_sub.empty:
        group['cm'] = 0.0  # Default missing scaffolds to 0 (should be fine since we only care about known chroms downstream anyways)
    else:
        # Perform standard mathematical linear interpolation
        group['cm'] = np.interp(group['bp'], ref_sub['bp'], ref_sub['cm'])
        
    updated_rows.append(group)

map_df = pd.concat(updated_rows)
map_df.to_csv(final_plink_map, sep='\t', index=False, header=False)
print('done')