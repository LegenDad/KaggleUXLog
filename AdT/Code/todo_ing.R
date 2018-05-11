rm(list=ls()); gc()
library(data.table)
library(lubridate)
##### 1st Saving Point #####
#saveRDS(adt, "adt_1st.RDS")
#saveRDS(tri, "tri_1st.RDS")
##### 2nd Saving Point #####
#saveRDS(adt, "adt_2nd.RDS")
adt <- readRDS("adt_2nd.RDS")

colnames(adt)
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

##### 3rd Saving Point #####
saveRDS(adt, "adt_3rd.RDS")

adt[, clicker_Nmed := median(clicker_Next), by = .(ip, device, os)]
adt[, clicker_app_Nmed := median(clicker_app_Next), by = .(ip, device, os,app)]
adt[, clicker_ch_Nmed := median(clicker_ch_Next), by = .(ip, device, os, app, channel)]
adt[, clicker_Pmed := median(clicker_prev), by = .(ip, device, os)]
adt[, clicker_app_Pmed := median(clicker_app_prev), by = .(ip, device, os,app)]
adt[, clicker_ch_Pmed := median(clicker_ch_prev), by = .(ip, device, os, app, channel)]
colnames(adt)

##### 4th Saving Point #####
saveRDS(adt, "adt_4th.RDS")

tri <- readRDS("tri_1st.RDS")
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

library(lightgbm)
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
saveRDS(realpred, "realpred.RDS")
#sub <- fread("../input/sample_submission.csv")
#sub$is_attributed <- round(realpred, 6)
#fwrite(sub, paste0("AdT_T_NPC_", round(model_lgbm$best_score, 6), ".csv"))

