
# preparation -------------------------------------------------------------

library(tidyverse)
library(knitr)
library(skimr)
library(DT)
library(ggthemes)
avi <- read_csv("../input/train.csv")
avite <- read_csv("../input/test.csv")


# param1 ------------------------------------------------------------------
# intro2.R 



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
