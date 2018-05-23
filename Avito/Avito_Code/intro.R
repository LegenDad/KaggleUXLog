# library(data.table)
# avi <- fread("../input/train.csv")

# install.packages("tidyverse")
library(tidyverse)
library(knitr)
avi <- read_csv("../input/train.csv")
avite <- read_csv("../input/test.csv")
colnames(avi)
colnames(avite)
avi_na <- sapply(avi, function(x) sum(is.na(x)))
avite_na <- sapply(avite, function(x) sum(is.na(x)))
kable(avi_na[avi_na >0])
range(avi$deal_probability)

head(sort(table(avi$region), decreasing = T))
head(sort(table(avite$region), decreasing = T))
head(sort(table(avi$city), decreasing = T))
head(sort(table(avite$city), decreasing = T))
head(sort(table(avi$category_name), decreasing = T))
head(sort(table(avite$category_name), decreasing = T))
head(sort(table(avi$parent_category_name), decreasing = T))
head(sort(table(avite$parent_category_name), decreasing = T))
head(sort(table(avi$param_1), decreasing = T))
head(sort(table(avite$param_1), decreasing = T))
head(sort(table(avi$param_2), decreasing = T))
head(sort(table(avite$param_2), decreasing = T))
head(sort(table(avi$param_3), decreasing = T))
head(sort(table(avite$param_3), decreasing = T))
head(sort(table(avi$deal_probability), decreasing = T))
tail(sort(table(avi$deal_probability), decreasing = T))
range(avi$activation_date)
range(avite$activation_date)
summary(avi$price)
summary(avite$price)
table(avi$user_type)
table(avite$user_type)
prop.table(table(avi$user_type))
prop.table(table(avite$user_type))

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


periods_tr <- read_csv("../input/periods_train.csv")
head(periods_tr)
glimpse(periods_tr)
glimpse(avi)
TotalNumberOfRows = nrow(avi)

train <-train %>%
  mutate(title_len = str_count(title)) %>%
  mutate(description_len = str_count(description))

test <-test %>%
  mutate(title_len = str_count(title)) %>%
  mutate(description_len = str_count(description))