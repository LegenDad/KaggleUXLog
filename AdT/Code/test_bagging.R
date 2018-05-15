library(data.table)
files <- list.files("../SubM")
sub1 <- fread(paste0("../SubM/",files[1]))
sub2 <- fread(paste0("../SubM/",files[2]))
sub3 <- fread(paste0("../SubM/",files[3]))
sub4 <- fread(paste0("../SubM/",files[4]))
sub5 <- fread(paste0("../SubM/",files[5]))

newsub <- cbind(sub1, sub2[,2], sub3[,2], sub4[,2], sub5[,2])
setnames(newsub, c("click_id", 1:5))
head(newsub)
newsub[, is_attributed := rowMeans(newsub[,-1])]
newsub <- newsub[, c("click_id", "is_attributed")]
fwrite(newsub, "bagging2.csv")








#submissions = [pd.read_csv(path) for path in downloaded_submission_paths]
#submissions_as_rank = [submission.rank() for submission in submissions]
#ensemble = np.mean(submissions_as_rank, axis=0)
