rm(list=ls()); gc()
library(data.table)
adt <- fread("../input/train_sample.csv")
#adt <- adt[sample(.N, 10e6), ]
library(lubridate)
adt <- setorder(adt, click_time)
adt[, click_hour := hour(adt$click_time)]
adt[, click_weekd := wday(adt$click_time)]
adt$click_time <- as.numeric(ymd_hms(adt$click_time))
head(adt)
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
adt[, clicker := .N, by = list(ip, device, os)]
adt[, clicker_app := .N, by = list(ip, device, os, app)]
adt[, clicker_N := seq(.N), by = list(ip, device, os)]
adt[, clicker_app_N := seq(.N), by = list(ip, device, os, app)]
adt[, app_dev := .N, by = list(app, device)]
adt[, app_os := .N, by = list(app, os)]
adt[, app_ch := .N, by = list(app, channel)]
adt[, clicker_Next := c(click_time[-1], NA), by = .(ip, device, os)]
adt[, clicker_Next := clicker_Next - click_time, by = .(ip, device, os)]
adt[is.na(clicker_Next), clicker_Next := 0]
adt[, clicker_app_Next := c(click_time[-1], NA), by = .(ip, device, os, app)]
adt[, clicker_app_Next := clicker_app_Next - click_time, by = .(ip, device, os, app)]
adt[is.na(clicker_app_Next), clicker_app_Next := 0]
adt[, clicker_ch_Next := c(click_time[-1], NA), by = .(ip, device, os, app, channel)]
adt[, clicker_ch_Next := clicker_ch_Next - click_time, 
    by = .(ip, device, os,app,channel)]
adt[is.na(clicker_ch_Next), clicker_ch_Next := 0]

#adt[, clicker_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
#    by = .(ip, device, os)]
#adt[, clicker_app_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
#    by = .(ip, device, os, app)]
#adt[, clicker_ch_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
#    by = .(ip, device, os, app, channel)]
#adt$clicker_Next <- ifelse(adt$clicker_Next < 0 , 0 , adt$clicker_Next)
#adt$clicker_app_Next <- ifelse(adt$clicker_app_Next <0 , 0 , adt$clicker_app_Next)
#adt$clicker_ch_Next <- ifelse(adt$clicker_ch_Next <0 , 0 , adt$clicker_ch_Next)
#fav_appG1 <- c(3, 12, 2)
#fav_appG2 <- c(9, 15, 18, 14)
#adt$fav_app_div <- ifelse(adt$click_hour %in% fav_appG1, 1, 
#                    ifelse(adt$click_hour %in% fav_appG2, 2, 3))
head(adt)
dim(adt)
colnames(adt)

#te_hourG1 <- c(4, 14, 13, 10, 9, 5)
#te_hourG2 <- c(15, 11, 6)
#adt$h_div <- ifelse(adt$click_hour %in% te_hourG1, 1, 
#                    ifelse(adt$click_hour %in% te_hourG2, 3, 2))
#head(adt[, 19:24])  

library(caret)
set.seed(777)
y <- adt$is_attributed
adt_index <- createDataPartition(y, p = 0.7, list = F)
tri <- createDataPartition(y[adt_index], p = 0.9, list = F)
cat_f <- c("app", "device", "os", "channel", "click_hour")
adt <- as.data.table(adt)
adtr <- adt[, -c("ip", "click_time", "attributed_time", "is_attributed")]

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
              max_depth= 3,
              min_child_samples= 100,
              max_bin= 100,
              subsample= 0.7,
              subsample_freq= 1,
              colsample_bytree= 0.7,
              min_child_weight= 0,
              min_split_gain= 0,
              scale_pos_weight=99.7)
model_lgbm <- lgb.train(params, dtrain, valids = list(validation = dval), 
                        nthread = 8, nrounds = 3000, verbose = 1, boosting = "gbdt",
                        early_stopping_rounds = 300, eval_freq = 10)
#str(model_lgbm)
#model_lgbm$record_evals
#model_lgbm$record_evals[["validation"]]
#model_lgbm$record_evals[["validation"]][["auc"]][["eval"]]
model_lgbm$best_score
model_lgbm$best_iter

pred_lgbm <- predict(model_lgbm, dtest, n = model_lgbm$best_iter)
pred_lgbm2 <- ifelse(pred_lgbm>0.8, 1, 0)
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

