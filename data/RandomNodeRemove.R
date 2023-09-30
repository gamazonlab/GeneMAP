# error free tolerance
random_remove <- function(x) {
  a <- c()
  for (k in 1:10) {
    rem <- node_list[sample(1:nrow(node_list), k), 2]
    routes_tidy %>%  
      activate(nodes) %>% 
      filter(!(label %in% unlist(rem))) -> new
    new %>%
      mutate(k = graph_mean_dist()) -> new
    new %>% activate(nodes) %>% as.data.frame() -> new
    a <- c(a, unique(new$k))
  }
  return(a)
}

freq_act <- table(c(overlap$Met1, overlap$Met2))

node_list <- df_community(overlap)[[2]]
cl <- makeCluster(4)
routes_tidy <- df_community(overlap)[[3]]
clusterExport(cl=cl, varlist = c("node_list", "routes_tidy"))
clusterEvalQ(cl,library(tidyverse))
clusterEvalQ(cl,library(tidygraph))


Sys.time()
a <- parLapply(1:500, random_remove, cl = cl)
Sys.time()
b <- c()

for (k in 1:10) {
  rem <- names(freq_act[1:k])
  routes_tidy %>%  
    activate(nodes) %>% 
    filter(!(label %in% unlist(rem))) -> new
  new %>%
    mutate(k = graph_mean_dist()) -> new
  new %>% activate(nodes) %>% as.data.frame() -> new
  b <- c(b, unique(new$k))
}




col_vector <- list("black", "#E7B800")
a_int <- unlist(a)

pl <- c()
for (i in 1:10) {
  pl <- c(pl, mean(a_int[seq(i,length(a_int), 10)]))
}

combine_error <- as_tibble(cbind(k = c(1:10), a = unlist(pl), gr = rep("a", 10)))
combine_error <- rbind(combine_error, cbind(k = c(1:10), a = b, gr = rep("b", 10)))
combine_error$k <- unlist(combine_error$k) 
combine_error$a <- unlist(combine_error$a) 

p <- ggplot(combine_error, aes(color = gr, x = as.numeric(unlist(k)), y = as.numeric(unlist(a)))) + 
  geom_point(size = 4) + theme_bw() + xlab("Number of nodes removed") + 
  ylab("Average distance between the nodes") + scale_color_manual(values = col_vector)
