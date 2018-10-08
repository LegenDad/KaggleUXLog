library(data.table)
files <- list.files("../SubM")
sub1 <- fread(paste0("../SubM/",files[1]))
sub2 <- fread(paste0("../SubM/",files[2]))
newsub <- cbind(sub1, sub2[,2])
head(newsub)
setnames(newsub, c("fullVisitorId", 1:2))
head(newsub)
newsub[, PredictedLogRevenue := rowMeans(newsub[,-1])]
newsub <- newsub[, c("fullVisitorId", "PredictedLogRevenue")]
head(newsub)
fwrite(newsub, "../SubM/bagging2ND.csv")
