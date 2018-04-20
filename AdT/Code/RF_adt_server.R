rm(list=ls()); gc()
#adt <- adt[sample(.N, 30e6), ]
library(data.table)
adt <- fread("../input/train.csv")
adt <- adt[sample(.N, 10e6), ]
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

library(caret)
#args(createDataPartition)
colnames(adt)
adt_index<- createDataPartition(adt$is_attributed, p=0.7, list = F)
y <- adt$is_attributed

adtr <- adt %>% select(-ip, -click_time, -attributed_time)

adte <- adtr[-adt_index,]
adtr <- adtr[adt_index,]

colnames(adte)
colnames(adtr)
table(adtr$is_attributed); table(adte$is_attributed)

###### glm #####
glm <- glm(is_attributed~., 
           family = binomial, adtr)
summary(glm)
anova(glm, test = "Chisq")
library(pscl)
pR2(glm)
format(3.510406e-01, scientific = F)
pred_glm <- predict(glm, newdata = adte, type = "response")
pred_glm2 <- ifelse(pred_glm > 0.5,1,0)
sum(pred_glm2)
library(e1071)
confusionMatrix(as.factor(pred_glm2), as.factor(y[-adt_index]))
library(ROCR)
pr <- prediction(pred_glm, y[-adt_index])
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)
auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc

##### bayesglm #####
library(arm)
glm2 <- bayesglm(is_attributed~., family = binomial, adtr)
summary(glm2)
anova(glm2, test = "Chisq")
pR2(glm2)
format(3.510406e-01, scientific = F)
pred_glm21 <- predict(glm2, newdata = adte, type = "response")
pred_glm22 <- ifelse(pred_glm2 > 0.5,1,0)
sum(pred_glm22)
confusionMatrix(as.factor(pred_glm22), as.factor(y[-adt_index]))
pr2 <- prediction(pred_glm21, y[-adt_index])
prf2 <- performance(pr2, measure = "tpr", x.measure = "fpr")
plot(prf2)
auc2 <- performance(pr2, measure = "auc")
auc2 <- auc2@y.values[[1]]
auc2

##### Random Forest #####
library(randomForest)
model.rf=randomForest(is_attributed~., adtr)
model.rf
plot(model.rf)
pred_rf <- predict(model.rf, adte)
pr3 <- prediction(pred_rf, adte$is_attributed)
pr3 <- prediction(pred_rf, adte$is_attributed)
prf3 <- performance(pr3, measure = "tpr", x.measure = "fpr")
plot(prf3)

auc3 <- performance(pr3, measure = "auc")
auc3 <- auc3@y.values[[1]]
auc3

rm(adtr, adte); gc()

##### test data _ NOT RUN in Local #####
adte <- fread("../input/test.csv")
adte <- adte %>% select(-click_id)
adte$click_hour <- hour(adte$click_time)
adte$click_weekd <- wday(adte$click_time)
adte <- adte %>% add_count(ip, click_hour, click_weekd) 
adte <- adte %>% add_count(ip, app)
adte <- adte %>% add_count(ip, device)
adte <- adte %>% add_count(ip, os)
adte <- adte %>% add_count(ip, channel)
adte <- adte %>% add_count(ip)
adte <- adte %>% add_count(app)
adte <- adte %>% add_count(device)
adte <- adte %>% add_count(os)
adte <- adte %>% add_count(channel)
head(adte)
colnames(adte)[9:18] <- c("ip_hw", "ip_app", "ip_dev", "ip_os", "ip_ch", 
                          "ip_cnt", "app_cnt", "dev_cnt", "os_cnt", "ch_cnt")
adte <- adte %>% select(-ip, -click_time)

######
glmpred <- predict(glm, newdata = adte, type = "response")
sub <- fread("../input/sample_submission.csv")
sub$is_attributed <- glmpred
fwrite(sub, paste0("glm", auc, ".csv"))

rfpred <- predict(model.rf, adte)
sub <- fread("../input/sample_submission.csv")
sub$is_attributed <- rfpred
fwrite(sub, paste0("rf", auc3, ".csv"))

#####
