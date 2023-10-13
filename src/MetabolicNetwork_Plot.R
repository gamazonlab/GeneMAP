library(tidyverse)
library(qvalue)
library(doParallel)
library(optparse)
library(stats)

cl <- makeCluster(12)
option_list = list(
  make_option("--index", action="store", default=NA, type='character',
              help="Path to dataframe of gwas and eQTL summary statistics [required]"),
  make_option("--source", action="store", default=NA, type='character',
              help="Path to dataframe of gwas and eQTL summary statistics [required]")
)

opt = parse_args(OptionParser(option_list=option_list))
index = opt$index
source = opt$source

print("Code 2023/08/09")
df <- read_tsv(paste("/ru-auth/local/home/akhan01/GeneMAP/Input_MetabolicNetwork/20230809_", source, "_Network_Whole_Blood.tsv", sep = ""))
print(source)
moi <- read.table(paste("/ru-auth/local/home/akhan01/GeneMAP/Input_MetabolicNetwork/20230809_Pairs/", index, ".txt", sep = ""))
max_n <- 1718101

my_fun <- function(input) {
    curr1$new_beta <- curr1$b.F[sample(1:nrow(curr1))] 
    comb <- inner_join(curr1, curr2, by = "gene")
    unlist(unname(cor.test(as.numeric(comb$new_beta), as.numeric(comb$b.F.y), method = "pearson")$estimate)) }
  
B_arr <- c(100, 1000, 10000, 100000, max_n)
  
clusterEvalQ(cl,library(tidyverse))
add <- c()
cp <- c()
print("Start analysis")
print(Sys.time())

for (j in 1:nrow(moi)) {
    print(paste("Current:", j, "Out of", nrow(moi)))
    print(Sys.time())
    curr1 <- df[df$met == moi[j,1],]
    curr2 <- df[df$met == moi[j,2],]
    clusterExport(cl=cl, varlist = c("curr1", "curr2"))
    comb <- inner_join(curr1, curr2, by = "gene")
    curr_parameters <- cor.test(as.numeric(comb$b.F.x), as.numeric(comb$b.F.y), method = "pearson") 
    curr_parameters <- unname(unlist(curr_parameters$estimate))
    k = 1
    pval <- 0
    B <- 1
    while ((k <= length(B_arr)) & (pval < 1/B)) {
      B <- B_arr[k]
      print(paste("Bval_Current:", B, sep = " "))
      k = k + 1
      out1 <- unlist(parLapply(cl, c(1:B), my_fun))
      pval <- min(length(out1[curr_parameters < out1])/B, length(out1[curr_parameters > out1])/B)
    }
    if (pval == 0) {
      to_add <- 1/B
    } else { to_add <- pval }
    add <- c(add, to_add)
    cp <- c(cp, curr_parameters)
    print(paste("B:", B))
    print(paste("Pval:", to_add)) }
  
# Output
print("Form and Save file")
output <- cbind(rep(moi[1], (length(moi)-1)), moi[2:length(moi)], cp, add)
colnames(output) <- c("Met1", "Met2", "PC", "pval")
write.table(x = as_tibble(output), file = paste("/ru-auth/local/home/GeneMAP/PheWAS_Processed/Results_Permutation_Metabolic_Network_20230809/", source, "/", index, ".txt", sep = ""))
