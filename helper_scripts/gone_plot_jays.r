# Basic example of plotting gone results across multiple populations in a time series
library(dplyr)
library(ggplot2)

cat("Parsing command-line arguments...\n")
# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
out_path_pre <- args[1] # Usually the earlier ("pre") population
out_path_post <- args[2] # Usually the later ("post") population
num_gens <- args[3] # Number of generations
color_pre <- args[4]
color_post <- args[5]


df_pre <- read.csv(out_path_pre, sep = '\t')
df_postbin1 <- read.csv(out_path_post_bin1, sep = '\t')
df_postbin2 <- read.csv(out_path_post_bin2, sep = '\t')

df_pre <- df_pre %>% mutate(time='pre') # Add time info
df_postbin1 <- df_postbin1 %>% mutate(time='postbin1')
df_postbin2 <- df_postbin2 %>% mutate(time='postbin2')

df_full <- rbind(df_pre, df_postbin1, df_postbin2) # Combine data comparing Ne estimates between time-separated populations
df_full <- df_full %>%
  filter(Generation <=num_gens) # Apply whatever data filters you want. GONE is only good up to 200 generations

color_codes <- c(pre='black', postbin1='blue', postbin2='red')

df_full %>%
  ggplot(aes(x=Generation, y=Ne_diploids, color = time)) +
  geom_step() +
  scale_color_manual(values = color_codes, name='Time') #+coord_cartesian(ylim = c(0,20))

df_post %>%
  ggplot(aes(x=Generation, y=Ne_diploids, color = time)) +
  geom_step() +
  scale_color_manual(values = color_codes, name='Time') #+coord_cartesian(ylim = c(0,20))

df_pre %>%
  ggplot(aes(x=Generation, y=Ne_diploids, color = time)) +
  geom_step() +
  scale_color_manual(values = color_codes, name='Time') #+coord_cartesian(ylim = c(0,20))
