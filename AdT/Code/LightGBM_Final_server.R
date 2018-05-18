rm(list=ls()); gc()
library(data.table)
library(lubridate)

tr <- fread("../input/train.csv")
te <- fread("../input/test.csv")
# te <- fread("../input/test_supplement.csv")
tr <- setorder(tr, click_time)
tr <- tr[, -"attributed_time"]
tri <- 1:nrow(tr)
te <- te[, -"click_id"]

adt <- rbind(tr, te, fill = T)
rm(tr, te); gc()

adt[, click_hour := hour(adt$click_time)]
adt[, click_weekd := wday(adt$click_time)]
adt$click_time <- as.numeric(ymd_hms(adt$click_time))
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
adt[, c("clicker", "clicker_N") := .(.N, seq(.N)), by = .(ip, device, os)]
adt[, c("clicker_app", "clicker_app_N") := .(.N, seq(.N)), by = .(ip, device, os, app)]
adt[, c("app_dev", "app_dev_N") := .(.N, seq(.N)), by = .(app, device)]
adt[, c("app_os", "app_os_N") := .(.N, seq(.N)), by = .(app, os)]
adt[, c("app_ch", "app_ch_N") := .(.N, seq(.N)),  by = .(app, channel)]

adt[, clicker_Next := c(click_time[-1], NA), by = .(ip, device, os)]
adt[, clicker_Next := clicker_Next - click_time, by = .(ip, device, os)]
adt[is.na(clicker_Next), clicker_Next := 0]
adt[, clicker_app_Next := c(click_time[-1], NA), by = .(ip, device, os, app)]
adt[, clicker_app_Next := clicker_app_Next - click_time, by = .(ip, device, os, app)]
adt[is.na(clicker_app_Next), clicker_app_Next := 0]
adt[, clicker_ch_Next := c(click_time[-1], NA), by = .(ip, device, os, app, channel)]
adt[, clicker_ch_Next := clicker_ch_Next - click_time, by = .(ip, device, os,app,channel)]
adt[is.na(clicker_ch_Next), clicker_ch_Next := 0]
adt[, clicker_prev := click_time - shift(click_time), by = .(ip, device, os)]
adt[is.na(clicker_prev), clicker_prev := 0]
adt[, clicker_app_prev := click_time - shift(click_time), by = .(ip, device, os, app)]
adt[is.na(clicker_app_prev), clicker_app_prev := 0]
adt[, clicker_ch_prev := click_time - shift(click_time), by = .(ip, device, os, app, channel)]
adt[is.na(clicker_ch_prev), clicker_ch_prev := 0]

adt[, clicker_Next2 := shift(click_time, 2, type = "lead", fill = 0) - click_time, 
    by = .(ip, device, os)]
adt[clicker_Next2 < 0 , clicker_Next2 := 0]
adt[, clicker_app_Next2 := shift(click_time, 2, type = "lead", fill = 0) - click_time,
    by = .(ip, device, os, app)]
adt[clicker_app_Next2 < 0 , clicker_app_Next2 := 0]
adt[, clicker_ch_Next2 := shift(click_time, 2, type = "lead", fill = 0) - click_time,
    by = .(ip, device, os, app, channel)]
adt[clicker_ch_Next2 < 0 , clicker_ch_Next2 := 0]

adt[, clicker_prev2 := click_time - shift(click_time, 2), by = .(ip, device, os)]
adt[is.na(clicker_prev2), clicker_prev2 := 0]
adt[, clicker_app_prev2 := click_time - shift(click_time, 2), by = 
      .(ip, device, os, app)]
adt[is.na(clicker_app_prev2), clicker_app_prev2 := 0]
adt[, clicker_ch_prev2 := click_time - shift(click_time, 2), 
    by = .(ip, device, os, app, channel)]
adt[is.na(clicker_ch_prev2), clicker_ch_prev2 := 0]

adt[, clicker_Last := max(click_time), by = .(ip, device, os)]
adt[, clicker_app_Last := max(click_time), by = .(ip, device, os, app)]
adt[, clicker_ch_Last := max(click_time), by = .(ip, device, os, app, channel)]

adt[, clicker_Nmean := as.integer(mean(clicker_Next)), by = .(ip, device, os)]
adt[, clicker_app_Nmean := as.integer(mean(clicker_app_Next)), by = .(ip, device, os,app)]
adt[, clicker_ch_Nmean := as.integer(mean(clicker_ch_Next)), by = .(ip, device, os, app, channel)]
adt[, clicker_Pmean := as.integer(mean(clicker_prev)), by = .(ip, device, os)]
adt[, clicker_app_Pmean := as.integer(mean(clicker_app_prev)), by = .(ip, device, os,app)]
adt[, clicker_ch_Pmean := as.integer(mean(clicker_ch_prev)), by = .(ip, device, os, app, channel)]

adt[, clicker_Nmed := as.integer(median(clicker_Next)), by = .(ip, device, os)]
adt[, clicker_app_Nmed := as.integer(median(clicker_app_Next)), by = .(ip, device, os,app)]
adt[, clicker_ch_Nmed := as.integer(median(clicker_ch_Next)), by = .(ip, device, os, app, channel)]
adt[, clicker_Pmed := as.integer(median(clicker_prev)), by = .(ip, device, os)]
adt[, clicker_app_Pmed := as.integer(median(clicker_app_prev)), by = .(ip, device, os,app)]
adt[, clicker_ch_Pmed := as.integer(median(clicker_ch_prev)), by = .(ip, device, os, app, channel)]
colnames(adt)

library(caret)
set.seed(777)
y <- adt[tri]$is_attributed
idx <- createDataPartition(y, p= 0.9, list = F)
cat_f <- c("app", "device", "os", "channel", "click_hour")
adtr <- adt[, -c("ip", "click_time", "is_attributed")]

library(pryr)
mem_used()
rm(adt); gc()
mem_used()

library(lightgbm)
adte <- as.matrix(adtr[-tri])
dtrain <- lgb.Dataset(data = as.matrix(adtr[tri][idx,]), 
                      label = y[idx],
                      categorical_feature = cat_f)
dval <- lgb.Dataset(data = as.matrix(adtr[tri][-idx,]), 
                    label = y[-idx], 
                    categorical_feature = cat_f)
rm(adtr); gc()
mem_used()

params = list(objective = "binary", 
              metric = "auc", 
              boosting = "gbdt",
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
                        nthread = 8, nrounds = 1500, verbose = 1,
                        early_stopping_rounds = 120, eval_freq = 10)
model_lgbm$best_score
model_lgbm$best_iter

library(knitr)
kable(lgb.importance(model_lgbm))
library(pryr)
mem_used()
rm(dval, dtrain, idx, y); gc()
mem_used()
realpred <- predict(model_lgbm, adte, n = model_lgbm$best_iter)
sub <- fread("../input/sample_submission.csv")
sub$is_attributed <- round(realpred, 6)
fwrite(sub, paste0("AdT_NP2Lstf_NPC_", round(model_lgbm$best_score, 6), ".csv"))
