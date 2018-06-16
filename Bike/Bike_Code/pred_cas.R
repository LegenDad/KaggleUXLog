library(tidyverse)
library(lubridate)
library(skimr)

btr <- read_csv("../input/train.csv")
bte <- read_csv("../input/test.csv")

glimpse(btr)
glimpse(bte)
btr %>% select(registered, casual) %>% skim()
tri <- 1:nrow(btr)
y <- log1p(btr$count)

colnames(btr)
colnames(bte)
# -casual -registered -count
cas <- btr$casual
reg <- btr$registered

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

tr <- bike[tri, ]
te <- bike[-tri,]
tr_index <- sample(nrow(tr)*0.7)  
val_index <- sample(nrow(tr[tr_index,])*0.9)

library(xgboost)

cas_tr <- xgb.DMatrix(data = data.matrix(tr[tr_index,][val_index,]),
                      label = cas[tr_index][val_index])

cas_val <- xgb.DMatrix(data = data.matrix(tr[tr_index,][-val_index,]),
                       label = cas[tr_index][-val_index])

reg_tr <- xgb.DMatrix(data = data.matrix(tr[tr_index,][val_index,]),
                      label = reg[tr_index][val_index])

reg_val <- xgb.DMatrix(data = data.matrix(tr[tr_index,][-val_index,]),
                       label = reg[tr_index][-val_index])

cas_te <- xgb.DMatrix(data = data.matrix(tr[-tr_index,]))
  
p <- list(booster = "gbtree",
          eval_metric = "rmse",
          nthread = 8,
          eta = 0.01,
          max_depth = 18,
          min_child_weight = 11,
          gamma = 0,
          subsample = 0.8,
          colsample_bytree = 0.7,
          alpha = 2.25,
          lambda = 0,
          nrounds = 5000)

m_cas <- xgb.train(p, cas_tr, p$nrounds, list(val = cas_val), 
                   print_every_n = 10, early_stopping_rounds = 200)
m_reg <- xgb.train(p, reg_tr, p$nrounds, list(val = reg_val), 
                   print_every_n = 10, early_stopping_rounds = 200)

pred_cas <- predict(m_cas, cas_te)
pred_rge <- predict(m_reg, cas_te)
range(pred_cas); range(pred_rge)

pred_cas <- ifelse(pred_cas < 0 , 0 , pred_cas)
pred_rge <- ifelse(pred_rge < 0 , 0 , pred_rge)


realtest <- xgb.DMatrix(data = data.matrix(te))

pred_cas <- predict(m_cas, realtest)
pred_rge <- predict(m_reg, realtest)
range(pred_cas); range(pred_rge)

pred_cas <- ifelse(pred_cas < 0 , 0 , pred_cas)
pred_rge <- ifelse(pred_rge < 0 , 0 , pred_rge)

tr$casual <- cas
tr$registered <- reg

te$casual <- pred_cas
te$registered <- pred_rge


dtest <- xgb.DMatrix(data = data.matrix(tr[-tr_index,]))

dtrain <- xgb.DMatrix(data = data.matrix(tr[tr_index,][val_index,]),
                      label = y[tr_index][val_index])

dval <- xgb.DMatrix(data = data.matrix(tr[tr_index,][-val_index,]),
                    label = y[tr_index][-val_index])



p <- list(booster = "gbtree",
          eval_metric = "rmse",
          nthread = 8,
          eta = 0.01,
          max_depth = 18,
          min_child_weight = 11,
          gamma = 0,
          subsample = 0.8,
          colsample_bytree = 0.7,
          alpha = 2.25,
          lambda = 0,
          nrounds = 5000)

m_xgb <- xgb.train(p, dtrain, p$nrounds, list(val = dval), 
                   print_every_n = 10, early_stopping_rounds = 200)


xgb.importance(feature_names = colnames(dtrain), m_xgb) %>% xgb.plot.importance()

# realtest <- xgb.DMatrix(data = data.matrix(bike[-tri,]))
realtest <- xgb.DMatrix(data = data.matrix(te))
preT <- expm1(predict(m_xgb, realtest))
range(preT)  
sub1 = read.csv("../input/sampleSubmission.csv")
sub1$count <- preT
write_csv(sub1, "../SubM/predT.csv")

tr
index <- sample(nrow(tr) * 0.9)
train <- xgb.DMatrix(data = data.matrix(tr[index,]), 
                     label = y[index])
val <- xgb.DMatrix(data = data.matrix(tr[-index,]), 
                   label = y[-index])
xgb <- xgb.train(p, train, p$nrounds, list(val = val), 
                 print_every_n = 10, early_stopping_rounds = 200)
pred <- expm1(predict(xgb, realtest))
range(pred)
sub1$count <- pred
write_csv(sub1, "../SubM/pred.csv")
