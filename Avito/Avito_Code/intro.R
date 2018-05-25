
# intro -------------------------------------------------------------------


# library(data.table)
# avi <- fread("../input/train.csv")

# install.packages("tidyverse")
library(tidyverse)
library(knitr)
library(skimr)
library(DT)
library(ggthemes)
avi <- read_csv("../input/train.csv")
avite <- read_csv("../input/test.csv")
colnames(avi)
colnames(avite)
# datatable(head(avi, 50))
head(avi, 50) %>% datatable(filter = 'top', 
                            options = list(pageLength = 15, autoWidth = T))

avi_na <- sapply(avi, function(x) sum(is.na(x)))
avite_na <- sapply(avite, function(x) sum(is.na(x)))
avi_na[avi_na >0]

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
  ggplot(aes(x=factor(region), y=deal_probability, fill= region)) +
  geom_boxplot() + theme_bw() + 
  labs(x='Region', y="Deal Probablity", title="Distribution of Deal Probablity") + 
  theme(axis.text.x = element_text(angle=90, hjust = 1))


# city --------------------------------------------------------------------

city <-c("Краснодар","Екатеринбург","Новосибирск","Ростов-на-Дону","Нижний Новгород",
         "Челябинск","Пермь","Казань","Самара","Омск")

city_en <-c("Krasnodar","Ekaterinburg","Novosibirsk","Rostov-na-Donu",
            "Nizhny Novgorod", "Chelyabinsk","Permian","Kazan","Samara","Omsk")

df_city_en <- as.data.frame(cbind(city,city_en) )

avi %>% group_by(city) %>% summarise(Count = n()) %>%
  arrange(desc(Count)) %>% head(10) %>% left_join(df_city_en) %>% 
  mutate(city_en = reorder(city_en, Count)) %>% 
  ggplot(aes(x=city_en, y=Count)) + 
  labs(x='City', y= 'Count', title = 'Most Popular City') + 
  geom_col() + coord_flip() + theme_wsj()

avi %>% group_by(city) %>% summarise(Count = n()) %>%
  arrange(desc(Count)) %>% head(10) %>% left_join(df_city_en) %>% datatable()
  

# category ----------------------------------------------------------------
category_name <- c("Одежда, обувь, аксессуары",
                   "Детская одежда и обувь",
                   "Товары для детей и игрушки",
                   "Квартиры",
                   "Телефоны",
                   "Мебель и интерьер",
                   "Предложение услуг",
                   "Автомобили",
                   "Ремонт и строительство",
                   "Бытовая техника",
                   "Недвижимость за рубежом",
                   "Квартиры",
                   "Дома, дачи, коттеджи",
                   "Земельные участки",
                   "Комнаты",
                   "Грузовики и спецтехника",
                   "Готовый бизнес",
                   "Гаражи и машиноместа",
                   "Коммерческая недвижимость")

category_name_en <- c("Clothes,shoes accessories" , 
                      "Children's clothing and footwear" ,
                      "Goods for children and toys" , 
                      "Apartments" , 
                      "Phones",
                      "Furniture and interior",
                      "Offer of services",
                      "Cars",
                      "Repair and construction",
                      "Appliances",
                      "Property Abroad", "Apartments", 
                      "Houses, cottages, cottages",
                      "Land",
                      "Rooms",
                      "Trucks and special equipment",
                      "Ready business", 
                      "Garages and parking places",
                      "Commercial Property")

df_category_en <- as.data.frame(cbind(category_name,category_name_en ) )


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
