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

# bike <- bike %>% mutate(temp = factor(temp) %>%  fct_lump(n=5),
#                         atemp = factor(atemp) %>%  fct_lump(n=5), 
#                         humidity = factor(humidity) %>%  fct_lump(n=5), 
#                         windspeed = factor(windspeed) %>%  fct_lump(n=5))

# bike <- model.matrix(~. -1, bike)
library(Matrix)
bike <- sparse.model.matrix(~. -1, bike)

tr <- bike[tri,]

set.seed(0)
index <- sample(nrow(tr) * 0.9)

library(xgboost)

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

realtest <- xgb.DMatrix(data = data.matrix(bike[-tri,]))
sub1 = read.csv("../input/sampleSubmission.csv")

pred <- expm1(predict(f_xgb, realtest))
range(pred)
sub1$count <- pred
write_csv(sub1, paste0("../SubM/xgb_", round(f_xgb$best_score, 5), ".csv"))

