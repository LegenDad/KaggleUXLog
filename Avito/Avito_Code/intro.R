
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
glimpse(avi)
glimpse(avite)
summary(avi)
# datatable(head(avi, 50))

head(avi, 50) %>% datatable(filter = 'top', 
                            options = list(pageLength = 10, autoWidth = T))

avi_na <- sapply(avi, function(x) sum(is.na(x)))
avite_na <- sapply(avite, function(x) sum(is.na(x)))
avi_na[avi_na >0]; avite_na[avite_na >0]

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
options(scipen=100)
range(avi$price, na.rm= T)
summary(avi$price)
summary(avite$price)
table(avi$user_type)
table(avite$user_type)
prop.table(table(avi$user_type))
prop.table(table(avite$user_type))

# intro_checkpoint --------------------------------------------------------
colnames(avi); colnames(avite)
avi_na[avi_na >0]; avite_na[avite_na >0]
summary(avi$price)
summary(avite$price)
table(avi$user_type)
range(avi$activation_date)
range(avite$activation_date)
# item_id
sum(unique(avi))




# item_id -----------------------------------------------------------------


sum(duplicated(avi$item_id))
sum(duplicated(avite$item_id))
length(unique(avi$item_id)) == nrow(avi)
length(unique(avite$item_id)) == nrow(avite)

# user_id -----------------------------------------------------------------
length(unique(avi$user_id)) / nrow(avi)
length(unique(avite$user_id)) / nrow(avi)

avi %>% group_by(user_id) %>% summarise(Count=n()) %>% 
  arrange(desc(Count)) %>% head(20) %>% 
  ggplot(aes(x=reorder(user_id, Count), y=Count)) + 
  geom_col(fill="steelblue") + coord_flip() +
  labs(x="User ID", y="Count", title = "Most Popular User ID")



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
  arrange(desc(Count)) %>% head(10)  

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
                      "Property Abroad", 
                      "Houses, cottages, cottages",
                      "Land",
                      "Rooms",
                      "Trucks and special equipment",
                      "Ready business", 
                      "Garages and parking places",
                      "Commercial Property")

df_category_en <- as.data.frame(cbind(category_name,category_name_en ) )

avi %>% group_by(category_name) %>% summarise(Count = n()) %>%
  arrange(desc(Count)) %>% head(10) %>% left_join(df_category_en) %>% 
  ggplot(aes(x=reorder(category_name_en, Count), y=Count)) + 
  geom_col(fill = "lightblue") + coord_flip() + theme_bw() + 
  labs(x='Category', y='Count', title='Most Popular Category') + 
  geom_text(aes(x=category_name_en, y= 5000, 
                label= paste(round(Count*100/nrow(avi),1), "%")), 
            hjust = 0, vjust=.5, fontface='bold')
  

# parent category ---------------------------------------------------------

parent_category_name <- c("Личные вещи","Для дома и дачи",
                          "Бытовая электроника","Недвижимость",
                          "Хобби и отдых","Транспорт",
                          "Услуги","Животные","Для бизнеса")

parent_category_name_en <- c("Personal things","home and cottages",
                             "Consumer electronics","Property",
                             "Hobbies and Recreation","Transport",
                             "services","Animals","business")

df_parentcategory_en <- as.data.frame(cbind(parent_category_name,parent_category_name_en ) )

avi %>% group_by(parent_category_name) %>% summarise(Count = n()) %>% 
  left_join(df_parentcategory_en) %>% arrange(desc(Count)) %>% 
  ggplot(aes(x=reorder(parent_category_name_en, Count), y=Count)) + 
  geom_col(fill="lightblue") + coord_flip() + theme_bw() + 
  labs(x="Parent Category", y="Count", title = "Most Popular Parent Category") + 
  geom_text(aes(x=parent_category_name_en, y = 5000, label= paste(round(Count*100/nrow(avi),1), "%")  ), 
            hjust=0, vjust =.5, fontface='bold')

# image_top_1 --------------------------------------------------------------
range(avi$image_top_1, na.rm=T)
summary(avi$image_top_1)
avi %>% filter(!is.na(image_top_1)) %>% group_by(image_top_1) %>%
  summarise(Count = n()) %>% arrange(desc(Count)) %>% head(10) %>% 
  ggplot(aes(x=reorder(image_top_1, Count), y=Count)) + 
  geom_col(fill = "lightblue") + coord_flip() + theme_bw() + 
  labs(x='image_top_1', y='Count', title="Most Popular ImageCode") + 
  geom_text(aes(x=factor(image_top_1), y=5000, 
                label = paste(round(Count*100/nrow(avi),2), "%")), 
            hjust=0, vjust=.5, fontface='bold')

summary(avi$deal_probability)
boxplot(avi$deal_probability)
avi %>% filter(!is.na(image_top_1) & deal_probability > .2) %>% group_by(image_top_1) %>%
  summarise(Count = n()) %>% arrange(desc(Count)) %>% head(10) %>% 
  ggplot(aes(x=reorder(image_top_1, Count), y=Count)) + 
  geom_col(fill = "lightblue") + coord_flip() + theme_bw() + 
  labs(x='image_top_1', y='Count', title="Most Popular ImageCode") + 
  geom_text(aes(x=factor(image_top_1), y=2000, 
                label = paste(round(Count*100/nrow(avi),2), "%")), 
            hjust=0, vjust=.5, fontface='bold')


# param1 ------------------------------------------------------------------
# intro2.R 



