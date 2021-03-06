library(data.table)
library(ggplot2)

files <- list.files("./", ".*xpclr.txt")

results <- NULL
for(file in files){
    tmp <- fread(file, header=FALSE, stringsAsFactors=FALSE)
    tmp <- as.data.frame(tmp)
    results <- rbind(results, tmp)  
}

colnames(results) <- c("Chromosome", "Grid", "nSNPs", "bp", "cM", "XPCLR", "maxS")

filter <- results$nSNPs > 0
filter <- filter & !(results$XPCLR == Inf)
results <- results[filter, ]

threshold <- quantile(results$XPCLR, 0.99,)

write.table(results, "XPCLR_allChrom_filtered.txt", row.names=FALSE, col.names=TRUE, sep="\t", quote=FALSE)

ggplot(results, aes(nSNPs)) +
    geom_histogram(bins=20) +
    facet_wrap(~Chromosome)
ggsave("numSNPs.png", width=5, height=5)

xpclrPlot <- ggplot() +
    geom_point(aes(bp, XPCLR), data=results) +
    geom_hline(yintercept=threshold) +
    facet_wrap(~Chromosome) +
    theme_classic()
ggsave("XPCLR_scores_byChrom.png", xpclrPlot, width=8, height=6)
