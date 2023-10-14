library(doParallel)
library(data.table)
registerDoParallel(16)

df <- fread("/ru-auth/local/home/akhan01/GeneMAP/Pathogenicity_hg38.tsv")
genome <- fread("/ru-auth/local/home/akhan01/GeneMAP/Homo_sapiens.GRCh38.107_genome_clean.tsv")
genome <- genome[genome$gene_biotype == "gene_biotype protein_coding",]
df <- df[,-c("genome", "REF", "ALT", "protein_variant", "am_class", "uniprot_id")]
df$`#CHROM` <- gsub("chr", "", df$`#CHROM`)

Sys.time()
acc <- foreach (i = 1:nrow(genome)) %dopar% {
  d <- df[(df$`#CHROM` == genome[i]$V1) & (df$POS <= genome[i]$V5) & (df$POS >= genome[i]$V4),]
  score <- mean(d$am_pathogenicity)
  score
}
Sys.time()

genome$score <- unlist(acc)

write.xlsx(as_tibble(genome), "/ru-auth/local/home/akhan01/GeneMAP/20230924_PathogenicityScore.xlsx")


