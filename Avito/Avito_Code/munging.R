
# int ---------------------------------------------------------------------

library(tidyverse)
library(knitr)
library(skimr)
library(DT)
avi <- read_csv("../input/train.csv")
# avtte <- read_csv("../input/test.csv")


# NA Check ---------------------------------------------------------------------


# avtte_na <- sapply(avtte, function(x) sum(is.na(x)))
# avtte_na[avtte_na > 0]
avi_na <- sapply(avi, function (x) sum(is.na(x)))
avi_na[avi_na>0]
# p1_na, p2_na, p3_na, dsc_na, price_na, img_na, img_t1_na
# test; dsc_na X

# p1.p2,p3 ----------------------------------------------------------------

avi$p1_na <- is.na(avi$param_1) %>% as.integer()
avi$p2_na <- is.na(avi$param_2) %>% as.integer()
avi$p3_na <- is.na(avi$param_3) %>% as.integer()
table(avi$p1_na)
table(avi$p2_na)
table(avi$p3_na)
str(avi$param_1)
head(sort(table(avi$param_1), decreasing = T), 7)
avi <- avi %>% mutate(param_1 = param_1 %>% factor() %>% as.integer(), 
                      param_2 = as.integer(factor(param_2)), 
                      param_3 = as.integer(factor(param_3)))
head(sort(table(avi$param_3), decreasing = T), 7)
sort(table(avi$param_3), decreasing = T)

# avi$param_1 <- ifelse(is.na(avi$param_1), -1, avi$param_1)
avi <- avi %>% replace_na(list(param_1 = -1, param_2 = -1, param_3 =-1))
nrow(avi[avi$param_1 ==-1, ]) == sum(avi$p1_na)
nrow(avi[avi$param_2 ==-1, ]) == sum(avi$p2_na)
nrow(avi[avi$param_3 ==-1, ]) == sum(avi$p3_na)
avi_na2 <- sapply(avi, function (x) sum(is.na(x)))
avi_na2[avi_na2>0]
str(avi$param_1)
range(avi$param_1)
range(avi$param_2)
range(avi$param_3)

pie(table(avi$param_1))
pie(table(avi$param_2))
pie(table(avi$param_3))

head(sort(table(avi$param_3), decreasing = T), 300)
head(sort(table(avi$param_3), decreasing = T), 250)
1503424 * 0.00005

?fct_lump


avi$dsc_na <- is.na(avi$description) %>% as.integer()
avi$img_na <- is.na(avi$image) %>% as.integer()
table(avi$dsc_na)
table(avi$img_na)
range(avi$image_top_1, na.rm = T)

#   mutate(
#          titl_len = str_length(title),
#          desc_len = str_length(description),
#          titl_cap = str_count(title, "[A-ZА-Я]"),
#          desc_cap = str_count(description, "[A-ZА-Я]"),
#          titl_pun = str_count(title, "[[:punct:]]"),
#          desc_pun = str_count(description, "[[:punct:]]"),
#          titl_dig = str_count(title, "[[:digit:]]"),
#          desc_dig = str_count(description, "[[:digit:]]"),
#          user_type = as.factor(user_type) %>% as.integer(),
#          category_name = category_name %>% factor() %>% as.integer(),
#          parent_category_name = parent_category_name %>% factor() %>% as.integer(),
#          region = region %>% factor() %>% as.integer(),
#          param_3 = param_3 %>% factor() %>% fct_lump(prop = 0.00005) %>% as.integer(),
#          city = city %>% factor() %>% fct_lump(prop = 0.0003) %>% as.integer(),
#          user_id = user_id %>% factor() %>% fct_lump(prop = 0.000025) %>% as.integer(),
#          price = log1p(price),
#          txt = paste(title, description, sep = " "),
#          mday = mday(activation_date),
#          wday = wday(activation_date),
#          day = day(activation_date)) %>%
#   select(-item_id, -image, -title, -description, -activation_date) %>%
#   replace_na(list(image_top_1 = -1, price = -1,
#                   param_1 = -1, param_2 = -1, param_3 = -1,
#                   desc_len = 0, desc_cap = 0, desc_pun = 0, desc_dig = 0)) %T>%
#   glimpse()

# dsc ---------------------------------------------------------------------


# price -------------------------------------------------------------------


# img ---------------------------------------------------------------------

