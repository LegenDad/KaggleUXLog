rm(list=ls()); gc()
library(data.table)
adt <- fread("../input/train_sample.csv")
adt$click_time <- as.POSIXct(adt$click_time)
range(adt$click_time)
adt$attributed_time <- ifelse(adt$is_attributed == 0, "2017-11-06 00:00:00", 
                              adt$attributed_time)
adt$attributed_time <- as.POSIXct(adt$attributed_time)
library(lubridate)
adt[, click_hour := hour(click_time)]
adt[, click_weekd := wday(click_time)]
adt[, ip_hw := .N, by = list(ip, click_hour, click_weekd)]
#head(adt)
#subset(adt, ip==105560 & click_hour == 13 & click_weekd ==3)
adt[, ip_app := .N, by = list(ip, app)]
#head(adt)
#subset(adt, ip==87540 & app==12)
adt[, ip_dev := .N, by = list(ip, device)]
#head(adt)
#subset(adt, ip == 87540 & device == 1)
adt[, ip_os := .N, by = list(ip, os)]
#head(adt)
#subset(adt, ip ==  87540 & os == 13)
adt[, ip_ch := .N, by = list(ip, channel)]
#head(adt)
#subset(adt, ip ==  105560 & channel == 259)
adt[, ip_cnt := .N, by = ip]
#head(adt)
#subset(adt, ip ==  87540)
adt[, app_cnt := .N, by = app]
#head(adt)
#nrow(adt[app==12,])
adt[, dev_cnt := .N, by = device]
#head(adt)
#nrow(adt[device==1,])
adt[, os_cnt := .N, by = os]
#head(adt)
#nrow(adt[os==13])
adt[, ch_cnt := .N, by = channel]
#head(adt)
#nrow(adt[channel==497])
dim(adt)
colnames(adt)
#te_hourG1 <- c(4, 14, 13, 10, 9, 5)
#te_hourG2 <- c(15, 11, 6)
#adt$h_div <- ifelse(adt$click_hour %in% te_hourG1, 1, 
#                    ifelse(adt$click_hour %in% te_hourG2, 3, 2))
adt[, clicker := .N, by = list(ip, device, os)]
#head(adt)
#subset(adt, ip ==  87540 & device == 1 & os == 13)
adt[, clicker_app := .N, by = list(ip, device, os, app)]
#head(adt)
#subset(adt, ip ==  87540 & device == 1 & os == 13 & app == 12)
adt[, clicker_N := 1:.N, by = list(ip, device, os)]
#subset(adt, ip ==  87540 & device == 1 & os == 13)
adt[, clicker_app_N := 1:.N, by = list(ip, device, os, app)]
#head(adt[clicker_app >3,])
#subset(adt, ip ==  36150 & device == 1 & os == 13 & app == 2)
dim(adt)
colnames(adt)
#head(adt[, 19:24])  
adt$down_time <- adt$attributed_time - adt$click_time
adt$down_time <- as.integer(adt$down_time)
range(adt$down_time)
adt$down_time <- ifelse(adt$down_time < 0, 0, adt$down_time)
colnames(adt)

  
  
