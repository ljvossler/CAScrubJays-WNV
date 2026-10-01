library(clusterProfiler)
library(dplyr)
library(org.Hs.eg.db)
library(tidyr)
library(msigdbr)

# Intial Pre/Post runs
human_gene_vec <- read.table("/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/top_0.1perc_genesymbols.map")$V2
human_background <- read.table("/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/hs_sj_genesymbols.map", sep='\t')$V2
# 11 enriched terms found at p threshold 0.05

# Post2015 set
human_gene_vec <- read.table("/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/post2015_top_0.1perc_genesymbols.map")$V2
human_background <- read.table("/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/hs_sj_genesymbols.map", sep='\t')$V2
# 6 enriched terms found at p threshold 0.05

ego <- enrichGO(gene          = human_gene_vec,
                keyType       = "SYMBOL",
                universe      = human_background,
                OrgDb         = org.Hs.eg.db,
                ont           = "BP",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.05,
                qvalueCutoff  = 0.05)

# Initial Pre/Post runs
genelist <- read.table("/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/scrubjays_master_genelist.revised.bed", header=1)

# Post2015 set
genelist <- read.table("/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/scrubjays_master_genelist.post2015.revised.bed", header=1)

cs_scores <- genelist[c("gene_name", "avg_comp_score")]

symbol_map <- read.table("/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/hs_sj_genesymbols.map", sep='\t')
merged_df <- cs_scores %>% left_join(symbol_map, by = c("gene_name" = "V2"))
clean_df <- merged_df %>% drop_na()

labeled_cs_scores <- clean_df$avg_comp_score
names(labeled_cs_scores) <- clean_df$V1

sorted_cs_scores <- sort(labeled_cs_scores, decreasing=TRUE)
sorted_cs_scores <- sorted_cs_scores[!duplicated(names(sorted_cs_scores))]

ego2 <- gseGO(geneList     = sorted_cs_scores,
              OrgDb        = org.Hs.eg.db,
              ont          = "ALL",
              minGSSize    = 100,
              maxGSSize    = 100000,
              pvalueCutoff = 0.05,
              keyType       = "SYMBOL",
              scoreType    = "std")

H_t2g <- msigdbr(species = "Homo sapiens", collection = "H") |>
  dplyr::select(gs_name, gene_symbol)
em_H <- GSEA(sorted_cs_scores, TERM2GENE = H_t2g,pvalueCutoff = 0.05)

C5_t2g <- msigdbr(species = "Homo sapiens", collection = "C5") |>
  dplyr::select(gs_name, gene_symbol)
em_C5 <- GSEA(sorted_cs_scores, TERM2GENE = C5_t2g,pvalueCutoff = 0.05)
# 1 enriched term found in initial Pre/Post set

C7_t2g <- msigdbr(species = "Homo sapiens", collection = "C7") |>
  dplyr::select(gs_name, gene_symbol)
em_C7 <- GSEA(sorted_cs_scores, TERM2GENE = C7_t2g,pvalueCutoff = 0.05)

C3_t2g <- msigdbr(species = "Homo sapiens", collection = "C3") |>
  dplyr::select(gs_name, gene_symbol)
em_C3 <- GSEA(sorted_cs_scores, TERM2GENE = C3_t2g,pvalueCutoff = 0.05)

