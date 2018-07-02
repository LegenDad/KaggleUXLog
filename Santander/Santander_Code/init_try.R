library(data.table)
library(knitr)

# library(plotly)
# library(caret)
# library(irlba)
# library(lattice)
# library(h2o)
# library(randomForest)
# library(foreach)
# library(doParallel)
# tr <- fread("../input/train.csv")
tr <- fread("../input/train.csv", header = T)
head(tr[,1:10])
range(tr$target)
par(mfrow=c(2,2))
hist(tr$target)
hist(log1p(tr$target))
boxplot(tr$target)
boxplot(log1p(tr$target))


tr <- fread("../input/train.csv", drop = "ID", header = T, showProgress = F)
te <- fread("../input/test.csv", drop = "ID", header = T, showProgress = F)
subm <- fread("../input/sample_submission.csv", showProgress = F)

set.seed(0)
target <- tr$target
tr$target <- NULL
summary(target)
var
zero_var <- names(tr)[tr[, lapply(.SD, var)] == 0]
zero_var2 <- names(tr)[tr[, lapply(.SD, sum)] == 0]
tr[, (zero_var) := NULL] 
dup <- names(tr)[duplicated(lapply(tr, c))]
sum(names(tr) %in% dup)

library(DT)
colnames(tr) %>% as.data.frame() %>% datatable()
lapply(iris, c)
duplicated(lapply(iris, c))
duplicated(iris)[140:143]
iris[140:143,]
duplicated(lapply(iris[140:143,], c))
