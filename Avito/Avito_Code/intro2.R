
# preparation -------------------------------------------------------------

library(tidyverse)
library(knitr)
library(skimr)
library(DT)
library(ggthemes)
avi <- read_csv("../input/train.csv")
avite <- read_csv("../input/test.csv")
avi_na <- sapply(avi, function(x) sum(is.na(x)))
avi_na[avi_na>0]

# param1 ------------------------------------------------------------------
param_1 <- c("Женская одежда","Для девочек","Для мальчиков",
             "Продам","С пробегом","Аксессуары",
             "Мужская одежда","Другое",
             "Игрушки","Детские коляски")

param_1_en <- c("Women's clothing","For girls","For boys",
                "Selling","With mileage","Accessories","Men's clothing","Other",
                "Toys","Baby carriages")

df_param_1_en <- as.data.frame(cbind(param_1,param_1_en ) )

avi %>% filter(!is.na(param_1)) %>% group_by(param_1) %>% 
  summarise(Count = n()) %>% arrange(desc(Count)) %>% head(10) %>% 
  left_join(df_param_1_en) %>% kable()

avi %>% filter(!is.na(param_1)) %>% group_by(param_1) %>% 
  summarise(Count = n()) %>% arrange(desc(Count)) %>% head(10) %>% 
  left_join(df_param_1_en) %>% 
  ggplot(aes(x = reorder(param_1_en, Count), y= Count)) + 
  geom_col(fill='lightblue') + coord_flip() + theme_bw() + 
  labs(x = 'Param_1', y = 'Count', title = 'Most Poupular Param 1') + 
  geom_text(aes(x=param_1_en, y = 10000, 
                label = paste(round(Count*100/nrow(avi),1), "%")), 
            hjust=0, vjust=.5, fontface='bold')


# param_2 -----------------------------------------------------------------

param_2 <- c("Обувь","Верхняя одежда",
             "Платья и юбки","Другое",
             "Трикотаж","Брюки",
             "1","2","На длительный срок","Дом")

param_2_en <- c("Footwear","Outerwear","Dresses and skirts","Other",
                "Knitwear","Pants","1","2","For a long time","House")

df_param_2_en <- as.data.frame(cbind(param_2,param_2_en ) )

avi %>% filter(!is.na(param_2)) %>% group_by(param_2) %>% 
  summarise(Count = n()) %>% arrange(desc(Count)) %>% head(10) %>% 
  left_join(df_param_2_en) %>% datatable()

avi %>% filter(!is.na(param_2)) %>% group_by(param_2) %>% 
  summarise(Count = n()) %>% arrange(desc(Count)) %>% head(10) %>% 
  left_join(df_param_2_en) %>% 
  ggplot(aes(x=reorder(param_2_en, Count), y = Count)) + 
  geom_col(fill='lightblue') + coord_flip() + theme_bw() + 
  labs(x='Param_2', y='Count', title='Most Popular Param 2') + 
  geom_text(aes(x=param_2_en, y=10000, 
                label = paste(round(Count*100/nrow(avi),1), "%")), 
            hjust = 0, vjust=.5, fontface = 'bold')




# param_3 -----------------------------------------------------------------

avi %>% filter(!is.na(param_3)) %>% group_by(param_3) %>% 
  summarise(Count = n()) %>% arrange(desc(Count)) %>% head(10) %>% datatable()

avi %>% filter(!is.na(param_3)) %>% group_by(param_3) %>% 
  summarise(Count = n()) %>% arrange(desc(Count)) %>% head(10) %>%
  ggplot(aes(x=reorder(param_3, Count), y=Count)) + 
  geom_col(fill='lightblue') + coord_flip() + theme_bw() + 
  labs(x='Param 3', y='Count', title='Most Popular Param 3') + 
  geom_text(aes(x=param_3, y=5000, 
                label = paste(round(Count*100/nrow(avi),1) , "%")), 
            hjust=0, vjust=.5, fontface='bold')



# title ; Do Not run in Local--------------------------------------------------------
title <- c("Платье","Туфли","Куртка",
           "Пальто","Джинсы","Комбинезон",
           "Кроссовки","Костюм","Ботинки",
           "Босоножки")

title_en <- c("Dress","Shoes","Jacket",
              "Coat","Jeans","Overalls",
              "Sneakers","Costume","Boots",
              "Sandals")

df_title_en <- as.data.frame(cbind(title,title_en) )

avi %>% group_by(title) %>% summarise(Count=n()) %>%
  arrange(desc(Count)) %>% head(10) %>% left_join(df_title_en) %>% kable()

avi %>% group_by(title) %>% summarise(Count=n()) %>%
  arrange(desc(Count)) %>% head(10) %>% left_join(df_title_en) %>% 
  ggplot(aes(x=reorder(title_en, Count), y=Count)) + 
  geom_col(fill='lightblue') + coord_flip() + theme_bw() + 
  labs(x='Title', y='Count', title='Most Popular Title') + 
  geom_text(aes(x=title_en, y=2000, 
                label = paste(round(Count*100/nrow(avi),1) , "%")), 
            hjust=0, vjust=.5, fontface='bold')

  



# image -------------------------------------------------------------------
avi$image_codeYN <- ifelse(is.na(avi$image), 0, 1)
prop.table(table(avi$image_codeYN))
avite$image_codeYN <- ifelse(is.na(avite$image), 0, 1)
prop.table(table(avite$image_codeYN))

avi %>% group_by(image_codeYN) %>% summarise(Count = n()) %>% 
  ggplot(aes(x=factor(image_codeYN), y=Count)) + 
  geom_col(fill='lightblue') + theme_wsj() + 
  labs(x="image_codeYN", y="Count", title="Image Code Y/N Count") + 
  geom_text(aes(x=factor(image_codeYN), y=500000, 
                label= paste0(Count, "\n\n\n", 
                              round(Count*100/nrow(avi),1), "%")))
avite %>% group_by(image_codeYN) %>% summarise(Count = n()) %>% 
  ggplot(aes(x=factor(image_codeYN), y=Count)) + 
  geom_col(fill='lightblue') + theme_wsj() + 
  labs(x="image_codeYN", y="Count", title="Image Code Y/N Count") + 
  geom_text(aes(x=factor(image_codeYN), y=100000, 
                label= paste0(Count, "\n\n\n", 
                              round(Count*100/nrow(avi),1), "%")))

ggplot(data=avi, aes(x=factor(image_codeYN), y=deal_probability)) +
  geom_boxplot(fill=c("lightgreen", "lightblue")) + theme_wsj() + 
  labs(x="image_codeYN", y="Deal Probability", 
       title = "Distribution of Deal Probability on ImageCode")
  

# Duration of Ad ---------------------------------------------------------------------
periods_tr <- read_csv("../input/periods_train.csv")
head(periods_tr)
glimpse(periods_tr)

periods_tr$duration_ad <- as.integer(periods_tr$date_to - periods_tr$date_from)

ggplot(periods_tr, aes(x=duration_ad)) + 
  geom_bar(fill = "lightblue") + theme_bw() +
  labs(x="Duration of AD", y="Count", title = "Distribution of Duration of AD")
  
summary(periods_tr$duration_ad)

periods_te <- read_csv("../input/periods_test.csv")
head(periods_te)
glimpse(periods_te)

periods_te$duration_ad <- as.integer(periods_te$date_to - periods_te$date_from)

ggplot(periods_te, aes(x=duration_ad)) + 
  geom_bar(fill = "lightblue") + theme_bw() +
  labs(x="Duration of AD", y="Count", title = "Distribution of Duration of AD")

summary(periods_te$duration_ad)



# Deal Probablity ---------------------------------------------------------



# unname ------------------------------------------------------------------
glimpse(avi)
TotalNumberOfRows = nrow(avi)

train <-train %>%
  mutate(title_len = str_count(title)) %>%
  mutate(description_len = str_count(description))

test <-test %>%
  mutate(title_len = str_count(title)) %>%
  mutate(description_len = str_count(description))
