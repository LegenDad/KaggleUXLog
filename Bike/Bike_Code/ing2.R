library(tidyverse)
library(lubridate)
library(Matrix)
library(xgboost)
library(lightgbm)
library(pryr)

btr <- read_csv("../input/train.csv")
bte <- read_csv("../input/test.csv")
glimpse(btr); glimpse(bte)

tri <- 1:nrow(btr)
y <- log1p(btr$count)
cas <- log1p(btr$casual)
reg <- log1p(btr$registered)
colnames(btr) ; colnames(bte)
# -casual -registered -count

bike <- btr %>% select(-casual, -registered, -count) %>% 
  bind_rows(bte) %>% 
  mutate(year = year(datetime) %>% factor(), 
         month = month(datetime) %>% factor(), 
         yday = yday(datetime) %>% factor(), 
         mday = mday(datetime) %>% factor(), 
         wday = wday(datetime) %>% factor(), 
         qday = qday(datetime) %>% factor(), 
         week = week(datetime) %>% factor(), 
         hour = hour(datetime), 
         am = am(datetime) %>% as.integer() %>% factor(), 
         pm = pm(datetime) %>% as.integer() %>% factor()) %>% 
  select(-datetime)

bike <- bike %>% mutate(h_dvi = ifelse(hour <=8, 1, 
                                       ifelse(hour ==9, 2, 
                                              ifelse(hour >= 10, 3, 4))))

bike$season      <- factor(bike$season)
bike$holiday     <- factor(bike$holiday)
bike$workingday  <- factor(bike$workingday)
bike$weather    <- factor(bike$weather)
bike$hour        <- factor(bike$hour)  
bike$h_dvi       <- factor(bike$h_dvi)  

bike <- sparse.model.matrix(~. -1, bike)

tr <- bike[tri,]
te <- bike[-tri,]
rm(btr, bte); gc()

set.seed(0)
index <- sample(nrow(tr) * 0.9)

p <- list(booster = "gbtree",
          eval_metric = "rmse",
          nthread = 8,
          eta = 0.05,
          max_depth = 8,
          min_child_weight = 11,
          subsample = .8,
          colsample_bytree = .7,
          nrounds = 5000)

params <- list(objective = "regression", 
               metric = "rmse", 
               min_data_in_leaf = 1, 
               learning_rate = 0.05,
               num_leaves = 30, 
               min_sum_hessian_in_leaf = 11, 
               feature_fraction = .7, 
               bagging_fraction = .8, 
               bagging_freq = 5)

cas_train <- xgb.DMatrix(data = tr[index,], label = cas[index])
cas_val <- xgb.DMatrix(data = tr[-index,], label = cas[-index])
cas_xgb <- xgb.train(p, cas_train, p$nrounds, list(val = cas_val),
                     print_every_n = 10, early_stopping_rounds = 200)

cas_lgtr <- lgb.Dataset(data = tr[index,], label = cas[index])
cas_lgval <- lgb.Dataset(data = tr[-index,], label = cas[-index])
cas_lgb <- lgb.train(params, cas_lgtr, 
                     valids = list(train = cas_lgtr, validation = cas_lgval),
                     nthread = 8, nrounds = 5000, verbose = 1, 
                     early_stopping_rounds = 200, eval_freq = 50)

cas_test <- xgb.DMatrix(data = bike[-tri,])
cas_pred <- predict(cas_xgb, cas_test)

cas_lgte <- te
cas_lgpred <- predict(cas_lgb, cas_lgte, n=cas_lgb$best_iter)

range(cas)
range(cas_pred)
range(cas_lgpred)
cas_pred <- ifelse(cas_pred<0 , 0 , cas_pred)
cas_lgpred <- ifelse(cas_lgpred<0 , 0 , cas_lgpred)

tr <- tr %>% cbind(casual = cas)
te <- te %>% cbind(casual = (cas_pred+cas_lgpred) / 2)

reg_xgtr <- xgb.DMatrix(data = tr[index,], label = reg[index])
reg_xgval <- xgb.DMatrix(data = tr[-index,], label = reg[-index])
reg_xgb <- xgb.train(p, reg_xgtr, p$nrounds, list(val = reg_xgval),
                     print_every_n = 10, early_stopping_rounds = 200)

reg_lgtr <- lgb.Dataset(data = tr[index,], label = reg[index])
reg_lgval <- lgb.Dataset(data = tr[-index,], label = reg[-index])
reg_lgb <- lgb.train(params, reg_lgtr, 
                     valids = list(train = reg_lgtr, validation = reg_lgval),
                     nthread = 8, nrounds = 5000, verbose = 1, 
                     early_stopping_rounds = 200, eval_freq = 50)

reg_xgte <- xgb.DMatrix(data = te)
reg_xgpred <- predict(reg_xgb, reg_xgte)

reg_lgte <- te
reg_lgpred <- predict(reg_lgb, reg_lgte, n=reg_lgb$best_iter)

range(reg)
range(reg_xgpred)
range(reg_lgpred)
reg_xgpred <- ifelse(reg_xgpred<0 , 0 , reg_xgpred)
reg_lgpred <- ifelse(reg_lgpred<0 , 0 , reg_lgpred)

tr <- tr %>% cbind(registered = reg)
te <- te %>% cbind(registered = (reg_xgpred+reg_lgpred) / 2)


train <- xgb.DMatrix(data = tr[index,], label = y[index])
val <- xgb.DMatrix(data = tr[-index,], label = y[-index])
f_xgb <- xgb.train(p, train, p$nrounds, list(val = val), 
                   print_every_n = 1000, early_stopping_rounds = 200)

xgb.importance(feature_names = colnames(train), f_xgb) %>% 
  xgb.plot.importance(top_n = 35)

realtest <- xgb.DMatrix(data = te)
sub1 = read.csv("../input/sampleSubmission.csv")
pred <- expm1(predict(f_xgb, realtest))
range(pred)
sub1$count <- pred
write_csv(sub1, paste0("../SubM/xgb_", round(f_xgb$best_score, 5), ".csv"))

dtrain <- lgb.Dataset(data = tr[index,], label = y[index])
dval <- lgb.Dataset(data = tr[-index,], label = y [-index])
realtest <- te
lgb_m <- lgb.train(params, dtrain, 
                   valids = list(train = dtrain, validation = dval),
                   nthread = 8, nrounds = 5000, verbose = 1, 
                   early_stopping_rounds = 200, eval_freq = 1000)
lgb_m$best_score
tree_imp <- lgb.importance(lgb_m, percentage = TRUE)
lgb.plot.importance(tree_imp, top_n = 10, measure = "Gain")

pred_lgbm <- expm1(predict(lgb_m, realtest, n = lgb_m$best_iter))
range(pred_lgbm)
sub <- read.csv("../input/sampleSubmission.csv")
sub$count <- pred_lgbm
write_csv(sub, paste0("../SubM/lgb_", round(lgb_m$best_score, 5), ".csv"))

pred_bag <- (pred+pred_lgbm) / 2
range(pred_bag)
sub <- read.csv("../input/sampleSubmission.csv")
sub$count <- pred_bag
write_csv(sub, "../SubM/bagging.csv")
