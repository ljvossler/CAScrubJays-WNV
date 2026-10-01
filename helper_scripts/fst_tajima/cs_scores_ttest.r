library(dplyr)


cat("Parsing command-line arguments...\n")
# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
genelist <- args[1] # should be master genelist file with headers labeled


gene_table <- read.table(genelist, header = 1)

vip_genes <- gene_table %>%
  filter(has_wnv_vip == 1)

nonvip_genes <- gene_table %>%
  filter(has_wnv_vip != 1)

t.test(vip_genes$avg_comp_score, y = nonvip_genes$avg_comp_score)  

#Welch Two Sample t-test for Post-2015 GeneSet

#data:  vip_genes$avg_comp_score and nonvip_genes$avg_comp_score
#t = -1.3061, df = 208.67, p-value = 0.1929
#alternative hypothesis: true difference in means is not equal to 0
#95 percent confidence interval:
#  -0.32608938  0.06619003
#sample estimates:
#  mean of x   mean of y 
#-0.11025225  0.01969743 

#================================================

#Welch Two Sample t-test for Binary Pre/Post GeneSet

#data:  vip_genes$avg_comp_score and nonvip_genes$avg_comp_score
#t = -1.2667, df = 208.68, p-value = 0.2067
#alternative hypothesis: true difference in means is not equal to 0
#95 percent confidence interval:
#  -0.32716949  0.07119485
#sample estimates:
#  mean of x   mean of y 
#-0.10138936  0.02659796 






