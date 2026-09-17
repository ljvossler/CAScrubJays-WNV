library(clusterProfiler)
library(dplyr)
library(org.Hs.eg.db)
library(tidyr)
library(msigdbr)

human_gene_vec <- read.table("/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/top_0.1perc_genesymbols.map")$V2
human_background <- read.table("/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/hs_sj_genesymbols.map", sep='\t')$V2
ego <- enrichGO(gene          = human_gene_vec,
                keyType       = "SYMBOL",
                universe      = human_background,
                OrgDb         = org.Hs.eg.db,
                ont           = "ALL",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01,
                qvalueCutoff  = 0.05)

genelist <- read.table("/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/scrubjays_master_genelist.revised.bed", header=1)
cs_scores <- genelist[c("gene_name", "avg_comp_score")]

symbol_map <- read.table("/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/hs_sj_genesymbols.map", sep='\t')
merged_df <- cs_scores %>% left_join(symbol_map, by = c("gene_name" = "V2"))
clean_df <- merged_df %>% drop_na()

labeled_cs_scores <- clean_df$avg_comp_score
names(labeled_cs_scores) <- clean_df$V1

sorted_cs_scores <- sort(labeled_cs_scores, decreasing=TRUE)
sorted_cs_scores <- sorted_cs_scores[!duplicated(names(sorted_cs_scores))]

ego3 <- gseGO(geneList     = sorted_cs_scores,
              OrgDb        = org.Hs.eg.db,
              ont          = "ALL",
              minGSSize    = 100,
              maxGSSize    = 100000,
              pvalueCutoff = 0.01,
              keyType       = "SYMBOL",
              scoreType    = "std")

H_t2g <- msigdbr(species = "Homo sapiens", collection = "H") |>
  dplyr::select(gs_name, gene_symbol)
em1 <- GSEA(sorted_cs_scores, TERM2GENE = H_t2g,pvalueCutoff = 0.05)

C5_t2g <- msigdbr(species = "Homo sapiens", collection = "C5") |>
  dplyr::select(gs_name, gene_symbol)
em2 <- GSEA(sorted_cs_scores, TERM2GENE = H_t2g,pvalueCutoff = 0.05)

C7_t2g <- msigdbr(species = "Homo sapiens", collection = "C7") |>
  dplyr::select(gs_name, gene_symbol)
em3 <- GSEA(sorted_cs_scores, TERM2GENE = H_t2g,pvalueCutoff = 0.05)

C3_t2g <- msigdbr(species = "Homo sapiens", collection = "C3") |>
  dplyr::select(gs_name, gene_symbol)
em4 <- GSEA(sorted_cs_scores, TERM2GENE = H_t2g,pvalueCutoff = 0.05)

