rm(list=ls()); gc()
library(data.table)
adt <- fread("../input/train_sample.csv")
library(lubridate)
colnames(adt)

adt$click_time <- as.POSIXct(adt$click_time)
adt$attributed_time <- ifelse(adt$is_attributed ==0, "2017-12-31 23:59:59", adt$attributed_time)
adt$attributed_time <- as.POSIXct(adt$attributed_time)
head(adt)
head(adt[adt$is_attributed ==1 , ])
adt$down_time <- adt$attributed_time - adt$click_time
str(adt$down_time)
adt$click_hour <- hour(adt$click_time)
adt$click_weekd <- wday(adt$click_time)
adt$down_time <- as.integer(adt$down_time)
range(adt$down_time)
table(adt$down_time)
#46341 4521608
adt$down_time <- ifelse(adt$down_time > 4500000, 4500000, adt$down_time)
colnames(adt)
library(dplyr)
colnames(adt)
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
colnames(adt)[12:21] <- c("ip_hw", "ip_app", "ip_dev", "ip_os", "ip_ch", 
                          "ip_cnt", "app_cnt", "dev_cnt", "os_cnt", "ch_cnt")
colnames(adt)
#te_hourG1 <- c(4, 14, 13, 10, 9, 5)
#te_hourG2 <- c(15, 11, 6)
#adt$h_div <- ifelse(adt$click_hour %in% te_hourG1, 1, 
#                    ifelse(adt$click_hour %in% te_hourG2, 3, 2))
adt <- adt %>% add_count(ip, device, os)
adt <- adt %>% add_count(ip, device, os, app)
colnames(adt)[22:23] <- c("clicker", "clicker_app")

adt <- adt %>% group_by(ip, device, os) %>% mutate(clicker_N = 1:n())
adt <- adt %>% group_by(ip, device, os, app) %>% mutate(clicker_app_N = 1:n())
colnames(adt)
#head(adt[, 19:24])  
library(caret)
set.seed(777)
y <- adt$is_attributed
adt_index <- createDataPartition(y, p = 0.7, list = F)
tri <- createDataPartition(y[adt_index], p = 0.9, list = F)
cat_f <- c("app", "device", "os", "channel", "click_hour")
adt <- as.data.table(adt)
adtr <- adt %>% select(-ip, -click_time, -attributed_time, -is_attributed)

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

