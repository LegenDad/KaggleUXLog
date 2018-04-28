rm(list=ls()); gc()
library(data.table)
adt <- fread("../input/train_sample.csv")
adt$click_time <- as.POSIXct(adt$click_time)
range(adt$click_time)
adt$attributed_time <- ifelse(adt$is_attributed == 0, "2017-11-06 00:00:00", 
                              adt$attributed_time)
adt$attributed_time <- as.POSIXct(adt$attributed_time)
library(lubridate)
adt[, click_hour := hour(click_time)]
adt[, click_weekd := wday(click_time)]
adt[, ip_hw := .N, by = list(ip, click_hour, click_weekd)]
adt[, ip_app := .N, by = list(ip, app)]
adt[, ip_dev := .N, by = list(ip, device)]
adt[, ip_os := .N, by = list(ip, os)]
adt[, ip_ch := .N, by = list(ip, channel)]
adt[, ip_cnt := .N, by = ip]
adt[, app_cnt := .N, by = app]
adt[, dev_cnt := .N, by = device]
adt[, os_cnt := .N, by = os]
adt[, ch_cnt := .N, by = channel]
dim(adt)
colnames(adt)
adt[, clicker := .N, by = list(ip, device, os)]
adt[, clicker_app := .N, by = list(ip, device, os, app)]
adt[, clicker_N := 1:.N, by = list(ip, device, os)]
adt[, clicker_app_N := 1:.N, by = list(ip, device, os, app)]
dim(adt)
colnames(adt)
adt$down_time <- adt$attributed_time - adt$click_time
adt$down_time <- as.integer(adt$down_time)
range(adt$down_time)
adt$down_time <- ifelse(adt$down_time < 0, 0, adt$down_time)
colnames(adt)

library(caret)
set.seed(777)
y <- adt$is_attributed
adt_index <- createDataPartition(y, p = 0.7, list = F)
tri <- createDataPartition(y[adt_index], p = 0.9, list = F)
cat_f <- c("app", "device", "os", "channel", "click_hour")
adtr <- adt[, c("ip", "click_time", "attributed_time", "is_attributed") := NULL]

library(lightgbm)
dtrain <- lgb.Dataset(data = as.matrix(adtr[adt_index,][tri,]), 
                      label = y[adt_index][tri], 
                      categorical_feature = cat_f)
dval <- lgb.Dataset(data = as.matrix(adtr[adt_index,][-tri,]), 
                    label = y[adt_index][-tri], 
                    categorical_feature = cat_f)
dtest <- as.matrix(adtr[-adt_index,])
params = list(objective = "binary", 
              metric = "auc", 
              learning_rate= 0.1, 
              num_leaves= 7,
              max_depth= 4,
              min_child_samples= 100,
              max_bin= 100,
              subsample= 0.7,
              subsample_freq= 1,
              colsample_bytree= 0.7,
              min_child_weight= 0,
              min_split_gain= 0,
              scale_pos_weight=99.7)
model_lgbm <- lgb.train(params, dtrain, valids = list(validation = dval), 
                        nthread = 8, nrounds = 3000, verbose = 1, 
                        early_stopping_rounds = 300, eval_freq = 10)
model_lgbm$best_score
model_lgbm$best_iter

pred_lgbm <- predict(model_lgbm, dtest, n = model_lgbm$best_iter)
pred_lgbm2 <- ifelse(pred_lgbm>0.5, 1, 0)
confusionMatrix(as.factor(pred_lgbm2), as.factor(y[-adt_index]))

library(ROCR)
pr <- prediction(pred_lgbm, y[-adt_index])
prf <- performance(pr, "tpr", "fpr")
plot(prf)
auc <- performance(pr, "auc")
(auc <- auc@y.values[[1]])
library(knitr)
kable(lgb.importance(model_lgbm))
lgb.plot.importance(lgb.importance(model_lgbm), top_n = 15)
library(pryr)
mem_used()




