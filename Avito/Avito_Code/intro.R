# library(data.table)
# avi <- fread("../input/train.csv")

# install.packages("tidyverse")
library(tidyverse)
avi <- read_csv("../input/train.csv")
head(avi)

na_cnt <- sapply(avi, function(x) sum(is.na(x)))
na_cnt[na_cnt >0]
library(Amelia)
??Amelia
missmap(avi, main='NA')

# intro -------------------------------------------------------------------



glimpse(avi)
colnames(avi)
summary(avi$item_id)
str(avi$item_id)
summary(avi$user_id)
summary(avi$region)
summary(avi$city)
summary(avi$parent_category_name)
summary(avi$category_name)
str(avi$category_name)
summary(avi$param_1)
str(avi$param_1)
summary(avi$param_2)
summary(avi$param_3)
str(avi$param_3)  # NA  862565
sum(is.na(avi$param_3))
summary(avi$title)
str(avi$title)
summary(avi$description)
summary(avi$price)  # NA 85362
str(avi$price)
summary(avi$item_seq_number)
str(avi$item_seq_number)
summary(avi$activation_date)
str(avi$activation_date)
range(avi$activation_date)  # "2017-03-15" "2017-04-07"
summary(avi$user_type)
str(avi$user_type)
table(avi$user_type) # Company, Private, Shop (3 factors)
summary(avi$image) # Id code of image. Ties to a jpg file in train_jpg. 
str(avi$image)     # Not every ad has an image
sum(is.na(avi$image))  # NA 112588
summary(avi$image_top_1) # NA 112588
str(avi$image_top_1) # Avito's classification code for the image.
summary(avi$deal_probability)
str(avi$deal_probability)
range(avi$deal_probability)


# period file -------------------------------------------------------------

colnames(avi)
period <- read_csv("../input/periods_train.csv")
head(avi$item_id)
range(avi$activation_date)
range(period$activation_date)
head(period )
glimpse(period)
tail <- tail(avi$item_id)
tail(avi$activation_date)
period[period$item_id =="ba83aefab5dc" ,]
period[period$item_id =="d1f0910d2126" ,]
period[period$item_id =="bc04866bc803" ,]
period[period$item_id =="8ab4c1e56046" ,]
avi[avi$item_id == "80bf58082ad3", ]
period[period$item_id =="80bf58082ad3" ,]

# active file -------------------------------------------------------------

active <- read_csv("../input/train_active.csv")
