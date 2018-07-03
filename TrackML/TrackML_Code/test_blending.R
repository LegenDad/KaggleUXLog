library(data.table)
files <- list.files("../SubM")
sub1 <- fread(paste0("../SubM/",files[1]))
sub2 <- fread(paste0("../SubM/",files[2]))
sub3 <- fread(paste0("../SubM/",files[3]))
# sub4 <- fread(paste0("../SubM/",files[4]))
# sub5 <- fread(paste0("../SubM/",files[5]))

# newsub <- cbind(sub1, sub2[,2], sub3[,2], sub4[,2], sub5[,2])
newsub <- cbind(sub1, sub2[,3], sub3[,3])
setnames(newsub, c("event_id", "hit_id",  1:3))
head(newsub)
newsub[, track_id := as.integer(rowMeans(newsub[,3:5]))]
newsub <- newsub[, c("event_id", "hit_id", "track_id")]
fwrite(newsub, "../SubM/bagging1.csv")
