rm(list=ls()); gc()
library(data.table)
#adt <- fread("../input/train.csv", skip = 134903891, 
#             col.names = c("ip", "app", "device", "os", "channel", 
#                           "click_time", "attributed_time", "is_attributed"))
tr <- fread("../input/train.csv")
#Select Train Sizes
set.seed(777)
#tr <- tr[sample(.N, 50e6), ]
#tr <- tr[sample(.N, 30e6), ]
#tr <- tr[sample(.N, 10e6), ]
#adt <- adt[sample(.N, 30e6), ]
te <- fread("../input/test.csv")

tr <- tr[, -"attributed_time"]
te <- te[, -"click_id"]

tri <- 1:nrow(tr)

adt <- rbind(tr, te, fill = T)
rm(tr, te); gc()

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
adt[, clicker_prev := click_time - shift(click_time), by = .(ip, device, os)]
adt[is.na(clicker_prev), clicker_prev := 0]
adt[, clicker_app_prev := click_time - shift(click_time), by = .(ip, device, os, app)]
adt[is.na(clicker_app_prev), clicker_app_prev := 0]
adt[, clicker_ch_prev := click_time - shift(click_time), 
    by = .(ip, device, os, app, channel)]
adt[is.na(clicker_ch_prev), clicker_ch_prev := 0]

#adt[, clicker_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
#    by = .(ip, device, os)]
#adt[, clicker_app_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
#    by = .(ip, device, os, app)]
#adt[, clicker_ch_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
#    by = .(ip, device, os, app, channel)]
#adt$clicker_Next <- ifelse(adt$clicker_Next < 0 , 0 , adt$clicker_Next)
#adt$clicker_app_Next <- ifelse(adt$clicker_app_Next <0 , 0 , adt$clicker_app_Next)
#adt$clicker_ch_Next <- ifelse(adt$clicker_ch_Next <0 , 0 , adt$clicker_ch_Next)
adt[, clicker_Nmean := as.integer(mean(clicker_Next)), by = .(ip, device, os)]
adt[, clicker_app_Nmean := as.integer(mean(clicker_app_Next)), 
    by = .(ip, device, os,app)]
adt[, clicker_ch_Nmean := as.integer(mean(clicker_ch_Next)), 
    by = .(ip, device, os, app, channel)]
adt[, clicker_Pmean := as.integer(mean(clicker_prev)), by = .(ip, device, os)]
adt[, clicker_app_Pmean := as.integer(mean(clicker_app_prev)), 
    by = .(ip, device, os,app)]
adt[, clicker_ch_Pmean := as.integer(mean(clicker_ch_prev)), 
    by = .(ip, device, os, app, channel)]

adt[, clicker_Nmed := as.integer(median(clicker_Next)), by = .(ip, device, os)]
adt[, clicker_app_Nmed := as.integer(median(clicker_app_Next)), 
    by = .(ip, device, os,app)]
adt[, clicker_ch_Nmed := as.integer(median(clicker_ch_Next)), 
    by = .(ip, device, os, app, channel)]
adt[, clicker_Pmed := as.integer(median(clicker_prev)), by = .(ip, device, os)]
adt[, clicker_app_Pmed := as.integer(median(clicker_app_prev)), 
    by = .(ip, device, os,app)]
adt[, clicker_ch_Pmed := as.integer(median(clicker_ch_prev)), 
    by = .(ip, device, os, app, channel)]
colnames(adt)


library(caret)
set.seed(777)
y <- adt[tri]$is_attributed
idx <- createDataPartition(y, p= 0.85, list = F)


#adt_index <- createDataPartition(y, p = 0.7, list = F)
#tri <- createDataPartition(y[adt_index], p = 0.9, list = F)
cat_f <- c("app", "device", "os", "channel", "click_hour")
adtr <- adt[, -c("ip", "click_time", "is_attributed")]
library(pryr)
mem_used()
rm(adt); gc()
mem_used()
saveRDS(adte, "adte.RDS")
saveRDS(adtr, "adtr.RDS")
saveRDS(cat_f, "cat_f.RDS")
saveRDS(idx, "idx.RDS")
saveRDS(tri, "tri.RDS")
saveRDS(y, "y.RDS")


########### todo buntu  #######
library(data.table)
library(lubridate)
library(caret)
library(pryr)
library(lightgbm)

#adte <- readRDS("adte.RDS")
adtr <- readRDS("adtr.RDS")
cat_f <- readRDS("cat_f.RDS")
idx <- readRDS("idx.RDS")
tri <- readRDS("tri.RDS")
y <- readRDS("y.RDS")


#dtrain <- lgb.Dataset(data = as.matrix(adtr[adt_index,][tri,]), 
#                      label = y[adt_index][tri],
#                      categorical_feature = cat_f)
#dval <- lgb.Dataset(data = as.matrix(adtr[adt_index,][-tri,]), 
#                    label = y[adt_index][-tri], 
#                    categorical_feature = cat_f)
#dtest <- as.matrix(adtr[-adt_index,])
adte <- as.matrix(adtr[-tri])
dtrain <- lgb.Dataset(data = as.matrix(adtr[tri][idx,]), 
                      label = y[idx],
                      categorical_feature = cat_f)
dval <- lgb.Dataset(data = as.matrix(adtr[tri][-idx,]), 
                    label = y[-idx], 
                    categorical_feature = cat_f)
saveRDS(adte, "adte.RDS")
rm(adtr, adte); gc()
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
                        nthread = 8, nrounds = 1200, verbose = 1,
                        early_stopping_rounds = 120, eval_freq = 10)
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
rm(dval, dtrain, idx, y); gc()
mem_used()
adte <- readRDS("adte.RDS")
realpred <- predict(model_lgbm, adte, n = model_lgbm$best_iter)
sub <- fread("../input/sample_submission.csv")
sub$is_attributed <- round(realpred, 6)
fwrite(sub, paste0("AdT_T_NPC_", round(model_lgbm$best_score, 6), ".csv"))

