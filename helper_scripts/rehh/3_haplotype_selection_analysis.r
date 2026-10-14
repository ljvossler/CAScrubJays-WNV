library(ggplot2)
library(rehh)
library(vcfR)

# Should be run per-population for calculation of iHS

cat("Parsing command-line arguments...\n")
args <- commandArgs(trailingOnly = TRUE)
wgscan1 <- args[1]
wgscan2 <- args[2]
outdir <- args[4]
pop1 <- args[5]
pop2 <- args[6]

wgscan1_df <- read.table(file = wgscan1, sep = "\t")
wgscan2_df <- read.table(file = wgscan2, sep = "\t")

# calculate genome-wide iHS values for each population
cat(paste0("calculating iHS...\n"))
wgs_ihs_pop1 <- ihh2ihs(wgscan1_df)
wgs_ihs_pop2 <- ihh2ihs(wgscan2_df)

# calculate rsb between two populations
cat(paste0("calculating RHS...\n"))
rsb_pop1_pop2 <- ines2rsb(scan_pop1 = wgscan2_df,
                        scan_pop2 = wgscan2_df,
                        popname1 = pop1,
                        popname2 = pop2)
write.table(rsb_pop1_pop2, file = paste0(outdir, "/", pop1, "_", pop2, "_rsb.tsv"), sep = "\t")


# calculate xp-ehh between two populations
cat(paste0("calculating XP-EHH...\n"))
xpehh_pop1_pop2 <- ies2xpehh(scan_pop1 =  wgscan2_df,
                           scan_pop2 =  wgscan2_df,
                           popname1 = pop1,
                           popname2 = pop2)
write.table(xpehh_pop1_pop2, file = paste0(outdir, "/", pop1, "_", pop2, "_xpehh.tsv"), sep = "\t")

# Plot statistics
#manhattanplot(wgs_ihs)


#plot(rsb_pop1_pop2[, paste0("RSB_", pop1, "_", pop2)],
#     xpehh_pop1_pop2[, paste0("XPEHH_", pop1, "_", pop2)],
#     xlab = "Rsb",
#     ylab = "XP-EHH",
#     pch = ".",
#     xlim = c(-7.5, 7.5),
#     ylim = c(-7.5, 7.5))
# add dashed diagonal
#abline(a = 0, b = 1, lty = 2)
