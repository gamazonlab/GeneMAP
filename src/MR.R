library(MendelianRandomization)
choline <- fread("GCST90200327_buildGRCh38.tsv.gz")
choline <- choline[choline$chromosome == 5,]
genome <- readRDS(dir_genome)
genome <- genome[genome$gene_name == "SLC25A48",]
choline <- choline[(choline$base_pair_location > genome$V4-1e+6) & (choline$base_pair_location < genome$V5+1e+6),]
eqtls <- read.xlsx(dir)
eqtls <- eqtls %>%
  separate(variant_id, into = c("Chromosome", "Position", "Reference", "Effect", "Build"), sep = "_")
colnames(choline)[2:4] <- c("Position", "Effect", "Reference")
combine <- merge(eqtls, choline, by = c("Position", "Effect", "Reference"))
MBEObject <- mr_mbe(mr_input(bx = combine$slope, bxse = combine$slope_se,
                             by = combine$beta, byse = combine$standard_error))
EggerObject <- mr_egger(mr_input(bx = combine$slope, bxse = combine$slope_se,
                                 by = combine$beta, byse = combine$standard_error))
