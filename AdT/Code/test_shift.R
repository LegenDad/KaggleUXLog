rm(list=ls()); gc()
library(data.table)
adt <- fread("../input/train_sample.csv")
#adt <- adt[sample(.N, 10e6), ]
library(lubridate)
adt <- setorder(adt, click_time)
adt[, click_hour := hour(adt$click_time)]
adt[, click_weekd := wday(adt$click_time)]
adt$click_time <- as.numeric(ymd_hms(adt$click_time))
head(adt)
adt[, ip_hw := .N, by = list(ip, click_hour, click_weekd)]
adt[, ip_app := .N, by = list(ip, app)]
adt[, ip_dev := .N, by = list(ip, device)]
adt[, ip_os := .N, by = list(ip, os)]
adt[, ip_ch := .N, by = list(ip, channel)]
adt[, ip_cnt := .N, by = ip]
adt[, app_cnt := .N, by = app]
adt[, dev_cnt := .N, by = device]
adt[, os_cnt := .N, by = os]
adt[, ch_cnt := .N, by = channel]
adt[, clicker := .N, by = list(ip, device, os)]
adt[, clicker_app := .N, by = list(ip, device, os, app)]
adt[, clicker_N := seq(.N), by = list(ip, device, os)]
adt[, clicker_app_N := seq(.N), by = list(ip, device, os, app)]
adt[, app_dev := .N, by = list(app, device)]
adt[, app_os := .N, by = list(app, os)]
adt[, app_ch := .N, by = list(app, channel)]
adt[, clicker_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
    by = .(ip, device, os)]
adt[, clicker_app_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
    by = .(ip, device, os, app)]
adt[, clicker_ch_Next := shift(click_time, 1, type = "lead", fill = 0) - click_time, 
    by = .(ip, device, os, app, channel)]
adt$clicker_Next <- ifelse(adt$clicker_Next < 0 , 0 , adt$clicker_Next)
adt$clicker_app_Next <- ifelse(adt$clicker_app_Next <0 , 0 , adt$clicker_app_Next)
adt$clicker_ch_Next <- ifelse(adt$clicker_ch_Next <0 , 0 , adt$clicker_ch_Next)
#fav_appG1 <- c(3, 12, 2)
#fav_appG2 <- c(9, 15, 18, 14)
#adt$fav_app_div <- ifelse(adt$click_hour %in% fav_appG1, 1, 
#                    ifelse(adt$click_hour %in% fav_appG2, 2, 3))
head(adt)
dim(adt)
colnames(adt)
