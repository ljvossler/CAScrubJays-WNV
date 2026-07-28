# FST-Tajima's D Composite Statistic Pipeline
===========================================

Computing the composite FST-Tajima's D statistic between time-seperated populations should follow the outline below.

## Script Requirements
- Run the setup scripts present in both `fst` and `tajima` directories.
- Ensure that you've generated SAF Files from ANGSD in Preprocessing (A1.3).
- Various helper scripts (mentioned below) present in the `general_scripts/fst_tajima_composite_scripts` directory.

===========================================
# Step-By-Step Pipeline

**Computing initial FST and Tajima's D**

Generate initial FST and Tajima estimate by running `fst.sh` and `tajima.sh` in `Gen-Main` repo respectively. Be sure to run `tajima_difference.sh` for tajima outputs to get the difference between two populations.

**Filtering by Depth and Mapability**

After generating your initial stats, but before plotting your outputs, you'll want to rerun your analysis using only windows that filtered for adequate depth and mapability. This should reduce the presence of spurious outliers when plotting. 

Compute the average depth statistics and map statistics per site across your genome for both FST and Theta. The backbone of this is `statavg_over_bedwindows.sh` (`Gen-Main`), but there is lots of file preparation that should be done prior, which is described in `generate_avg_depthmapstats.sh`.

Now that you've computed the averaged stats, filter your FST and theta inputs by these data using `filter_avg_depthmapstats.sh`.

Using these filtered inputs, you can run `Gen-Main`'s `fst.filteredfiles.sh` and `tajima.filteredfiles.sh` for FST and Tajima respectively to generate plotted outputs post-filtering.

**Computing Composite Statistic**

You can now run `fst_tajima_composite.sh` to generate and plot the combined FST/Tajima's D output. This script will also extract lists of the most interesting genes based on their top 0.1% or 1% composite score. 

===========================================
# Additional Notes
Help/Guides: https://github.com/dannyjackson/DarwinFinches/tree/main/Scripts/C_SelectionAnalysis

Gen-Main Repo: https://github.com/dannyjackson/Genomics-Main/tree/main/C_SelectionAnalysis


===========================================
