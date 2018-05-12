rm(list=ls()); gc()
library(data.table)
adt <- fread("../input/train.csv")

#Select Train Sizes
set.seed(777)
adt <- adt[sample(.N, 50e6), ]
#adt <- adt[sample(.N, 20e6), ]
#adt <- adt[sample(.N, 30e6), ]

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

dim(adt)
colnames(adt)

#te_hourG1 <- c(4, 14, 13, 10, 9, 5)
#te_hourG2 <- c(15, 11, 6)
#adt$h_div <- ifelse(adt$click_hour %in% te_hourG1, 1, 
#                    ifelse(adt$click_hour %in% te_hourG2, 3, 2))
colnames(adt)

library(caret)
set.seed(777)
y <- adt$is_attributed
adt_index <- createDataPartition(y, p = 0.7, list = F)
tri <- createDataPartition(y[adt_index], p = 0.9, list = F)
cat_f <- c("app", "device", "os", "channel", "click_hour")
adtr <- adt[, -c("ip", "click_time", "attributed_time", "is_attributed")]

library(lightgbm)
dtrain <- lgb.Dataset(data = as.matrix(adtr[adt_index,][tri,]), 
                      label = y[adt_index][tri],
                      categorical_feature = cat_f)
dval <- lgb.Dataset(data = as.matrix(adtr[adt_index,][-tri,]), 
                    label = y[adt_index][-tri], 
                    categorical_feature = cat_f)
dtest <- as.matrix(adtr[-adt_index,])
rm(adt); gc()
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
                        nthread = 8, nrounds = 2000, verbose = 1, 
                        early_stopping_rounds = 200, eval_freq = 10)
model_lgbm$best_score
model_lgbm$best_iter

pred_lgbm <- predict(model_lgbm, dtest, n = model_lgbm$best_iter)
#pred_lgbm2 <- ifelse(pred_lgbm>0.8, 1, 0)
#confusionMatrix(as.factor(pred_lgbm2), as.factor(y[-adt_index]))

library(ROCR)
pr <- prediction(pred_lgbm, y[-adt_index])
#prf <- performance(pr, "tpr", "fpr")
#plot(prf)
auc <- performance(pr, "auc")
(auc <- auc@y.values[[1]])
library(knitr)
kable(lgb.importance(model_lgbm))
lgb.plot.importance(lgb.importance(model_lgbm), top_n = 15)
library(pryr)
mem_used()
rm(adt_index, dtest, dval, dtrain, adtr, tri, y); gc()

##### test data #####
adte <- fread("../input/test.csv")
adte[, click_hour := hour(adte$click_time)]
adte[, click_weekd := wday(adte$click_time)]

colnames(adte)

adte[, v1 := .N, by = ip]
adte[, v2 := .N, by = app]
adte[, v3 := .N, by = device]
adte[, v4 := .N, by = os]
adte[, v5 := .N, by = channel]
adte[, v6 := .N, by = click_hour]

adte[, v7 := .N, by = list(ip, app)]
adte[, v8 := .N, by = list(device, ip)]
adte[, v9 := .N, by = list(ip, os)]
adte[, v10 := .N, by = list(ip, channel)]
adte[, v11 := .N, by = list(ip, click_hour)]
adte[, v12 := .N, by = list(app, device)]
adte[, v13 := .N, by = list(app, os)]
adte[, v14 := .N, by = list(app, channel)]
adte[, v15 := .N, by = list(app, click_hour)]
adte[, v16 := .N, by = list(device, os)]
adte[, v17 := .N, by = list(device, channel)]
adte[, v18 := .N, by = list(device, click_hour)]
adte[, v19 := .N, by = list(os, channel)]
adte[, v20 := .N, by = list(os, click_hour)]
adte[, v21 := .N, by = list(channel, click_hour)]

adte[, v22 := .N, by = list(ip, app, device)]
adte[, v23 := .N, by = list(ip, app, os)]
adte[, v24 := .N, by = list(ip, app, channel)]
adte[, v25 := .N, by = list(ip, app, click_hour)]
adte[, v26 := .N, by = list(ip, device, os)]
adte[, v27 := .N, by = list(ip, device, channel)]
adte[, v28 := .N, by = list(ip, device, click_hour)]
adte[, v29 := .N, by = list(ip, os, channel)]
adte[, v30 := .N, by = list(ip, os, click_hour)]
adte[, v31 := .N, by = list(ip, channel, click_hour)]
adte[, v32 := .N, by = list(app, device, os)]
adte[, v33 := .N, by = list(app, device, channel)]
adte[, v34 := .N, by = list(app, device, click_hour)]
adte[, v35 := .N, by = list(device, os, channel)]
adte[, v36 := .N, by = list(device, os, click_hour)]
adte[, v37 := .N, by = list(os, channel, click_hour)]

adte[, v38 := .N, by = list(ip, app, device, os)]
adte[, v39 := .N, by = list(ip, app, device, channel)]
adte[, v40 := .N, by = list(ip, app, device, click_hour)]
adte[, v41 := .N, by = list(ip, device, os, channel)]
adte[, v42 := .N, by = list(ip, device, os, click_hour)]
adte[, v43 := .N, by = list(ip, os, channel, click_hour)]
adte[, v44 := .N, by = list(app, device, os, channel)]
adte[, v45 := .N, by = list(app, device, os, click_hour)]
adte[, v46 := .N, by = list(app, os, channel, click_hour)]
adte[, v47 := .N, by = list(device, os, channel, click_hour)]

adte[, v48 := .N, by = list(ip, app, device, os, channel)]
adte[, v49 := .N, by = list(ip, app, device, os, click_hour)]
adte[, v50 := .N, by = list(ip, app, device, channel, click_hour)]
adte[, v51 := .N, by = list(ip, app, os, channel, click_hour)]
adte[, v52 := .N, by = list(ip, device, os, channel, click_hour)]
adte[, v53 := .N, by = list(app, device, os, channel, click_hour)]

adte[, v54 := .N, by = list(ip, app, device, os, channel, click_hour)]

adte[, v101 := seq(.N), by = ip]
adte[, v102 := seq(.N), by = app]
adte[, v103 := seq(.N), by = device]
adte[, v104 := seq(.N), by = os]
adte[, v105 := seq(.N), by = channel]
adte[, v106 := seq(.N), by = click_hour]

adte[, v107 := seq(.N), by = list(ip, app)]
adte[, v108 := seq(.N), by = list(device, ip)]
adte[, v109 := seq(.N), by = list(ip, os)]
adte[, v110 := seq(.N), by = list(ip, channel)]
adte[, v111 := seq(.N), by = list(ip, click_hour)]
adte[, v112 := seq(.N), by = list(app, device)]
adte[, v113 := seq(.N), by = list(app, os)]
adte[, v114 := seq(.N), by = list(app, channel)]
adte[, v115 := seq(.N), by = list(app, click_hour)]
adte[, v116 := seq(.N), by = list(device, os)]
adte[, v117 := seq(.N), by = list(device, channel)]
adte[, v118 := seq(.N), by = list(device, click_hour)]
adte[, v119 := seq(.N), by = list(os, channel)]
adte[, v120 := seq(.N), by = list(os, click_hour)]
adte[, v121 := seq(.N), by = list(channel, click_hour)]

adte[, v122 := seq(.N), by = list(ip, app, device)]
adte[, v123 := seq(.N), by = list(ip, app, os)]
adte[, v124 := seq(.N), by = list(ip, app, channel)]
adte[, v125 := seq(.N), by = list(ip, app, click_hour)]
adte[, v126 := seq(.N), by = list(ip, device, os)]
adte[, v127 := seq(.N), by = list(ip, device, channel)]
adte[, v128 := seq(.N), by = list(ip, device, click_hour)]
adte[, v129 := seq(.N), by = list(ip, os, channel)]
adte[, v130 := seq(.N), by = list(ip, os, click_hour)]
adte[, v131 := seq(.N), by = list(ip, channel, click_hour)]
adte[, v132 := seq(.N), by = list(app, device, os)]
adte[, v133 := seq(.N), by = list(app, device, channel)]
adte[, v134 := seq(.N), by = list(app, device, click_hour)]
adte[, v135 := seq(.N), by = list(device, os, channel)]
adte[, v136 := seq(.N), by = list(device, os, click_hour)]
adte[, v137 := seq(.N), by = list(os, channel, click_hour)]

adte[, v138 := seq(.N), by = list(ip, app, device, os)]
adte[, v139 := seq(.N), by = list(ip, app, device, channel)]
adte[, v140 := seq(.N), by = list(ip, app, device, click_hour)]
adte[, v141 := seq(.N), by = list(ip, device, os, channel)]
adte[, v142 := seq(.N), by = list(ip, device, os, click_hour)]
adte[, v143 := seq(.N), by = list(ip, os, channel, click_hour)]
adte[, v144 := seq(.N), by = list(app, device, os, channel)]
adte[, v145 := seq(.N), by = list(app, device, os, click_hour)]
adte[, v146 := seq(.N), by = list(app, os, channel, click_hour)]
adte[, v147 := seq(.N), by = list(device, os, channel, click_hour)]

adte[, v148 := seq(.N), by = list(ip, app, device, os, channel)]
adte[, v149 := seq(.N), by = list(ip, app, device, os, click_hour)]
adte[, v150 := seq(.N), by = list(ip, app, device, channel, click_hour)]
adte[, v151 := seq(.N), by = list(ip, app, os, channel, click_hour)]
adte[, v152 := seq(.N), by = list(ip, device, os, channel, click_hour)]
adte[, v153 := seq(.N), by = list(app, device, os, channel, click_hour)]

adte[, v154 := seq(.N), by = list(ip, app, device, os, channel, click_hour)]

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
fwrite(sub, paste0("AdT_", round(auc, 6), ".csv"))


##### END #####