library(MendelianRandomization)
metabolite <- fread("GCST90200327_buildGRCh38.tsv.gz")
metabolite <- metabolite[metabolite$chromosome == 5,]
genome <- readRDS(dir_genome)

## replace gene
genome <- genome[genome$gene_name == "GENE_NAME",]

metabolite <- metabolite[(metabolite$base_pair_location > genome$V4-1e+6) & (metabolite$base_pair_location < genome$V5+1e+6),]
eqtls <- read.xlsx(dir)
eqtls <- eqtls %>%
  separate(variant_id, into = c("Chromosome", "Position", "Reference", "Effect", "Build"), sep = "_")
colnames(metabolite)[2:4] <- c("Position", "Effect", "Reference")
combine <- merge(eqtls, metabolite, by = c("Position", "Effect", "Reference"))
MBEObject <- mr_mbe(mr_input(bx = combine$slope, bxse = combine$slope_se,
                             by = combine$beta, byse = combine$standard_error))
EggerObject <- mr_egger(mr_input(bx = combine$slope, bxse = combine$slope_se,
                                 by = combine$beta, byse = combine$standard_error))
