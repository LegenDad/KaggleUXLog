library(tidyverse)
library(lubridate)

btr <- read_csv("../input/train.csv")
bte <- read_csv("../input/test.csv")

glimpse(btr)
glimpse(bte)
tri <- 1:nrow(btr)
y <- log1p(btr$count)

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
tr <- bike[tri, ]
tr_index <- sample(nrow(tr)*0.7)  
val_index <- sample(nrow(tr[tr_index,])*0.9)

library(xgboost)

dtest <- xgb.DMatrix(data = data.matrix(tr[-tr_index,]))

dtrain <- xgb.DMatrix(data = data.matrix(tr[tr_index,][val_index,]),
                      label = y[tr_index][val_index])

dval <- xgb.DMatrix(data = data.matrix(tr[tr_index,][-val_index,]),
                    label = y[tr_index][-val_index])

p <- list(booster = "gbtree",
          eval_metric = "rmse",
          nthread = 8,
          eta = 0.05,
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

realtest <- xgb.DMatrix(data = data.matrix(bike[-tri,]))
# preT <- expm1(predict(m_xgb, realtest))
# range(preT)  
sub1 = read.csv("../input/sampleSubmission.csv")
# sub1$count <- preT
# write_csv(sub1, "../SubM/predT.csv")


index <- sample(nrow(tr) * 0.9)
train <- xgb.DMatrix(data = data.matrix(tr[index,]), 
                     label = y[index])
val <- xgb.DMatrix(data = data.matrix(tr[-index,]), 
                   label = y[-index])
f_xgb <- xgb.train(p, train, p$nrounds, list(val = val), 
                 print_every_n = 10, early_stopping_rounds = 200)
xgb.importance(feature_names = colnames(dtrain), f_xgb) %>% xgb.plot.importance()
pred <- expm1(predict(f_xgb, realtest))
range(pred)
sub1$count <- pred
write_csv(sub1, paste0("../SubM/xgb_", round(f_xgb$best_score, 5), ".csv"))

