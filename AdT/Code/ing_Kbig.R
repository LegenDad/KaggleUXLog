rm(list=ls()); gc()
library(data.table)
adt <- fread("../input/train.csv")
adt <- adt[sample(.N, 30e6), ]
#adt <- adt[sample(.N, 20e6), ]
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
adt[, clicker := .N, by = list(ip, device, os)]
adt[, clicker_app := .N, by = list(ip, device, os, app)]
adt[, clicker_N := 1:.N, by = list(ip, device, os)]
adt[, clicker_app_N := 1:.N, by = list(ip, device, os, app)]
dim(adt)
colnames(adt)

adt$down_time <- adt$attributed_time - adt$click_time
#adt$down_time <- as.integer(adt$down_time)
range(adt$down_time)
adt$down_time <- ifelse(adt$down_time < 0, 0, adt$down_time)
adt$down_time <- adt$down_time / 3600
adt$down_time <- ifelse(0<adt$down_time & adt$down_time<1 , 1, adt$down_time)
adt$down_time <- round(adt$down_time)
head(table(adt$down_time))
dim(adt)
colnames(adt)

library(caret)
set.seed(777)
y <- adt$is_attributed
adt_index <- createDataPartition(y, p = 0.7, list = F)
tri <- createDataPartition(y[adt_index], p = 0.9, list = F)
cat_f <- c("app", "device", "os", "channel", "click_hour", "down_time")

library(lightgbm)
dt_y <- adt$down_time
adtr <- adt[, c("ip", "click_time", "attributed_time", "is_attributed") := NULL]

dttrain <- lgb.Dataset(data = as.matrix(adtr[adt_index,][tri,][,-"down_time"]), 
                       label = dt_y[adt_index][tri])
dtval <- lgb.Dataset(data = as.matrix(adtr[adt_index,][-tri,][,-"down_time"]), 
                     label = dt_y[adt_index][-tri])
dttest <- as.matrix(adtr[-adt_index,][,-"down_time"])
rm(adt); gc()
p <- list(objective = "regression", 
          boosting = "dart", 
          metric = "rmse", 
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
model_dt <- lgb.train(p, dttrain, valids = list(validation = dtval), 
                      nthread = 4, nrounds = 2000, verbose = 1, 
                      early_stopping_rounds = 200, eval_freq = 10)

model_dt$best_score
model_dt$best_iter
pred_dt <- predict(model_dt, dttest, n = model_dt$best_iter)
sqrt(mean((dt_y[-adt_index] - pred_dt)^2))
range(pred_dt)
pred_dt <- ifelse(pred_dt <0, 0, pred_dt)

adte <- adtr[-adt_index]
adte$down_time <- as.integer(pred_dt)
rm(dttrain, dtval, dttest); gc()

dtest <- as.matrix(adte)
dtrain <- lgb.Dataset(data = as.matrix(adtr[adt_index,][tri,]), 
                      label = y[adt_index][tri], 
                      categorical_feature = cat_f)
dval <- lgb.Dataset(data = as.matrix(adtr[adt_index,][-tri,]), 
                    label = y[adt_index][-tri], 
                    categorical_feature = cat_f)
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
                        nthread = 4, nrounds = 3000, verbose = 1, 
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
rm(dtest, dtrain, dval, adte, adtr); gc()
rm(y, adt_index, tri, dt_y, pred_dt, pred_lgbm); gc()

##### test data #####
adte <- fread("../input/test.csv")
adte[, click_hour := hour(click_time)]
adte[, click_weekd := wday(click_time)]
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
adte[, clicker_N := 1:.N, by = list(ip, device, os)]
adte[, clicker_app_N := 1:.N, by = list(ip, device, os, app)]
dim(adte)
colnames(adte)
adte <- adte[, -c("click_id", "ip", "click_time")]
adte <- as.matrix(adte)
pred_dt <- predict(model_dt, adte, n = model_dt$best_iter)
pred_dt <- ifelse(pred_dt <0, 0, pred_dt)
adte <- as.data.table(adte)
adte$down_time <- as.integer(pred_dt)

dim(adte)
colnames(adte)

adte <- as.matrix(adte)
realpred <- predict(model_lgbm, adte, n = model_lgbm$best_iter)
sub <- fread("../input/sample_submission.csv")
sub$is_attributed <- round(realpred, 6)
fwrite(sub, paste0("AdTbyH", round(model_lgbm$best_score, 6), ".csv"))


