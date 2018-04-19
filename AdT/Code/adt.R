rm(list=ls()); gc()
library(data.table)
adt <- fread("../input/train_sample.csv")
library(lubridate)
adt$click_hour <- hour(adt$click_time)
adt$click_weekd <- wday(adt$click_time)
library(dplyr)
colnames(adt)
str(adt)
adt <- adt %>% add_count(ip, click_hour, click_weekd) 
adt <- adt %>% add_count(ip, click_hour, app)
adt <- adt %>% add_count(ip, click_hour, device)
adt <- adt %>% add_count(ip, click_hour, os)
adt <- adt %>% add_count(ip, click_hour, channel)
adt <- adt %>% add_count(ip)
head(adt)
colnames(adt)[11:16] <- c("ip_hw", "ip_app", "ip_dev", "ip_os", "ip_ch", 
                          "ip_cnt")
colnames(adt)
#install.packages("xgboost")
library(xgboost)
library(caret)
colnames(adt)
colnames(adt[,-c(1,6:8)])
set.seed(777)
adt_index <- createDataPartition(adt$is_attributed, p=0.7, list = F)
y <- adt[adt_index,]$is_attributed

adtr <- adt %>% select(-ip, -click_time, -attributed_time, -is_attributed)
#adtr <- adt[,-c(1,6:8)]
colnames(adtr)
str(adtr)
dtest <- xgb.DMatrix(data = data.matrix(adtr[-adt_index,]))
tri <- createDataPartition(y, p = 0.9, list = F)
dtrain <- xgb.DMatrix(data = data.matrix(adtr[adt_index,][tri,]), label = y[tri])
dval <- xgb.DMatrix(data = data.matrix(adtr[adt_index,][-tri,]), label = y[-tri])
cols <- colnames(adtr)

p <- list(objective = "binary:logistic",
          booster = "gbtree",
          eval_metric = "auc",
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
          nrounds = 3000)
m_xgb <- xgb.train(p, dtrain, p$nrounds, list(val = dval), print_every_n = 50, 
                   early_stopping_rounds = 200)

(imp <- xgb.importance(cols, model=m_xgb))
xgb.plot.importance(imp, top_n = 10)
predXG <- predict(m_xgb,dtest)
predXG <- ifelse(predXG > 0.5,1,0)
sum(predXG)
library(e1071)
confusionMatrix(as.factor(predXG), as.factor(adt[-adt_index,]$is_attributed))
#install.packages("ROCR")
library(ROCR)
pr <- prediction(predXG, adt[-adt_index,]$is_attributed)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)

auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc
