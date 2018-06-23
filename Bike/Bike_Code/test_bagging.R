library(data.table)
files <- list.files("../SubM")
sub1 <- fread(paste0("../SubM/",files[2]))
sub2 <- fread(paste0("../SubM/",files[4]))
# sub3 <- fread(paste0("../SubM/",files[3]))
# sub4 <- fread(paste0("../SubM/",files[4]))
# sub5 <- fread(paste0("../SubM/",files[5]))

newsub <- cbind(sub1, sub2[,2])
setnames(newsub, c("datetime", 1:2))
head(newsub)
newsub[, count := rowMeans(newsub[,-1])]
newsub <- newsub[, c("datetime", "count")]
fwrite(newsub, "../SubM/bagging2.csv")




# xgboost + lgbm = bagging
# bagging + script = bagging2




#submissions = [pd.read_csv(path) for path in downloaded_submission_paths]
#submissions_as_rank = [submission.rank() for submission in submissions]
#ensemble = np.mean(submissions_as_rank, axis=0)