master <- c()
# create node_list
## Prepare pairs
met_list <- unique(c(overlap$Met1, overlap$Met2))
acc <- c()
for (i in 1:(length(met_list)-1)) {
  add <- met_list[(i+1):length(met_list)]
  add <- cbind(rep(met_list[i] , length(add)), add)
  acc <- rbind(acc, add) }
acc <- as.data.frame(acc)
# simulate random networks by selecting random edges 
for (i in 1:20000) {
  test <- as_tibble(acc[sample(1:nrow(acc), size = nrow(overlap)),])
  freq <- table(c(test$V1, test$add))
  master <- c(master, unname(freq))
}

# Density plots
master <- as_tibble(master)
freq_act <- table(c(overlap$Met1, overlap$Met2))
freq_act <- tibble(name = names(freq_act), freq = freq_act)
freq_act$freq <- as.numeric(freq_act$freq)
freq_act1 <- table(freq_act$freq)
freq_act1 <- tibble(x = log10(as.numeric(names(freq_act1))), y = log10(freq_act1/sum(freq_act1)))

#m_act <- mean(freq_act)
# Plot distribution of the node degrees for the random networks
ggplot(master, aes(x=value)) + geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
                                              binwidth=1,
                                              colour="black", fill="white") + theme_bw() + xlab("k")

freq_act1$Actual <- c(rep("Yes", nrow(freq_act1)))
freq_sim <- table(master)
freq_sim <- tibble(x = log10(as.numeric(names(freq_sim))), y = log10(freq_sim/sum(freq_sim)))
freq_sim$Actual <- c(rep("No", nrow(freq_sim)))
freq_comb <- rbind(freq_sim, freq_act1)
col_vector <- list("black", "#E7B800")


# Plot power log plot
p <- ggplot(freq_comb, aes(x = x, y = as.numeric(y), color = Actual)) + geom_point() + theme_bw() + ylab("log(P/K)") +
  xlab("log(k)") + geom_smooth(method = "lm", alpha = .15, data = freq_comb[freq_comb$Actual == "Yes",], aes(x = x, y = as.numeric(y))) +
  scale_color_manual(values = col_vector) +  
  stat_poly_eq(data = freq_comb[freq_comb$Actual == "Yes",], use_label(c("R2", "R2.CI", "P", "method")))
