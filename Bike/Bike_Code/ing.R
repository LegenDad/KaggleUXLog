library(tidyverse)
library(lubridate)

btr <- read_csv("../input/train.csv")
bte <- read_csv("../input/test.csv")

glimpse(btr)
glimpse(bte)
tri <- 1:nrow(btr)
y <- log1p(btr$count)
cas <- log1p(btr$casual)
reg <- log1p(btr$registered)
colnames(btr)
colnames(bte)
# -casual -registered -count

bike <- btr %>% select(-casual, -registered, -count) %>% 
  bind_rows(bte) %>% 
  mutate(year = year(datetime), 
         month = month(datetime), 
         yday = yday(datetime), 
         mday = mday(datetime), 
         wday = wday(datetime), 
         qday = qday(datetime), 
         week = week(datetime), 
         hour = hour(datetime), 
         am = am(datetime) %>% as.integer(), 
         pm = pm(datetime) %>% as.integer()) %>% select(-datetime)

bike <- bike %>% mutate(h_dvi = ifelse(hour <=8, 1, 
                                       ifelse(hour ==9, 2, 
                                              ifelse(hour >= 10, 3, 4))))



bike$season      <- factor(bike$season)
bike$holiday     <- factor(bike$holiday)
bike$workingday  <- factor(bike$workingday)
bike$weather    <- factor(bike$weather)
bike$year       <- factor(bike$year)
bike$month       <- factor(bike$month)
bike$yday       <- factor(bike$yday)
bike$mday       <- factor(bike$mday)
bike$wday       <- factor(bike$wday)
bike$qday       <- factor(bike$qday)
bike$week        <- factor(bike$week)
bike$hour        <- factor(bike$hour)  
bike$am          <- factor(bike$am)    
bike$pm          <- factor(bike$pm) 
bike$h_dvi       <- factor(bike$h_dvi)  


# bike <- model.matrix(~. -1, bike)
library(Matrix)
bike <- sparse.model.matrix(~. -1, bike)

tr <- bike[tri,]

set.seed(0)
index <- sample(nrow(tr) * 0.9)

library(xgboost)

cas_train <- xgb.DMatrix(data = data.matrix(tr[index,]), 
                     label = cas[index])
cas_val <- xgb.DMatrix(data = data.matrix(tr[-index,]), 
                   label = cas[-index])
p <- list(booster = "gbtree",
          eval_metric = "rmse",
          nthread = 8,
          eta = 0.05,
          max_depth = 8,
          min_child_weight = 11,
          # gamma = 0,
          subsample = .8,
          colsample_bytree = .7,
          # alpha = 2.25,
          # lambda = 0,
          nrounds = 5000)

cas_xgb <- xgb.train(p, cas_train, p$nrounds, list(val = cas_val), 
                   print_every_n = 10, early_stopping_rounds = 200)

cas_test <- xgb.DMatrix(data = data.matrix(bike[-tri,]))
cas_pred <- predict(cas_xgb, cas_test)
range(cas)
range(cas_pred)
cas_pred <- ifelse(cas_pred<0 , 0 , cas_pred)

dim(tr)
dim(bike)
length(cas_pred)
tr <- tr %>% cbind(casual = cas)
te <- bike[-tri,] %>% cbind(casual = cas_pred)

reg_train <- xgb.DMatrix(data = data.matrix(tr[index,]), 
                         label = reg[index])
reg_val <- xgb.DMatrix(data = data.matrix(tr[-index,]), 
                       label = reg[-index])

reg_xgb <- xgb.train(p, reg_train, p$nrounds, list(val = reg_val), 
                     print_every_n = 10, early_stopping_rounds = 200)

reg_test <- xgb.DMatrix(data = data.matrix(te))
reg_pred <- predict(reg_xgb, reg_test)
range(reg)
range(reg_pred)
reg_pred <- ifelse(reg_pred<0 , 0 , reg_pred)
tr <- tr %>% cbind(registered = reg)
te <- te %>% cbind(registered = reg_pred)

train <- xgb.DMatrix(data = data.matrix(tr[index,]), 
                     label = y[index])
val <- xgb.DMatrix(data = data.matrix(tr[-index,]), 
                   label = y[-index])

p <- list(booster = "gbtree",
          eval_metric = "rmse",
          nthread = 8,
          eta = 0.05,
          max_depth = 8,
          min_child_weight = 11,
          # gamma = 0,
          subsample = .8,
          colsample_bytree = .7,
          # alpha = 2.25,
          # lambda = 0,
          nrounds = 5000)



f_xgb <- xgb.train(p, train, p$nrounds, list(val = val), 
                   print_every_n = 10, early_stopping_rounds = 200)
xgb.importance(feature_names = colnames(train), f_xgb) %>% 
  xgb.plot.importance(top_n = 35)

realtest <- xgb.DMatrix(data = data.matrix(te))
sub1 = read.csv("../input/sampleSubmission.csv")

pred <- expm1(predict(f_xgb, realtest))
range(pred)
sub1$count <- pred
write_csv(sub1, paste0("../SubM/xgb_", round(f_xgb$best_score, 5), ".csv"))

library(lightgbm)
params <- list(objective = "regression", 
               metric = "rmse", 
               min_data_in_leaf = 1, 
               learning_rate = 0.05,
               num_leaves = 30, 
               min_sum_hessian_in_leaf = 11, 
               feature_fraction = .7, 
               bagging_fraction = .8, 
               bagging_freq = 5)

dtrain <- lgb.Dataset(data = data.matrix(tr[index,]), 
                      label = y[index])

dval <- lgb.Dataset(data = data.matrix(tr[-index,]), 
                    label = y [-index])

realtest <- data.matrix(te)

lgb_m <- lgb.train(params, dtrain, 
                   valids = list(train = dtrain, validation = dval),
                   nthread = 8, nrounds = 5000, verbose = 1, 
                   early_stopping_rounds = 200, eval_freq = 50)

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
