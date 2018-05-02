rm(list=ls()); gc()
library(data.table)
adt <- fread("../input/train_sample.csv")
library(lubridate)
adt[, click_hour := hour(adt$click_time)]
adt[, click_weekd := wday(adt$click_time)]
colnames(adt)

adt[, v1 := .N, by = ip]
adt[, v2 := .N, by = app]
adt[, v3 := .N, by = device]
adt[, v4 := .N, by = os]
adt[, v5 := .N, by = channel]
adt[, v6 := .N, by = click_hour]

adt[, v7 := .N, by = list(ip, app)]
adt[, v8 := .N, by = list(device, ip)]
adt[, v9 := .N, by = list(ip, os)]
adt[, v10 := .N, by = list(ip, channel)]
adt[, v11 := .N, by = list(ip, click_hour)]
adt[, v12 := .N, by = list(app, device)]
adt[, v13 := .N, by = list(app, os)]
adt[, v14 := .N, by = list(app, channel)]
adt[, v15 := .N, by = list(app, click_hour)]
adt[, v16 := .N, by = list(device, os)]
adt[, v17 := .N, by = list(device, channel)]
adt[, v18 := .N, by = list(device, click_hour)]
adt[, v19 := .N, by = list(os, channel)]
adt[, v20 := .N, by = list(os, click_hour)]
adt[, v21 := .N, by = list(channel, click_hour)]

adt[, v22 := .N, by = list(ip, app, device)]
adt[, v23 := .N, by = list(ip, app, os)]
adt[, v24 := .N, by = list(ip, app, channel)]
adt[, v25 := .N, by = list(ip, app, click_hour)]
adt[, v26 := .N, by = list(ip, device, os)]
adt[, v27 := .N, by = list(ip, device, channel)]
adt[, v28 := .N, by = list(ip, device, click_hour)]
adt[, v29 := .N, by = list(ip, os, channel)]
adt[, v30 := .N, by = list(ip, os, click_hour)]
adt[, v31 := .N, by = list(ip, channel, click_hour)]
adt[, v32 := .N, by = list(app, device, os)]
adt[, v33 := .N, by = list(app, device, channel)]
adt[, v34 := .N, by = list(app, device, click_hour)]
adt[, v35 := .N, by = list(device, os, channel)]
adt[, v36 := .N, by = list(device, os, click_hour)]
adt[, v37 := .N, by = list(os, channel, click_hour)]

adt[, v38 := .N, by = list(ip, app, device, os)]
adt[, v39 := .N, by = list(ip, app, device, channel)]
adt[, v40 := .N, by = list(ip, app, device, click_hour)]
adt[, v41 := .N, by = list(ip, device, os, channel)]
adt[, v42 := .N, by = list(ip, device, os, click_hour)]
adt[, v43 := .N, by = list(ip, os, channel, click_hour)]
adt[, v44 := .N, by = list(app, device, os, channel)]
adt[, v45 := .N, by = list(app, device, os, click_hour)]
adt[, v46 := .N, by = list(app, os, channel, click_hour)]
adt[, v47 := .N, by = list(device, os, channel, click_hour)]

adt[, v48 := .N, by = list(ip, app, device, os, channel)]
adt[, v49 := .N, by = list(ip, app, device, os, click_hour)]
adt[, v50 := .N, by = list(ip, app, device, channel, click_hour)]
adt[, v51 := .N, by = list(ip, app, os, channel, click_hour)]
adt[, v52 := .N, by = list(ip, device, os, channel, click_hour)]
adt[, v53 := .N, by = list(app, device, os, channel, click_hour)]

adt[, v54 := .N, by = list(ip, app, device, os, channel, click_hour)]

adt[, v101 := seq(.N), by = ip]
adt[, v102 := seq(.N), by = app]
adt[, v103 := seq(.N), by = device]
adt[, v104 := seq(.N), by = os]
adt[, v105 := seq(.N), by = channel]
adt[, v106 := seq(.N), by = click_hour]

adt[, v107 := seq(.N), by = list(ip, app)]
adt[, v108 := seq(.N), by = list(device, ip)]
adt[, v109 := seq(.N), by = list(ip, os)]
adt[, v110 := seq(.N), by = list(ip, channel)]
adt[, v111 := seq(.N), by = list(ip, click_hour)]
adt[, v112 := seq(.N), by = list(app, device)]
adt[, v113 := seq(.N), by = list(app, os)]
adt[, v114 := seq(.N), by = list(app, channel)]
adt[, v115 := seq(.N), by = list(app, click_hour)]
adt[, v116 := seq(.N), by = list(device, os)]
adt[, v117 := seq(.N), by = list(device, channel)]
adt[, v118 := seq(.N), by = list(device, click_hour)]
adt[, v119 := seq(.N), by = list(os, channel)]
adt[, v120 := seq(.N), by = list(os, click_hour)]
adt[, v121 := seq(.N), by = list(channel, click_hour)]

adt[, v122 := seq(.N), by = list(ip, app, device)]
adt[, v123 := seq(.N), by = list(ip, app, os)]
adt[, v124 := seq(.N), by = list(ip, app, channel)]
adt[, v125 := seq(.N), by = list(ip, app, click_hour)]
adt[, v126 := seq(.N), by = list(ip, device, os)]
adt[, v127 := seq(.N), by = list(ip, device, channel)]
adt[, v128 := seq(.N), by = list(ip, device, click_hour)]
adt[, v129 := seq(.N), by = list(ip, os, channel)]
adt[, v130 := seq(.N), by = list(ip, os, click_hour)]
adt[, v131 := seq(.N), by = list(ip, channel, click_hour)]
adt[, v132 := seq(.N), by = list(app, device, os)]
adt[, v133 := seq(.N), by = list(app, device, channel)]
adt[, v134 := seq(.N), by = list(app, device, click_hour)]
adt[, v135 := seq(.N), by = list(device, os, channel)]
adt[, v136 := seq(.N), by = list(device, os, click_hour)]
adt[, v137 := seq(.N), by = list(os, channel, click_hour)]

adt[, v138 := seq(.N), by = list(ip, app, device, os)]
adt[, v139 := seq(.N), by = list(ip, app, device, channel)]
adt[, v140 := seq(.N), by = list(ip, app, device, click_hour)]
adt[, v141 := seq(.N), by = list(ip, device, os, channel)]
adt[, v142 := seq(.N), by = list(ip, device, os, click_hour)]
adt[, v143 := seq(.N), by = list(ip, os, channel, click_hour)]
adt[, v144 := seq(.N), by = list(app, device, os, channel)]
adt[, v145 := seq(.N), by = list(app, device, os, click_hour)]
adt[, v146 := seq(.N), by = list(app, os, channel, click_hour)]
adt[, v147 := seq(.N), by = list(device, os, channel, click_hour)]

adt[, v148 := seq(.N), by = list(ip, app, device, os, channel)]
adt[, v149 := seq(.N), by = list(ip, app, device, os, click_hour)]
adt[, v150 := seq(.N), by = list(ip, app, device, channel, click_hour)]
adt[, v151 := seq(.N), by = list(ip, app, os, channel, click_hour)]
adt[, v152 := seq(.N), by = list(ip, device, os, channel, click_hour)]
adt[, v153 := seq(.N), by = list(app, device, os, channel, click_hour)]

adt[, v154 := seq(.N), by = list(ip, app, device, os, channel, click_hour)]



#sort(table(adt$app), decreasing = T)
#fav_appG1 <- c(3, 12, 2)
#fav_appG2 <- c(9, 15, 18, 14)
#adt$fav_app_div <- ifelse(adt$click_hour %in% fav_appG1, 1, 
#                    ifelse(adt$click_hour %in% fav_appG2, 2, 3))
#adt[, spec := .N, by = list(ip, device, os, app, channel)]
#adt[, spec_N := seq(.N), by = list(ip, device, os, app, channel)]
#adt[, ip_ch_N := seq(.N), by = list(ip, channel)]
#adt[, h_clicker := .N, by = list(click_hour, ip, device, os)]
#adt[, h_clicker_app := .N, by = list(click_hour, ip, device, os, app)]
#adt[, h_clicker_N := seq(.N), by = list(click_hour, ip, device, os)]
#adt[, h_clicker_app_N := seq(.N), by = list(click_hour, ip, device, os, app)]


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

