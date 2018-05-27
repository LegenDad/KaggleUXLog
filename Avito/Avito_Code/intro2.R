
# preparation -------------------------------------------------------------

library(tidyverse)
library(knitr)
library(skimr)
library(DT)
library(ggthemes)
avi <- read_csv("../input/train.csv")
# avite <- read_csv("../input/test.csv")


# param1 ------------------------------------------------------------------
param_1 <- c("Женская одежда","Для девочек","Для мальчиков",
             "Продам","С пробегом","Аксессуары",
             "Мужская одежда","Другое",
             "Игрушки","Детские коляски")

param_1_en <- c("Women's clothing","For girls","For boys",
                "Selling","With mileage","Accessories","Men's clothing","Other",
                "Toys","Baby carriages")

df_param_1_en <- as.data.frame(cbind(param_1,param_1_en ) )

# unname ------------------------------------------------------------------


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
