library(data.table)
library(tidyverse)
library(ggplot2)
library(ggsignif)
library(rstatix)
library(ggpubr)
library(egg)
library(cowplot)
library(ggrepel)


## QQplot
k <- read_tsv("Comb_Sig_ForQQPlot_Whole_Blood.tsv")
met_library <- read.xlsx("LibraryMetabolismNew.xlsx")
k$met <- k$gene.x %in% met_library$ENSG
nn = nrow(k)
xx =  -log10((1:nn)/(nn+1))
k$xx <- xx
col_vector <- c("black", "#E7B800")
k <- filter(k, met == TRUE)
p <- ggplot(k, aes(x = xx, y = -sort(log10(pvalue.y)))) + geom_point(color = "gray", size = .75) +
  theme_classic() + geom_abline(color = "darkgray") + geom_hline(yintercept = -log10(0.05/nn), show.legend = "BF", linetype=2, color = "orange") + 
  ylab("-log10(Observed pval)") + xlab("-log10(Expected pval)") 

