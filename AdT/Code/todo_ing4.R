rm(list=ls()); gc()
library(data.table)
library(lubridate)

#### 1st Saving Point #####
# saveRDS(adt, "fadt_1st.RDS")
# saveRDS(tri, "ftri_1st.RDS")


##### 2nd Saving Point #####
# saveRDS(adt, "fadt_2nd.RDS")

##### 3rd Saving Point #####
# saveRDS(adt, "fadt_3rd.RDS")
adt <- readRDS("50adt_3rd.RDS")

tri <- readRDS("50tri_1st.RDS")
library(caret)
set.seed(777)
y <- adt[tri]$is_attributed
idx <- createDataPartition(y, p= 0.9, list = F)
# cat_f <- c("app", "device", "os", "channel", "click_hour")
# cat_f <- c("app", "device", "os", "channel", "click_hour", "clicker_app_Nmean", "clicker_app_Nmed")
# cat_f <- c("app", "device", "os", "channel", "click_hour", 
#            "ip_hw", "ip_app", "ip_dev", "ip_os", "ip_ch")
# cat_f <- c("app", "device", "os", "channel", "click_hour", 
#            "app_cnt", "dev_cnt", "os_cnt", "ch_cnt")
cat_f <- c("app", "device", "os", "channel", "click_hour", 
           "clicker", "clicker_app", "app_dev", "app_os", "app_ch")
adtr <- adt[, -c("ip", "click_time", "is_attributed")]
library(pryr)
mem_used()
rm(adt); gc()
mem_used()

library(lightgbm)
adte <- as.matrix(adtr[-tri])
# saveRDS(adte, "fadte.RDS")
# rm(adte); gc()
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
# adte <- readRDS("fadte.RDS")
adte <- readRDS("50adte.RDS")
realpred <- predict(model_lgbm, adte, n = model_lgbm$best_iter)
sub <- fread("../input/sample_submission.csv")
sub$is_attributed <- round(realpred, 6)
fwrite(sub, paste0("AdT_NP2LstCF_NPC_", round(model_lgbm$best_score, 6), ".csv"))
