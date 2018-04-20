rm(list=ls()); gc()
#adt <- adt[sample(.N, 30e6), ]
library(data.table)
adt <- fread("../input/train.csv")
adt <- adt[sample(.N, 10e6), ]
library(lubridate)
adt$click_hour <- hour(adt$click_time)
adt$click_weekd <- wday(adt$click_time)
library(dplyr)
colnames(adt)
str(adt)
adt <- adt %>% add_count(ip, click_hour, click_weekd) 
adt <- adt %>% add_count(ip, app)
adt <- adt %>% add_count(ip, device)
adt <- adt %>% add_count(ip, os)
adt <- adt %>% add_count(ip, channel)
adt <- adt %>% add_count(ip)
adt <- adt %>% add_count(app)
adt <- adt %>% add_count(device)
adt <- adt %>% add_count(os)
adt <- adt %>% add_count(channel)
head(adt)
colnames(adt)[11:20] <- c("ip_hw", "ip_app", "ip_dev", "ip_os", "ip_ch", 
                          "ip_cnt", "app_cnt", "dev_cnt", "os_cnt", "ch_cnt")
colnames(adt)
#install.packages("xgboost")
library(xgboost)
library(caret)
colnames(adt)
colnames(adt[,-c(1,6:8)])
set.seed(777)
adt_index <- createDataPartition(adt$is_attributed, p=0.7, list = F)
#y <- adt[adt_index,]$is_attributed
y <- adt$is_attributed
adtr <- adt %>% select(-ip, -click_time, -attributed_time, -is_attributed)
colnames(adtr)
dtest <- xgb.DMatrix(data = data.matrix(adtr[-adt_index,]))
tri <- createDataPartition(y[adt_index], p = 0.9, list = F)
dtrain <- xgb.DMatrix(data = data.matrix(adtr[adt_index,][tri,]), 
                      label = y[adt_index][tri])
dval <- xgb.DMatrix(data = data.matrix(adtr[adt_index,][-tri,]), 
                    label = y[adt_index][-tri])
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
predXG2 <- ifelse(predXG > 0.85,1,0)
sum(predXG2)
library(e1071)
confusionMatrix(as.factor(predXG2), as.factor(adt[-adt_index,]$is_attributed))
#install.packages("ROCR")
library(ROCR)
#pr <- prediction(predXG, adt[-adt_index,]$is_attributed)
pr <- prediction(predXG, y[-adt_index])
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)

auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc
rm(auc, pr, prf, predXG2, dtest, dval, dtrain, adtr, adt); gc()
##### test data _ NOT RUN in Local #####
adte <- fread("../input/test.csv")
adte <- adte %>% select(-click_id)
adte$click_hour <- hour(adte$click_time)
adte$click_weekd <- wday(adte$click_time)
adte <- adte %>% add_count(ip, click_hour, click_weekd) 
adte <- adte %>% add_count(ip, app)
adte <- adte %>% add_count(ip, device)
adte <- adte %>% add_count(ip, os)
adte <- adte %>% add_count(ip, channel)
adte <- adte %>% add_count(ip)
adte <- adte %>% add_count(app)
adte <- adte %>% add_count(device)
adte <- adte %>% add_count(os)
adte <- adte %>% add_count(channel)
head(adte)
colnames(adte)[9:18] <- c("ip_hw", "ip_app", "ip_dev", "ip_os", "ip_ch", 
                          "ip_cnt", "app_cnt", "dev_cnt", "os_cnt", "ch_cnt")
adte <- adte %>% select(-ip, -click_time)
adtest <- xgb.DMatrix(data = data.matrix(adte))
realpred <- predict(m_xgb, adtest)
sub <- fread("../input/sample_submission.csv")
sub$is_attributed <- realpred
fwrite(sub, paste0("adt", m_xgb$best_score, ".csv"))


#####