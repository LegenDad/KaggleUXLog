library(tidyverse)
library(lubridate)
library(knitr)

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

library(lightgbm)

dtrain <- lgb.Dataset(data = data.matrix(tr[tr_index,][val_index,]), 
                      label = y[tr_index][val_index])

dval <- lgb.Dataset(data = data.matrix(tr[tr_index,][-val_index,]), 
                    label = y [tr_index][-val_index])

params <- list(objective = "regression", 
               metric = "rmse", 
               min_data_in_leaf = 1, 
               learning_rate = 0.05,
               num_leaves = 30, 
               min_sum_hessian_in_leaf = 11, 
               feature_fraction = .7, 
               bagging_fraction = .8, 
               bagging_freq = 5)

lgb_vm <- lgb.train(params, dtrain, 
                    valids = list(train = dtrain, validation = dval),
                    nthread = 8, nrounds = 5000, verbose = 1, 
                    early_stopping_rounds = 200, eval_freq = 50)

lgb_vm$best_score
kable(lgb.importance(lgb_vm))

index <- sample(nrow(tr) * 0.9)

dtrain <- lgb.Dataset(data = data.matrix(tr[index,]), 
                      label = y[index])

dval <- lgb.Dataset(data = data.matrix(tr[-index,]), 
                    label = y [-index])

realtest <- data.matrix(bike[-tri,])

lgb_m <- lgb.train(params, dtrain, 
                    valids = list(train = dtrain, validation = dval),
                    nthread = 8, nrounds = 5000, verbose = 1, 
                    early_stopping_rounds = 200, eval_freq = 50)

lgb_m$best_score
kable(lgb.importance(lgb_m))
tree_imp <- lgb.importance(lgb_m, percentage = TRUE)
lgb.plot.importance(tree_imp, top_n = 10, measure = "Gain")


pred <- expm1(predict(lgb_m, realtest, n = lgb_m$best_iter))
range(pred)
sub <- read.csv("../input/sampleSubmission.csv")
sub$count <- pred
write_csv(sub, paste0("../SubM/lgb_", round(lgb_m$best_score, 5), ".csv"))


