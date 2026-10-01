# Basic example of plotting gone results across multiple populations in a time series
library(dplyr)
library(ggplot2)

bin_info <- read.csv('gone_bin_info.csv')

num_gens <- 300 # Number of generations
colors <- colorRampPalette(c("blue", "red"))(16)
df_lst <- c()


for(i in seq_len(nrow(bin_info))) {
  df_tmp <- read.csv(bin_info[i,'fpath'], sep = '\t')
  timespan <- bin_info[i,'year_span']
  df_tmp <- df_tmp %>% mutate(time=paste0('bin', i, '_', timespan)) # Add time info
  df_lst[[i]] <- df_tmp
}

df_full <- bind_rows(df_lst) # Combine data comparing Ne estimates between time-separated populations
df_full <- df_full %>%
  filter(Generation <=num_gens) # Apply whatever data filters you want. GONE is only good up to 200 generations

colors <- colorRampPalette(c("blue", "red"))(16)
names(colors) <- unique(df_full$time)

df_full %>%
  ggplot(aes(x=Generation, y=Ne_diploids, color = time)) +
  geom_step() +
  scale_color_manual(values = colors, name='Time') #+coord_cartesian(ylim = c(0,20))
