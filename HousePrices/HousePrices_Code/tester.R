library(data.table)
files <- list.files("../SubM")
sub1 <- fread(paste0("../SubM/",files[1]))
sub2 <- fread(paste0("../SubM/",files[2]))
newsub <- cbind(sub1, sub2[,2])
setnames(newsub, c("id", 1:2))
head(newsub)
newsub[, SalePrice := rowMeans(newsub[,-1])]
newsub <- newsub[, c("id", "SalePrice")]
fwrite(newsub, "../SubM/bagging8TH.csv")
