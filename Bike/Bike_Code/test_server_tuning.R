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

bike <- btr %>% select(-casual, -registered) %>% 
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
# library(Matrix)
# bike <- sparse.model.matrix(~. -1, bike)

library(mlr)
library(parallelMap)
tr <- bike[tri,]
te <- bike[-tri,] %>% select(-count)
train <- createDummyFeatures(tr)
test <- createDummyFeatures(te)
# Convert the target feature using a log(x+1) transformation and optimize w.r.t. rmse later (equivalent to optimizing rmsle).
train$count = log1p(train$count)

# Create task and learner
trainTask = makeRegrTask(data = train, target = "count")
lrn = makeLearner("regr.xgboost", nrounds = 4000, nthread = 8,
                  base_score = mean(train$count))

# Define hyperparameter ranges you want to consider for tuning
ps = makeParamSet(
  makeNumericParam("eta", lower = 0.01, upper = 0.08),
  makeNumericParam("subsample", lower = 0.7, upper = 1),
  makeNumericParam("colsample_bytree", lower = 0.5, upper = 1),
  makeIntegerParam("max_depth", lower = 5, upper = 12),
  makeIntegerParam("min_child_weight", lower = 1, upper = 50)
)

# Use 'maxit' iterations of random search for tuning (parallelize each iteration using 16 cores)
ctrl = makeTuneControlRandom(maxit = 48)
rdesc = makeResampleDesc("CV", iters = 4)
parallelStartMulticore(16)
(res = tuneParams(lrn, trainTask, rdesc, measures = rmse, par.set = ps, control = ctrl))
parallelStop()

# Train the model with best hyperparameters
mod = train(setHyperPars(lrn, par.vals = c(res$x, nthread = 8, verbose = 1)), trainTask)

# Make prediction (convert predictions back using the inverse of log(x+1))
pred = expm1(getPredictionResponse(predict(mod, newdata = test)))
range(pred)
sub1 = read.csv("../input/sampleSubmission.csv")
sub1$count <- pred
write_csv(sub1, "mlr_t.csv")


