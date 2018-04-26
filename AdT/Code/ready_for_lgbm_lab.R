#categorical_features = c("app", "device", "os", "channel", "hour")
DT = data.table(x=rep(c("b","a","c"),each=3), v=c(1,1,1,2,2,1,1,2,2), y=c(1,3,6), a=1:9, b=9:1)
DT

DT <- DT %>% add_count(x,v) 
DT <- DT %>% group_by(x, v) %>% mutate(nn = 1:n())


train[, UsrappCount:=.N, by=list(ip,app,device,os)]
train[, UsrappNewness:=1:.N, by=list(ip,app,device,os)]
train[, UsrCount:=.N, by=list(ip,device,os)]
train[, UsrNewness:=1:.N, by=list(ip,device,os)]

library(devtools)
install_github("Microsoft/LightGBM", subdir = "R-package")
library(lightgbm)
data(agaricus.train, package='lightgbm')
train <- agaricus.train
dtrain <- lgb.Dataset(train$data, label=train$label)
params <- list(objective="regression", metric="l2")
model <- lgb.cv(params, dtrain, 10, nfold=5, min_data=1, learning_rate=1, early_stopping_rounds=10)

dtrain <- lgb.Dataset(data = as.matrix(adtr[adt_index,][tri,]),
                      label = y[adt_index][tri])
str(dtrain)
dval <- lgb.Dataset(data = as.matrix(adtr[adt_index,][-tri,]), 
                    label = y[adt_index][-tri])
dtest <- as.matrix(adtr[-adt_index,])
mem_used()
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
                        nthread = 4, nrounds = 2000, verbose = 1, 
                        early_stopping_rounds = 200, eval_freq = 50)
str(model_lgbm)
model_lgbm$record_evals
model_lgbm$record_evals[["validation"]]
model_lgbm$record_evals[["validation"]][["auc"]]
model_lgbm$record_evals[["validation"]][["auc"]][["eval"]]
foo <- model_lgbm$record_evals[["validation"]][["auc"]][["eval"]]
max(unlist(foo))
model_lgbm$best_iter

pred_lgbm <- predict(model_lgbm, data = dtest, n = model_lgbm$best_iter)




library(ROCR)
#pr <- prediction(predXG, adt[-adt_index,]$is_attributed)
pr <- prediction(pred_lgbm, y[-adt_index])
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)

auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc






######################
dtrain = lgb.Dataset(data = as.matrix(dtrain[, colnames(dtrain) != "is_attributed"]), 
                     label = dtrain$is_attributed, categorical_feature = categorical_features)
dvalid = lgb.Dataset(data = as.matrix(valid[, colnames(valid) != "is_attributed"]), 
                     label = valid$is_attributed, categorical_feature = categorical_features)
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
model <- lgb.train(params, dtrain, valids = list(validation = dvalid), nthread = 4,
                   nrounds = 1000, verbose= 1, early_stopping_rounds = 20, eval_freq = 50)