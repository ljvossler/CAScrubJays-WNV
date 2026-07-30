#!/usr/bin/Rscript

library(tidyverse)
library(optparse)
option_list = list(
  make_option(c("-e", "--eigenvec"), type="character", default=NULL, 
              help="path to eigenvector file", metavar="character"),
  make_option(c("-a", "--eigenval"), type="character", default=NULL, 
              help="path to eigenvalue file", metavar="character")
) 
opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)


pca <- read_table2(opt$eigenvec, col_names = FALSE)
eigenval <- scan(opt$eigenval)

# sort out the pca data
# remove nuisance column
pca <- pca[,-1]
# set names
names(pca)[1] <- "ind"
names(pca)[2:ncol(pca)] <- paste0("PC", 1:(ncol(pca)-1))


# sort out the individual species and pops
# spp
spp <- rep(NA, length(pca$ind))
spp[grep("PunPund", pca$ind)] <- "pundamilia"
spp[grep("PunNyer", pca$ind)] <- "nyererei"
# location
loc <- rep(NA, length(pca$ind))
loc[grep("Mak", pca$ind)] <- "makobe"
loc[grep("Pyt", pca$ind)] <- "python"
# combine - if you want to plot each in different colours
spp_loc <- paste0(spp, "_", loc)


# remake data.frame
pca <- as.tibble(data.frame(pca, spp, loc, spp_loc))


# first convert to percentage variance explained
pve <- data.frame(PC = 1:16, pve = eigenval/sum(eigenval)*100)


# make plot
a <- ggplot(pve, aes(PC, pve)) + geom_bar(stat = "identity")
a + ylab("Percentage variance explained") + theme_light()
# calculate the cumulative sum of the percentage variance explained
cumsum(pve$pve)

# plot pca
b <- ggplot(pca, aes(PC1, PC2, col = spp, shape = loc)) + geom_point(size = 3)
b <- b + scale_colour_manual(values = c("red", "blue"))
b <- b + coord_equal() + theme_light()
b + xlab(paste0("PC1 (", signif(pve$pve[1], 3), "%)")) + ylab(paste0("PC2 (", signif(pve$pve[2], 3), "%)"))
