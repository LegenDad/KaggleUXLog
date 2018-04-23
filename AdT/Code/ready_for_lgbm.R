system.time(source("checking.R"))
system.time(source("adt.R"))
package_version("xgboost")
packageVersion("xgboost")
sort(table(adt$click_hour), decreasing = T)
sort(table(adt$device), decreasing = T)
in_test_hh  = ifelse(hour %in% most_freq_hours_in_test_data, 1,
                     ifelse(hour %in% least_freq_hours_in_test_data, 2, 3))
#add_count(ip, wday, in_test_hh)
mem_used()
??mem_used
categorical_features = c("app", "os", "channel")

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
cat("Validation AUC @ best iter: ", 
    max(unlist(model$record_evals[["validation"]][["auc"]][["eval"]])), "\n")
dtest <- as.matrix(test[, colnames(test)])
install.packages("pryr")
library(pryr)
mem_used()
preds <- predict(model, data = dtest, n = model$best_iter)
preds <- as.data.frame(preds)
sub$is_attributed = preds
sub$is_attributed = round(sub$is_attributed,4)
kable(lgb.importance(model, percentage = TRUE))

library(dplyr)
?gc
??kable
