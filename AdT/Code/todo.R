library(data.table)
adt <- fread("../input/train_sample.csv")
adt$click_time <- as.POSIXct(adt$click_time)
library(lubridate)
adt[, click_hour := hour(adt$click_time)]
adt[, click_weekd := wday(adt$click_time)]
#adt[, click_m := minute(adt$click_time)]
#adt[, click_s := second(adt$click_time)]
head(adt)
adt87 <- adt[adt$ip == 87540,]
adt87
library(dplyr)
adt87 %>% group_by(ip, os, device) %>% mutate(diff = diff.difftime(click_time))

adt878 <- adt87 %>% group_by(ip, os, device) %>% mutate(g1 = 1:n())
adt878 <- as.data.table(adt878)
diff(adt878$click_time)
difftime(adt878$click_time)
difftime(adt878$click_time[1], adt878$click_time[2])

as.numeric(difftime(adt878$click_time[1], adt878$click_time[2]), units = "secs")
as.numeric(difftime(adt878$click_time[1], adt878$click_time[2]), units = "hours")
as.numeric(difftime(adt878$click_time[1], adt878$click_time[2]), units = "mins")
61540 / 60 / 60
as.numeric(difftime(adt878$click_time[8], adt878$click_time[2]), units = "secs")
