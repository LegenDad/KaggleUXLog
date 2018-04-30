##### XGBoost #####
library(xgboost)
dttrain <- xgb.DMatrix(data = data.matrix(adtr[adt_index,][tri,][,-"down_time"]), 
                       label = dt_y[adt_index][tri])
dtval <- xgb.DMatrix(data = data.matrix(adtr[adt_index,][-tri,][,-"down_time"]), 
                     label = dt_y[adt_index][-tri])
dttest <- xgb.DMatrix(data = data.matrix(adtr[-adt_index,][,-"down_time"]))
m_xgb <- xgb.train(data = dttrain, nrounds = 150, max_depth = 5, 
                   eta =0.1, subsample = 0.9)

#xgb.importance(feature_names = colnames(dttrain), m_xgb) %>% xgb.plot.importance()
predXG <- predict(m_xgb, dttest)
sqrt(mean((dt_y[-adt_index] - predXG)^2))
range(dt_y[-adt_index])
range(predXG)
#predXG <- ifelse(predXG < 0, 0, round(predXG))
predXG <- ifelse(predXG < 0, 0, predXG)
predXG <- as.integer(predXG)
tail(table(predXG))
table(predXG, adte$down_time)
confusionMatrix(factor(predXG), factor(adte$down_time))
adte$down_time <- predXG
library(lightgbm)
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
                        nthread = 8, nrounds = 3000, verbose = 1, 
                        early_stopping_rounds = 300, eval_freq = 10)
#str(model_lgbm)
#model_lgbm$record_evals
#model_lgbm$record_evals[["validation"]]
#model_lgbm$record_evals[["validation"]][["auc"]][["eval"]]
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


###### LM #####
lm <- lm(down_time~. ,data = adtr[adt_index,])
pred_lm <- predict(lm, adtr[-adt_index,])
range(pred_lm)
pred_lm <- ifelse(pred_lm <0, 0, pred_lm)
sqrt(mean((dt_y[-adt_index] - pred_lm)^2))
adte <- adtr[-adt_index]
adte$down_time <- as.integer(pred_lm)
library(lightgbm)
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
                        nthread = 8, nrounds = 3000, verbose = 1, 
                        early_stopping_rounds = 300, eval_freq = 10)
#str(model_lgbm)
#model_lgbm$record_evals
#model_lgbm$record_evals[["validation"]]
#model_lgbm$record_evals[["validation"]][["auc"]][["eval"]]
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

##### Multinorm #####
library(nnet)
lm <- multinom(factor(down_time)~. ,adtr[adt_index,])
pred_lm <- predict(lm, adte)
table(pred_lm)
confusionMatrix(factor(pred_lm), factor(adte$down_time))
##### LightGBM #####
library(lightgbm)
dt_y <- adt$down_time
dttrain <- lgb.Dataset(data = as.matrix(adtr[adt_index,][tri,][,-"down_time"]), 
                       label = dt_y[adt_index][tri])
dtval <- lgb.Dataset(data = as.matrix(adtr[adt_index,][-tri,][,-"down_time"]), 
                     label = dt_y[adt_index][-tri])
dttest <- as.matrix(adtr[-adt_index,][,-"down_time"])
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
                      nthread = 8, nrounds = 3000, verbose = 1, 
                      early_stopping_rounds = 300, eval_freq = 10)

model_dt$best_score
model_dt$best_iter
pred_dt <- predict(model_dt, dttest, n = model_dt$best_iter)
sqrt(mean((dt_y[-adt_index] - pred_dt)^2))
range(pred_dt)
adte <- adtr[-adt_index]
pred_dt <- ifelse(pred_dt <0, 0, pred_dt)
adte$down_time <- as.integer(pred_dt)
library(lightgbm)
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
                        nthread = 8, nrounds = 3000, verbose = 1, 
                        early_stopping_rounds = 300, eval_freq = 10)
#str(model_lgbm)
#model_lgbm$record_evals
#model_lgbm$record_evals[["validation"]]
#model_lgbm$record_evals[["validation"]][["auc"]][["eval"]]
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



  