
# preparation -------------------------------------------------------------

library(tidyverse)
library(knitr)
library(skimr)
library(DT)
library(ggthemes)
library(lubridate)
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
  left_join(df_param_1_en) %>% datatable()

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



# title ; Do Not run in Win--------------------------------------------------------
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


# title legnth------------------------------------------------------------
avi %>% mutate(title_len = str_count(title)) %>% 
  ggplot(aes(x=title_len)) + geom_histogram(bins = 30, fill='lightblue') +
  labs(x='Title Length', y='Count', title='train : Distibution of Title Length')

avite %>% mutate(title_len = str_count(title)) %>% 
  ggplot(aes(x=title_len)) + geom_histogram(bins = 30, fill='lightblue') +
  labs(x='Title Length', y='Count', title='test : Distibution of Title Length')

# description -------------------------------------------------------------

avi %>% mutate(des_len = str_count(description)) %>% 
  filter(des_len < 1000) %>% 
  ggplot(aes(x=des_len)) + geom_histogram(bins=30, fill = 'lightblue')

# price -------------------------------------------------------------------

skim(avi$price) %>% kable()
avi %>% filter(!is.na(price)) %>% ggplot(aes(x=price)) + geom_histogram(bins=50)

avi %>% filter(!is.na(price)) %>% ggplot(aes(x=price)) + 
  geom_histogram(bins=50, fill = 'steelblue')  + 
  labs(title="Price Log Graph") + 
  scale_x_log10() + scale_y_log10() + theme_wsj()

avi %>% filter(!is.na(price)) %>% ggplot(aes(x=price, fill=user_type)) + 
  geom_histogram(bins=50)  + 
  labs(x='price', y='count', title="Price Log Graph") + 
  scale_x_log10() + scale_y_log10() + theme_wsj()

avi %>% filter(!is.na(price)) %>% left_join(df_parentcategory_en) %>% 
  ggplot(aes(x=price, fill=parent_category_name_en)) + 
  geom_histogram(bins=50)  + 
  labs(x='price', y='count', title="Price Log Graph") + 
  scale_x_log10() + scale_y_log10() + theme_wsj()

avite %>% filter(!is.na(price)) %>% ggplot(aes(x=price)) + 
  geom_histogram(bins=50)  + 
  scale_x_log10() + scale_y_log10()



# item_seq_number ----------------------------------------------------------------
skim(avi$item_seq_number)
length(unique(avi$item_seq_number))
range(avi$item_seq_number)

avi %>% ggplot(aes(x=item_seq_number)) + 
  geom_histogram(bins = 30) + scale_x_log10()
avi %>% ggplot(aes(x=item_seq_number, fill=user_type)) + 
  geom_histogram(bins = 30) + scale_x_log10()
  

# activation date ---------------------------------------------------
range(avi$activation_date)
avi %>% mutate(day = day(activation_date)) %>% group_by(day) %>% 
  summarise(Count = n()) %>% 
  datatable(filter = "top", options = list(pageLength = 30, autoWidth= T))

avite %>% mutate(day = day(activation_date)) %>% group_by(day) %>% 
  summarise(Count = n()) %>% 
  datatable(filter = "top", options = list(pageLength = 30, autoWidth= T))

avi %>% mutate(day = day(activation_date)) %>% group_by(day) %>% 
  summarise(Count = n()) %>% 
  ggplot(aes(x=day, y=Count)) + geom_col()


# activation day of week ----------------------------------------------------------
range(avi$activation_date)
avi %>% mutate(wday = wday(activation_date, labe=T, locale="UK")) %>% 
  group_by(wday) %>% summarise(Count=n()) %>%
  ggplot(aes(x=wday, y=Count)) + 
  geom_col(fill='lightblue', col='white') + theme_bw() + 
  labs(x="Activation Weekday", y="Count", title="Activation Weekday")

avite %>% mutate(wday = wday(activation_date, labe=T, locale="UK")) %>% 
  group_by(wday) %>% summarise(Count=n()) %>%
  ggplot(aes(x=wday, y=Count)) + 
  geom_col(fill='lightblue', col='white') + theme_bw() + 
  labs(x="Activation Weekday", y="Count", title="Activation Weekday")

# user type ---------------------------------------------------------------
table(avi$user_type)
avi %>% group_by(user_type) %>% summarise(Count = n()) %>%
  ggplot(aes(x=user_type, y=Count)) + 
  geom_col(color='orange', fill = 'lightblue') + 
  labs(x='User Type', y='Count', title = 'User Type') + 
  geom_text(aes(x=user_type, y= 50000, 
                label = paste(round(Count*100/nrow(avi)), "%")), 
            size = 5, fontface='bold')

avite %>% group_by(user_type) %>% summarise(Count = n()) %>%
  ggplot(aes(x=user_type, y=Count)) + 
  geom_col(color='orange', fill = 'lightblue') + 
  labs(x='User Type', y='Count', title = 'User Type') + 
  geom_text(aes(x=user_type, y= 15000, 
                label = paste(round(Count*100/nrow(avite)), "%")), 
            size = 5, fontface='bold')


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
  


# image_top_1 -------------------------------------------------------------

skim(avi$image_top_1)
ggplot(avi, aes(x=image_top_1)) + geom_histogram(bins = 30)

# Deal Probablity ---------------------------------------------------------
summary(avi$deal_probability)
avi %>% ggplot(aes(x=deal_probability)) + 
  geom_histogram(bins=30, fill = 'lightblue') + theme_wsj() + 
  labs(x="Deal Probability", y= "Count", title = "Distribution of Deal Probability")

avi %>% ggplot(aes(x=deal_probability)) + 
  geom_histogram(bins=10, fill = 'lightblue') + theme_wsj() + 
  labs(x="Deal Probability", y= "Count", title = "Distribution of Deal Probability")

avi %>% ggplot(aes(x=deal_probability)) + 
  geom_histogram(bins=5, fill = 'lightblue') + theme_wsj() + 
  labs(x="Deal Probability", y= "Count", title = "Distribution of Deal Probability")



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


# unname ------------------------------------------------------------------
glimpse(avi)
TotalNumberOfRows = nrow(avi)

train <-train %>%
  mutate(title_len = str_count(title)) %>%
  mutate(description_len = str_count(description))

test <-test %>%
  mutate(title_len = str_count(title)) %>%
  mutate(description_len = str_count(description))


# ---
#   title: "EDA and XGB Avito"
# author: "Bukun"
# output:
#   html_document:
#   number_sections: true
# toc: true
# fig_width: 10
# code_folding: hide
# fig_height: 4.5
# theme: cosmo
# highlight: tango
# ---
#Preparation{.tabset .tabset-fade .tabset-pills}
#{r,message=FALSE,warning=FALSE}