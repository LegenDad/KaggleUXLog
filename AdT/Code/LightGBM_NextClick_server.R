rm(list=ls()); gc()
library(data.table)
adt <- fread("../input/train.csv", skip = 134903891, 
             col.names = c("ip", "app", "device", "os", "channel", 
                           "click_time", "attributed_time", "is_attributed"))
#adt <- fread("../input/train.csv")
#Select Train Sizes
#set.seed(777)
#adt <- adt[sample(.N, 50e6), ]
#adt <- adt[sample(.N, 10e6), ]
#adt <- adt[sample(.N, 30e6), ]
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


dim(adt)
colnames(adt)

#te_hourG1 <- c(4, 14, 13, 10, 9, 5)
#te_hourG2 <- c(15, 11, 6)
#adt$h_div <- ifelse(adt$click_hour %in% te_hourG1, 1, 
#                    ifelse(adt$click_hour %in% te_hourG2, 3, 2))
colnames(adt)
adt[, clicker_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
    by = .(ip, device, os)]
adt[, clicker_app_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
    by = .(ip, device, os, app)]
adt[, clicker_ch_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
    by = .(ip, device, os, app, channel)]
adt$clicker_Next <- ifelse(adt$clicker_Next < 0 , 0 , adt$clicker_Next)
adt$clicker_app_Next <- ifelse(adt$clicker_app_Next <0 , 0 , adt$clicker_app_Next)
adt$clicker_ch_Next <- ifelse(adt$clicker_ch_Next <0 , 0 , adt$clicker_ch_Next)

library(caret)
set.seed(777)
y <- adt$is_attributed
idx <- createDataPartition(y, p= 0.9, list = F)
#adt_index <- createDataPartition(y, p = 0.7, list = F)
#tri <- createDataPartition(y[adt_index], p = 0.9, list = F)
cat_f <- c("app", "device", "os", "channel", "click_hour")
adtr <- adt[, -c("ip", "click_time", "attributed_time", "is_attributed")]

library(lightgbm)
#dtrain <- lgb.Dataset(data = as.matrix(adtr[adt_index,][tri,]), 
#                      label = y[adt_index][tri],
#                      categorical_feature = cat_f)
#dval <- lgb.Dataset(data = as.matrix(adtr[adt_index,][-tri,]), 
#                    label = y[adt_index][-tri], 
#                    categorical_feature = cat_f)
#dtest <- as.matrix(adtr[-adt_index,])
dtrain <- lgb.Dataset(data = as.matrix(adtr[idx,]), 
                      label = y[idx],
                      categorical_feature = cat_f)
dval <- lgb.Dataset(data = as.matrix(adtr[-idx,]), 
                    label = y[-idx], 
                    categorical_feature = cat_f)

rm(adt); gc()
params = list(objective = "binary", 
              metric = "auc", 
              learning_rate= 0.1, 
              num_leaves= 7,
              max_depth= 3,  #change:4 to 3
              min_child_samples= 100,
              max_bin= 100,
              subsample= 0.7,
              subsample_freq= 1,
              colsample_bytree= 0.7, #change : 0.7 to 0.9
              min_child_weight= 0,
              min_split_gain= 0,
              scale_pos_weight=99.7 #change : 99.7 to 200
              )
model_lgbm <- lgb.train(params, dtrain, valids = list(validation = dval), 
                        nthread = 8, nrounds = 2000, verbose = 1, 
                        early_stopping_rounds = 200, eval_freq = 10)
model_lgbm$best_score
model_lgbm$best_iter

#pred_lgbm <- predict(model_lgbm, dtest, n = model_lgbm$best_iter)
#pred_lgbm2 <- ifelse(pred_lgbm>0.8, 1, 0)
#confusionMatrix(as.factor(pred_lgbm2), as.factor(y[-adt_index]))

#library(ROCR)
#pr <- prediction(pred_lgbm, y[-adt_index])
#prf <- performance(pr, "tpr", "fpr")
#plot(prf)
#auc <- performance(pr, "auc")
#(auc <- auc@y.values[[1]])
library(knitr)
kable(lgb.importance(model_lgbm))
lgb.plot.importance(lgb.importance(model_lgbm), top_n = 15)
library(pryr)
mem_used()
#rm(adt_index, dtest, dval, dtrain, adtr, tri, y); gc()
rm(dval, dtrain, adtr, idx, y); gc()

##### test data #####
adte <- fread("../input/test.csv")
adte <- setorder(adte, click_time)
adte[, click_hour := hour(adte$click_time)]
adte[, click_weekd := wday(adte$click_time)]
adte$click_time <- as.numeric(ymd_hms(adte$click_time))
adte[, ip_hw := .N, by = list(ip, click_hour, click_weekd)]
adte[, ip_app := .N, by = list(ip, app)]
adte[, ip_dev := .N, by = list(ip, device)]
adte[, ip_os := .N, by = list(ip, os)]
adte[, ip_ch := .N, by = list(ip, channel)]
adte[, ip_cnt := .N, by = ip]
adte[, app_cnt := .N, by = app]
adte[, dev_cnt := .N, by = device]
adte[, os_cnt := .N, by = os]
adte[, ch_cnt := .N, by = channel]
adte[, clicker := .N, by = list(ip, device, os)]
adte[, clicker_app := .N, by = list(ip, device, os, app)]
adte[, clicker_N := seq(.N), by = list(ip, device, os)]
adte[, clicker_app_N := seq(.N), by = list(ip, device, os, app)]
adte[, app_dev := .N, by = list(app, device)]
adte[, app_os := .N, by = list(app, os)]
adte[, app_ch := .N, by = list(app, channel)]
adte[, clicker_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
    by = .(ip, device, os)]
adte[, clicker_app_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
    by = .(ip, device, os, app)]
adte[, clicker_ch_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
    by = .(ip, device, os, app, channel)]
adte$clicker_Next <- ifelse(adte$clicker_Next < 0 , 0 , adte$clicker_Next)
adte$clicker_app_Next <- ifelse(adte$clicker_app_Next <0 , 0 , adte$clicker_app_Next)
adte$clicker_ch_Next <- ifelse(adte$clicker_ch_Next <0 , 0 , adte$clicker_ch_Next)
dim(adte)
colnames(adte)
#adte$h_div <- ifelse(adte$click_hour %in% te_hourG1, 1, 
#                    ifelse(adte$click_hour %in% te_hourG2, 3, 2))
colnames(adte)
adte <- adte[, -c("click_id", "ip", "click_time")]
colnames(adte)
adte <- as.matrix(adte)
realpred <- predict(model_lgbm, adte, n = model_lgbm$best_iter)
sub <- fread("../input/sample_submission.csv")
sub$is_attributed <- round(realpred, 6)
fwrite(sub, paste0("AdT_NC_", round(model_lgbm$best_score, 6), ".csv"))


##### END #####