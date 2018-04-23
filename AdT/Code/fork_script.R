library(data.table)
library(xgboost)

#---------------------------
cat("Loading data...\n")
train <- fread("../input/train.csv", drop = c("attributed_time"), showProgress=F) 
test <- fread("../input/test.csv", drop = c("click_id"), showProgress=F)

set.seed(0)
train <- train[sample(.N, 50e6), ]

#---------------------------
cat("Basic preprocessing...\n")
y <- train$is_attributed
tri <- 1:nrow(train)
tr_te <- rbind(train, test, fill = T)

rm(train, test); gc()

tr_te[, `:=`(yday = yday(click_time),
             wday = wday(click_time),
             hour = hour(click_time))
      ][, ip_f := .N, by = "ip"
        ][, app_f := .N, by = "app"
          ][, channel_f := .N, by = "channel"
            ][, device_f := .N, by = "device"
              ][, os_f := .N, by = "os"
                ][, app_f := .N, by = "app"
                  ][, ip_app_f := .N, by = "ip,app"
                    ][, ip_dev_f := .N, by = "ip,device"
                      ][, ip_os_f := .N, by = "ip,os"
                        ][, ip_chan_f := .N, by = "ip,channel"
                          ][, c("ip", "click_time", "is_attributed") := NULL]

#---------------------------
cat("Preparing data...\n")
dtest <- xgb.DMatrix(data = data.matrix(tr_te[-tri]))


#
tr_te <- tr_te[tri]
tri <- caret::createDataPartition(y, p = 0.9, list = F)
dtrain <- xgb.DMatrix(data = data.matrix(tr_te[tri]), label = y[tri])
dval <- xgb.DMatrix(data = data.matrix(tr_te[-tri]), label = y[-tri])
cols <- colnames(tr_te)

rm(tr_te, y, tri); gc()

#---------------------------
cat("Training model...\n")
p <- list(objective = "binary:logistic",
          booster = "gbtree",
          eval_metric = "auc",
          nthread = 8,
          eta = 0.07,
          max_depth = 7,
          min_child_weight = 148,
          gamma = 167.6125,
          subsample = 0.6928,
          colsample_bytree = 0.9108,
          colsample_bylevel = 0.9857,
          alpha = 43.2165,
          lambda = 74.6334,
          scale_pos_weight = 103,
          nrounds = 2000)

m_xgb <- xgb.train(p, dtrain, p$nrounds, list(val = dval), print_every_n = 10, early_stopping_rounds = 200)

(imp <- xgb.importance(cols, model=m_xgb))
xgb.plot.importance(imp, top_n = 10)

#---------------------------
cat("Creating submission file...\n")
subm <- fread("../input/sample_submission.csv") 
subm[, is_attributed := round(predict(m_xgb, dtest), 6)]
fwrite(subm, paste0("dt_xgb_", m_xgb$best_score, ".csv"))