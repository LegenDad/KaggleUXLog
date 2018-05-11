rm(list=ls()); gc()
library(data.table)
adt <- fread("../input/train_sample.csv")
library(lubridate)
adt$click_hour <- hour(adt$click_time)
adt$click_weekd <- wday(adt$click_time)
library(dplyr)
colnames(adt)
str(adt)
adt <- adt %>% add_count(ip, click_hour, click_weekd)
adt <- adt %>% add_count(ip, app)
adt <- adt %>% add_count(ip, device)
adt <- adt %>% add_count(ip, os)
adt <- adt %>% add_count(ip, channel)
adt <- adt %>% add_count(ip)
adt <- adt %>% add_count(app)
adt <- adt %>% add_count(device)
adt <- adt %>% add_count(os)
adt <- adt %>% add_count(channel)
head(adt)
colnames(adt)[11:20] <- c("ip_hw", "ip_app", "ip_dev", "ip_os", "ip_ch", 
                          "ip_cnt", "app_cnt", "dev_cnt", "os_cnt", "ch_cnt")
colnames(adt)
adt_index <- caret::createDataPartition(adt$is_attributed, p=0.7, list = F)
y <- adt$is_attributed
adtr <- adt %>% select(-ip, -click_time, -attributed_time)
adte <- adtr[-adt_index,]
adtr <- adtr[adt_index,]
colnames(adte) == colnames(adtr)
table(adtr$is_attributed); table(adte$is_attributed)
str(adtr)

###### glm #####
glm <- glm(factor(is_attributed)~., family = binomial, adtr)
summary(glm)

##### cv #####
library(caret)
model <- train(factor(is_attributed)~., adtr, method = "glm",
               trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE))
model
# check R Square
#library(pscl)
#pR2(glm)
pred_glm <- predict(glm, adte, type = "response")
#confusion matrix
#pred_glm2 <- ifelse(pred_glm>.5, 1, 0)
#library(caret)
#confusionMatrix(as.factor(pred_glm2), as.factor(y[-adt_index]))
#pred_glm2 <- ifelse(pred_glm > 0.5,1,0)
library(e1071)
library(ROCR)
pr <- prediction(pred_glm, y[-adt_index])
prf <- performance(pr, "tpr", "fpr")
plot(prf)
auc <- performance(pr, "auc")
(auc <- auc@y.values[[1]])


##### Decision Tree #####
library(rpart)
pred_tree <- rpart(as.factor(is_attributed)~., adtr, method = "class")
summary(pred_tree)
pred_rp <- predict(pred_tree, adte, type = "class")
confusionMatrix(pred_rp, as.factor(y[-adt_index]))
pred_rp2 <- predict(pred_tree, adte, type = "prob")[,2]
pr2 <- prediction(pred_rp2, y[-adt_index])
prf2 <- performance(pr2, "tpr", "fpr")
plot(prf2)
auc2 <- performance(pr2, "auc")
(auc2 <- auc2@y.values[[1]])
cat("glm auc:", auc)
cat("tree auc:", auc2)
##### Random Forest#####  
#memory problem. move to adt_rf
#library(randomForest)
#model.rf=randomForest(as.factor(is_attributed)~., adtr)
#model.rf
#plot(model.rf)
#pred_rf <- predict(model.rf, adte)
#pr3 <- prediction(pred_rf, adte$is_attributed)
#pr3 <- prediction(pred_rf, adte$is_attributed)
#prf3 <- performance(pr3, measure = "tpr", x.measure = "fpr")
#plot(prf3)
#
#auc3 <- performance(pr3, measure = "auc")
#auc3 <- auc3@y.values[[1]]
#auc3
###### END #####