### Load libraries
library(ggplot2)

cat("Parsing command-line arguments...\n")
args <- commandArgs(trailingOnly = TRUE)
stats_tsv <- args[1]
outdir <- dirname(stats_tsv)
outprefix <- args[2]

df <- read.delim(stats_tsv, header = TRUE, stringsAsFactors = FALSE)
df_clean <- df[complete.cases(df[, c("fst", "tajima")]), ]

### Select only the numeric columns
stat_matrix <- df_clean[, c("fst", "tajima")]

### Compute Pearson correlation matrix
cor_matrix <- cor(stat_matrix, method = "pearson")
print(round(cor_matrix, 3))


# Create composite score
### Normalize each component (Z-scores)
df_clean$z_fst <- scale(df_clean$fst)
df_clean$z_tajima <- scale(df_clean$tajima)

### Invert Tajima’s D so that low values contribute positively to the score
df_clean$z_tajima_inv <- -1 * df_clean$z_tajima

df_clean$composite_score <- df_clean$z_fst + df_clean$z_tajima_inv


# Get top 0.1%
df_clean$highest_composite <- "FALSE"
cutoff <- quantile(df_clean$composite_score, 0.999)
top_windows <- df_clean[df_clean$composite_score >= cutoff, ]
df_clean$highest_composite <- df_clean$composite_score >= cutoff
write.table(top_windows, file.path(outdir, paste(outprefix,"composite_score.additive.0.1perc.tsv")), sep = "\t", row.names = FALSE, quote = FALSE)

# Get top 1%
df_clean$highest_composite <- "FALSE"
cutoff <- quantile(df_clean$composite_score, 0.99)
top_windows <- df_clean[df_clean$composite_score >= cutoff, ]
df_clean$highest_composite <- df_clean$composite_score >= cutoff
write.table(top_windows, file.path(outdir, paste(outprefix,"composite_score.additive.1perc.tsv")), sep = "\t", row.names = FALSE, quote = FALSE)


# write full table to tsv
write.table(df_clean, file.path(outdir, paste(outprefix,"composite_score.additive.tsv")), sep = "\t", row.names = FALSE, quote = FALSE)

df_clean$highlight_group <- "None"
df_clean$highlight_group[df_clean$highest_composite] <- "CS top 0.1%"

# Plot and save to PDF
pdf(file.path(outdir, paste(outprefix,"additive_composite_score.scaled.pdf")), width = 8, height = 6)
ggplot(df_clean, aes(x = z_fst, y = z_tajima_inv)) +
  geom_point(aes(color = highlight_group), size = 1, alpha = 0.8) +
  scale_color_manual(values = c("None" = "gray80",
                                "CS top 0.1%" = "blue")) +
  labs(title = "Plot of Selection Statistics",
       x = "z_FST", y = "z_Tajima_inv", color = "Top 0.1%") +
  theme_minimal()
dev.off()

# Plot and save to PDF
pdf(file.path(outdir, paste(outprefix,"additive_composite_score.pdf")), width = 8, height = 6)
ggplot(df_clean, aes(x = fst, y = tajima)) +
  geom_point(aes(color = highlight_group), size = 1, alpha = 0.8) +
  scale_color_manual(values = c("None" = "gray80",
                                "CS top 0.1%" = "blue")) +
  labs(title = "Plot of Selection Statistics",
       x = "FST", y = "Tajima", color = "Top 0.1%") +
  theme_minimal()
dev.off()