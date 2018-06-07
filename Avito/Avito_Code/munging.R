
# int ---------------------------------------------------------------------

library(tidyverse)
library(knitr)
library(skimr)
library(DT)
avi <- read_csv("../input/train.csv")
avtte <- read_csv("../input/test.csv")
avi_na <- sapply(avi, function (x) sum(is.na(x)))
avi_na[avi_na>0]
avtte_na <- sapply(avtte, function(x) sum(is.na(x)))
avtte_na[avtte_na > 0]
# p1_na, p2_na, p3_na, dsc_na, price_na, img_na, img_t1_na
# test; dsc_na X

avi$p1_na <- is.na(avi$param_1) %>% as.integer()
table(avi$p1_na)

skim(avi$image)
# tr_te <- tr %>% 
#   select(-deal_probability) %>% 
#   bind_rows(te) %>% 
#   mutate(no_img = is.na(image) %>% as.integer(),
#          no_dsc = is.na(description) %>% as.integer(),
#          no_p1 = is.na(param_1) %>% as.integer(), 
#          no_p2 = is.na(param_2) %>% as.integer(), 
#          no_p3 = is.na(param_3) %>% as.integer(),
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
#          param_1 = param_1 %>% factor() %>% as.integer(),
#          param_2 = param_2 %>% factor() %>% as.integer(),
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
