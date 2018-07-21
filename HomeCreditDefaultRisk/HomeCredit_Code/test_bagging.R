library(data.table)
files <- list.files("../SubM")
sub1 <- fread(paste0("../SubM/",files[1]))
sub2 <- fread(paste0("../SubM/",files[2]))
# sub3 <- fread(paste0("../SubM/",files[3]))
# sub4 <- fread(paste0("../SubM/",files[4]))
# sub5 <- fread(paste0("../SubM/",files[5]))

newsub <- cbind(sub1, sub2[,2])
setnames(newsub, c("SK_ID_CURR", 1:2))
head(newsub)
newsub[, TARGET := rowMeans(newsub[,-1])]
newsub <- newsub[, c("SK_ID_CURR", "TARGET")]
fwrite(newsub, "../SubM/enbagging.csv")
