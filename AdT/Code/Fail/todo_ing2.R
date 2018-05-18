rm(list=ls()); gc()
library(data.table)
library(lubridate)


#### 1st Saving Point #####
#saveRDS(adt, "adt_1st.RDS")
#saveRDS(tri, "tri_1st.RDS")
#saveRDS(teid, "teid.RDS")

##### 2nd Saving Point #####
#saveRDS(adt, "adt_2nd.RDS")
adt <- readRDS("adt_2nd.RDS")
tri <- readRDS("tri_1st.RDS")

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
saveRDS(adte, "adte.RDS")
rm(adte); gc()
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
#saveRDS(realpred, "realpred.RDS")
sub <- fread("../input/sample_submission.csv")
sub$is_attributed <- round(realpred, 6)
fwrite(sub, paste0("AdT_NP2Lst18_NPC_", round(model_lgbm$best_score, 6), ".csv"))
