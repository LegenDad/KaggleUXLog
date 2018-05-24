# library(data.table)
# avi <- fread("../input/train.csv")

# install.packages("tidyverse")
library(tidyverse)
library(knitr)
library(ggthemes)
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


# region ------------------------------------------------------------------

head(sort(table(avi$region), decreasing = T))
head(sort(table(avite$region), decreasing = T))

region <- c("Краснодарский край","Свердловская область", 
            "Ростовская область","Татарстан","Челябинская область",
            "Нижегородская область","Самарская область",
            "Башкортостан","Пермский край","Новосибирская область",
            "Ставропольский край","Ханты-Мансийский АО",
            "Воронежская область","Иркутская область",
            "Тульская область","Тюменская область","Белгородская область")
region_en <- c("Krasnodar","Sverdlovsk","Rostov","Tatarstan", 
               "Chelyabinsk","Nizhny Novgorod","Samara", 
               "Bashkortostan","Perm","Novosibirsk", 
               "Stavropol","Khanty-Mansiysk Autonomous Okrug", 
               "Voronezh","Irkutsk","Tula","Tyumen","Belgorod")

df_regions_en <- as.data.frame(cbind(region,region_en))

avi %>% group_by(region) %>% summarise(Count = n()) %>%
  arrange(desc(Count)) %>% head(10) %>% kable()

avi %>% group_by(region) %>% summarise(Count = n()) %>%
  arrange(desc(Count)) %>% head(10) %>% left_join(df_regions_en) %>%
  mutate(region_en = reorder(region_en, Count)) %>%
  ggplot(aes(x=region_en, y=Count)) + 
  geom_col() + coord_flip() + theme_wsj() +
  geom_text(aes(x=region_en, y = 1, label=paste(round((Count/nrow(avi))*100,2), "%")), 
            hjust = 0, vjust =.5,  fontface = 'bold', color="orange") + 
  labs(x='region', y='count', title = 'Most Popular Region')

avite %>% group_by(region) %>% summarise(Count = n()) %>%
  arrange(desc(Count)) %>% head(10) %>% left_join(df_regions_en) %>%
  mutate(region_en = reorder(region_en, Count)) %>%
  ggplot(aes(x=region_en, y=Count)) + 
  geom_col() + coord_flip() + theme_wsj() +
  geom_text(aes(x=region_en, y = 1, label=paste(round((Count/nrow(avi))*100,2), "%")), 
            hjust = 0, vjust =.5,  fontface = 'bold', color="orange") + 
  labs(x='region', y='count', title = 'Most Popular Region')

region_dt <- avi %>% group_by(region) %>% summarise(Count = n()) %>% 
  arrange(desc(Count)) %>% head(10)
avi %>% filter(region %in% region_dt$region) %>%
  ggplot(aes(x=factor(region), y=deal_probability, fill= factor(region))) +
  geom_boxplot() + theme_wsj() +
  theme(axis.text.x = element_text(angle=90, hjust = 1))

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