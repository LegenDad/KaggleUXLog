# library(data.table)
# avi <- fread("../input/train.csv")

# install.packages("tidyverse")
library(tidyverse)
avi <- read_csv("../input/train.csv")
head(avi)
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


period <- read_csv("../input/periods_train.csv")
head(period)
period[period$item_id == "b912c3c6a6ad",]
