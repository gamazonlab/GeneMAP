## Community analysis function
df_community <- function(df, y = 0.001) {
  set.seed(45)
  df$pval <- as.numeric(unlist(df$pval))
  df$PC <- abs(as.numeric(unlist(df$PC)))
  node_list <- unique(c(df[,1], df[,2]))
  nodes <- tibble(id = c(1:length(node_list)), label = node_list)
  nodes$id <- as.numeric(nodes$id)
  df <- df[order(df$PC),]
  per_route <- df %>%  
    group_by(Met1, Met2) %>%
    ungroup()
  colnames(per_route)[1:2] <- c("source", "destination")
  edges <- per_route %>% 
    left_join(nodes, by = c("source" = "label")) %>% 
    rename(from = id)
  edges <- edges %>% 
    left_join(nodes, by = c("destination" = "label")) %>% 
    rename(to = id)
  routes_tidy <- tbl_graph(nodes = nodes, edges = edges,  directed = FALSE)
  routes_tidy %>% 
    mutate(community=as.factor(group_louvain(weights = NULL))) -> routes_tidy
  node_list <-
    routes_tidy %>%
    activate(nodes) %>%
    data.frame()
  node_list <-
    routes_tidy %>%
    activate(nodes) %>%
    data.frame()
  p <- ggraph(routes_tidy, layout = 'kk') + 
    geom_node_point(aes(color=community), size = 4.5) +
    geom_edge_link(alpha = 0.5, width = y)  +
    theme_graph() + theme(legend.position='left')
  return(list(p, node_list, routes_tidy)) 
}