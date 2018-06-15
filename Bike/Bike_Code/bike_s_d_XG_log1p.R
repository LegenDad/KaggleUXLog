btr <- read.csv("../Data/Bike/train.csv", stringsAsFactors = F)
bte <- read.csv("../Data/Bike/test.csv", stringsAsFactors = F)
dim(btr); dim(bte)
sum(is.na(btr)); sum(is.na(bte))
colnames(btr)
colnames(bte)
str(btr); str(bte)

btr$datetime <- as.POSIXct(btr$datetime)
btr$year <- format(btr$datetime, "%Y")
btr$month <- format(btr$datetime, "%m")
btr$day <- format(btr$datetime, "%d")
btr$hour <- format(btr$datetime, "%H")
btr$weekday <- format(btr$datetime, "%A")
btr$weeknum <- format(btr$datetime, "%U")

bte$datetime <- as.POSIXct(bte$datetime)
bte$year <- format(bte$datetime, "%Y")
bte$month <- format(bte$datetime, "%m")
bte$day <- format(bte$datetime, "%d")
bte$hour <- format(bte$datetime, "%H")
bte$weekday <- format(bte$datetime, "%A")
bte$weeknum <- format(bte$datetime, "%U")
library(lubridate)

btr$year <- as.integer(btr$year)
btr$month <- as.integer(btr$month)
btr$day <- as.integer(btr$day)
btr$hour <- as.integer(btr$hour)
btr$weekday <- wday(btr$datetime)
btr$weeknum <- as.integer(btr$weeknum)
btr$count <- log1p(btr$count)
str(btr)

bte$year <- as.integer(bte$year)
bte$month <- as.integer(bte$month)
bte$day <- as.integer(bte$day)
bte$hour <- as.integer(bte$hour)
bte$weekday <- wday(bte$datetime)
bte$weeknum <- as.integer(bte$weeknum)
str(bte)

library(caret)
library(dplyr)
colnames(btr)
btr_index <- sample(nrow(btr)*0.7)
#y <- btr$count
#y[-btr_index]
#y[btr_index]
y <- btr[btr_index,]$count
btr2 <- btr %>% select(-count, -datetime, -registered, -casual)
bte2 <- bte %>% select(-datetime)
colnames(btr2)
colnames(bte2)
#install.packages("xgboost")
library(xgboost)

val_index <- sample(nrow(btr2[btr_index,])*0.9)
length(y[val_index]) + length(y[-val_index])
dtest <- xgb.DMatrix(data = data.matrix(btr2[-btr_index,]))
dtrain <- xgb.DMatrix(data = data.matrix(btr2[btr_index,][val_index,]), 
                      label = y[val_index])
dval <- xgb.DMatrix(data = data.matrix(btr2[btr_index,][-val_index,]), 
                    label = y[-val_index])
args(xgb.train)

m_xgb <- xgb.train(data = dtrain, nround = 150, max_depth = 5,
                   eta = 0.1, subsample = 0.9)

xgb.importance(feature_names = colnames(dtrain), m_xgb) %>% xgb.plot.importance()
predXG <- predict(m_xgb, dtest)
fooo <- btr[-btr_index,]$count
sqrt(mean((fooo - predXG)^2))
class(fooo)
class(predXG)

p <- list(booster = "gbtree",
          nthread = 8,
          eta = 0.07,
          max_depth = 7,
          min_child_weight = 148,
          gamma = 167.6125,
          subsample = 0.6928,
          colsample_bytree = 0.9108,
          colsample_bylevel = 0.9857,
          alpha = 43.2165,
          lambda = 74.6334,
          scale_pos_weight = 103,
          nrounds = 2000)
m_xgb2 <- xgb.train(p, dtrain, p$nrounds, list(val = dval), print_every_n = 50, 
                    early_stopping_rounds = 200)

predXG2 <- predict(m_xgb2, dtest)
sqrt(mean((fooo - predXG2)^2))

realtest <- xgb.DMatrix(data = data.matrix(bte2))

preT1 <- predict(m_xgb, realtest)
preT1 <- expm1(preT1)
range(preT1)

preT2 <- predict(m_xgb2, realtest)
preT2 <- expm1(preT2)
range(preT2)
sub1 = read.csv("../Data/Bike/sampleSubmission.csv")
sub1$count <- preT1
sub2 = read.csv("..//Data/Bike/sampleSubmission.csv")
# sub2$count <- ifelse(preT2 <0, 0, preT2)
head(sub1); head(sub2)

write.csv(sub1, file="../Data/Bike/submission1.csv", row.names=F)
write.csv(sub2, file="../Data/Bike/submission2.csv", row.names=F)
