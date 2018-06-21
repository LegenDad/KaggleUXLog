# Created by Giuseppe Casalicchio
library(mlr) # Tutorial: https://mlr-org.github.io/mlr-tutorial
library(xgboost)
library(data.table)
library(parallelMap)
packageVersion("mlr")
packageVersion("xgboost")
set.seed(1)

# Read data
train = read.csv("../input/train.csv")
test = read.csv("../input/test.csv") 
dateTest = test$datetime

# Feature engineering
featureEngineer = function(df) {
  # convert holiday, workingday and weather into factors
  names = c("season", "holiday", "workingday", "weather")
  df[,names] = lapply(df[,names], factor)
  # convert datetime into timestamps (in order to split it into day and hour)
  df$datetime = strptime(as.character(df$datetime), format = "%Y-%m-%d %T", tz = "EST")
  # convert hours to factors in separate feature
  df$hour = as.factor(format(df$datetime, format = "%H"))
  # add day of the week as new feature
  df$weekday = as.factor(format(df$datetime, format = "%u"))
  # extract year from date and convert to factor
  df$year = as.factor(format(df$datetime, format = "%Y"))
  # remove duplicated information
  df$datetime = df$casual = df$registered = NULL
  return(df)
}
train = featureEngineer(train)
test = featureEngineer(test)

# Convert the target feature using a log(x+1) transformation and optimize w.r.t. rmse later (equivalent to optimizing rmsle).
train$count = log1p(train$count)

# Create task and learner
trainTask = makeRegrTask(data = train, target = "count")
lrn = makeLearner("regr.xgboost", nrounds = 400, nthread = 1, base_score = mean(train$count))

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
parallelStartMulticore(8)
(res = tuneParams(lrn, trainTask, rdesc, measures = rmse, par.set = ps, control = ctrl))
parallelStop()

# Train the model with best hyperparameters
mod = train(setHyperPars(lrn, par.vals = c(res$x, nthread = 16, verbose = 1)), trainTask)

# Make prediction (convert predictions back using the inverse of log(x+1))
pred = expm1(getPredictionResponse(predict(mod, newdata = test)))
submit = data.frame(datetime = dateTest, count = pred)
write.csv(submit, file = "script.csv", row.names = FALSE)