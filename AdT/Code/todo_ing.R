rm(list=ls()); gc()
library(data.table)
library(lubridate)
library(caret)
library(pryr)

##### 1st Saving Point #####
#saveRDS(adt, "adt_1st.RDS")
#saveRDS(tri, "tri_1st.RDS")
#saveRDS(teid, "teid.RDS")
##### 2nd Saving Point #####
#saveRDS(adt, "adt_2nd.RDS")
##### 3rd Saving Point #####
#saveRDS(adt, "adt_3rd.RDS")

adt <- readRDS("adt_3rd.RDS")
tri <- readRDS("tri_1st.RDS")

set.seed(0)
y <- adt[tri]$is_attributed
idx <- createDataPartition(y, p= 0.9, list = F)
cat_f <- c("app", "device", "os", "channel", "click_hour")
adtr <- adt[, -c("ip", "click_time", "is_attributed")]
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
saveRDS(adte, "adte.RDS")
rm(adtr, adte); gc()
mem_used()

params = list(objective = "binary", 
              metric = "auc", 
              boosting = "gbdt",
              learning_rate= 0.1, 
              num_leaves= 127,
              max_depth= -1,  #change:4 to 3
              min_child_samples= 100,
              max_bin= 1023,
              subsample= 0.9,
              subsample_freq= 1,
              colsample_bytree= 0.7, #change : 0.7 to 0.9
              min_child_weight= 30,
              min_split_gain= 0.0001, 
              scale_pos_weight=1 #change : 99.7 to 200
)

model_lgbm <- lgb.train(params, dtrain, valids = list(validation = dval), 
                        nthread = 8, nrounds = 1500, verbose = 1,
                        early_stopping_rounds = 120, eval_freq = 10)
model_lgbm$best_score
model_lgbm$best_iter

library(knitr)
kable(lgb.importance(model_lgbm))
lgb.plot.importance(lgb.importance(model_lgbm), top_n = 15)
mem_used()
rm(dval, dtrain, idx, y); gc()
mem_used()
adte <- readRDS("adte.RDS")
realpred <- predict(model_lgbm, adte, n = model_lgbm$best_iter)
saveRDS(realpred, "realpred.RDS")
length(realpred)
teid <- readRDS("teid.RDS")
tes <- data.table(click_id = teid, realpred = realpred)
cir <- fread("../input/test_click_id_relation.csv")
head(cir)
setkey(tes, click_id)
setkey(cir, click_id.testsup)
result <- tes[cir]
head(result)
result <- setorder(result, click_id.test)

sub <- fread("../input/sample_submission.csv")
sub$is_attributed <- round(result$realpred, 6)
head(sub)
fwrite(sub, paste0("AdT_T_TS_", round(model_lgbm$best_score, 6), ".csv"))
