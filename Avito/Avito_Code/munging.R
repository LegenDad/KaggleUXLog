
# int ---------------------------------------------------------------------

library(tidyverse)
library(knitr)
library(skimr)
library(DT)
library(lubridate)
avi <- read_csv("../input/train.csv")
# avite <- read_csv("../input/test.csv")


# NA Check ---------------------------------------------------------------------


# avite_na <- sapply(avite, function(x) sum(is.na(x)))
# avite_na[avite_na > 0]
avi_na <- sapply(avi, function (x) sum(is.na(x)))
avi_na[avi_na>0]
# p1_na, p2_na, p3_na, dsc_na, price_na, img_na, img_t1_na
# test; dsc_na X

# p1.p2,p3 try----------------------------------------------------------------

# avi$p1_na <- is.na(avi$param_1) %>% as.integer()
# avi$p2_na <- is.na(avi$param_2) %>% as.integer()
# avi$p3_na <- is.na(avi$param_3) %>% as.integer()
# table(avi$p1_na)
# table(avi$p2_na)
# table(avi$p3_na)
# str(avi$param_1)
# head(sort(table(avi$param_1), decreasing = T), 7)
# avi <- avi %>% mutate(param_1 = param_1 %>% factor() %>% as.integer(), 
#                       param_2 = as.integer(factor(param_2)), 
#                       param_3 = as.integer(factor(param_3)))
# head(sort(table(avi$param_3), decreasing = T), 7)
# sort(table(avi$param_3), decreasing = T)
# 
# avi <- avi %>% replace_na(list(param_1 = -1, param_2 = -1, param_3 =-1))
# nrow(avi[avi$param_1 ==-1, ]) == sum(avi$p1_na)
# nrow(avi[avi$param_2 ==-1, ]) == sum(avi$p2_na)
# nrow(avi[avi$param_3 ==-1, ]) == sum(avi$p3_na)
# avi_na2 <- sapply(avi, function (x) sum(is.na(x)))
# avi_na2[avi_na2>0]
# str(avi$param_1)
# range(avi$param_1)
# range(avi$param_2)
# range(avi$param_3)
# 
# pie(table(avi$param_1))
# pie(table(avi$param_2))
# pie(table(avi$param_3))
# 
# head(sort(table(avi$param_3), decreasing = T), 300)
# head(sort(table(avi$param_3), decreasing = T), 250)
# 1503424 * 0.00005


# p1, p2, p3 retry --------------------------------------------------------
avi$p1_na <- is.na(avi$param_1) %>% as.integer()
avi$p2_na <- is.na(avi$param_2) %>% as.integer()
avi$p3_na <- is.na(avi$param_3) %>% as.integer()
avi <- avi %>% mutate(param_1 = param_1 %>% factor() %>% as.integer(), 
                      param_2 = param_2 %>% factor() %>% as.integer(), 
                      param_3 = param_3 %>% factor() %>% 
                        fct_lump(prop = 0.00005) %>% as.integer())
avi <- avi %>% replace_na(list(param_1 = 0, param_2 = 0, param_3 = 0))
nrow(avi[avi$param_1 ==-1, ]) == sum(avi$p1_na)
nrow(avi[avi$param_2 ==-1, ]) == sum(avi$p2_na)
nrow(avi[avi$param_3 ==-1, ]) == sum(avi$p3_na)
avi_na2 <- sapply(avi, function (x) sum(is.na(x)))
avi_na2[avi_na2>0]

pie(table(avi$param_1))
pie(table(avi$param_2))
pie(table(avi$param_3))
avi %>% select(param_1:param_3) %>% skim()
avi %>% select(contains("param")) %>% skim()

# dsc ---------------------------------------------------------------------

# dsc_na, price_na, img_na, img_t1_na
# test; dsc_na X
avi$dsc_na <- is.na(avi$description) %>% as.integer()

avi$dsc_len = str_length(avi$description)
range(avi$dsc_len, na.rm=T)
avi$dsc_capE = str_count(avi$description, "[A-Z]")
range(avi$dsc_capE)
range(avi$dsc_capE, na.rm=T)
avi$dsc_capR = str_count(avi$description, "[А-Я]")
range(avi$dsc_capR, na.rm = T)
avi$dsc_cap = str_count(avi$description, "[A-ZА-Я]")
range(avi$dsc_cap, na.rm=T)
avi <- avi %>% replace_na(list(dsc_len =0 , dsc_capE=0, dsc_capR=0, dsc_cap=0))
range(avi$dsc_cap)
range(avi$dsc_capE)
range(avi$dsc_capR)
avi$dsc_pun = str_count(avi$description, "[[:punct:]]")
range(avi$dsc_pun, na.rm = T)
avi$dsc_dig = str_count(avi$description, "[[:digit:]]")
range(avi$dsc_dig, na.rm = T)
avi <- avi %>% replace_na(list(dsc_pun=0, dsc_dig=0))
range(avi$dsc_pun)
table(avi$dsc_pun)
avi %>% select(contains("dsc")) %>% skim()
pie(table(avi$dsc_len))
boxplot(avi$dsc_len)
pie(table(avi$dsc_na))
pie(table(avi$dsc_cap))
pie(table(avi$dsc_capE))
pie(table(avi$dsc_capR))
pie(table(avi$dsc_dig))
pie(table(avi$dsc_pun))

# price -------------------------------------------------------------------

# dsc_na, price_na, img_na, img_t1_na
# test; dsc_na X

# log x , log(1+x)  google seach graph check

range(avi$price, na.rm=T)
# avi$price <- log(avi$price)
avi$price <-log1p(avi$price)
avi <- avi %>% replace_na(list(price = -1))  # -1 or 0 check
skim(avi$price)
head(table(avi$price))

# img ---------------------------------------------------------------------

# dsc_na, price_na, img_na, img_t1_na
# test; dsc_na X


avi$img_na <- is.na(avi$image) %>% as.integer()

range(avi$image_top_1, na.rm = T)

avi <- avi %>% replace_na(list(image_top_1 = -1))
table(avi$image_top_1)
length(unique(avi$image_top_1))

avi_na3 <- sapply(avi, function (x) sum(is.na(x)))


# user_id ------------------------------------------------------------------

# [1] "item_id"              "user_id"              "region"              
# [4] "city"                 "parent_category_name" "category_name"       
# [7] "param_1"              "param_2"              "param_3"             
# [10] "title"                "description"          "price"               
# [13] "item_seq_number"      "activation_date"      "user_type"           
# [16] "image"                "image_top_1"          "deal_probability"    

length(unique(avi$user_id))
771769 / 150324

avi %>% add_count(user_id) %>% group_by(n) %>% summarise(count= n())
sqrt(237)
150324 * 0.00002

avi %>% add_count(user_id) %>% summarize(count = n_distinct(n))

avi <- avi %>% mutate(user_id = factor(user_id) %>% 
                        fct_lump(prop = 0.00002) %>% as.integer())

avi %>% group_by(user_id) %>% summarise(count = n()) %>% arrange(desc(count))
range(avi$user_id)
table(avi$user_id)


# region ------------------------------------------------------------------
avi %>% group_by(region) %>% summarise(count=n())
pie(table(avi$region))

avi <- avi %>% mutate(region = factor(region) %>% as.integer())


# city --------------------------------------------------------------------

avi %>% group_by(city) %>% summarise(count=n()) %>% arrange(desc(count))
avi %>% group_by(city) %>% summarise(count=n()) %>% arrange(desc(count)) %>% datatable()
1503424 * 0.0003

avi <- avi %>% mutate(city = factor(city) %>% 
                        fct_lump(prop = 0.0003) %>% as.integer())



# parent_category_name ----------------------------------------------------

avi %>% group_by(parent_category_name) %>% summarise(count=n())

avi <- avi %>% mutate(parent_category_name = factor(parent_category_name) %>% 
                        as.integer())


# category_name -----------------------------------------------------------

avi %>% group_by(category_name) %>% summarise(count=n())

avi <- avi %>% mutate(category_name = factor(category_name) %>% as.integer())


# param_1,2,3 -------------------------------------------------------------

# p1, p2, p3 retry 


# title -------------------------------------------------------------------

avi %>% select(contains("dsc")) %>% colnames()
# "dsc_na"   "dsc_len"  "dsc_capE" "dsc_capR" "dsc_cap"  "dsc_pun"  "dsc_dig" 

avi <- avi %>% mutate(title_len = str_length(title), 
                      title_capE = str_count(title, "[A-Z]"), 
                      title_capR = str_count(title, "[А-Я]"),
                      title_cap = str_count(title, "[A-ZА-Я]"),
                      title_pun = str_count(title, "[[:punct:]]"), 
                      title_dig = str_count(title, "[[:digit:]]")
                      )


avi %>% select(contains("title")) %>% skim()


# description, price -------------------------------------------------------------

# dsc, price section


# item_seq_number ---------------------------------------------------------

glimpse(avi$item_seq_number)
avi %>% group_by(item_seq_number) %>% summarize(cnt = n()) %>% arrange(desc(cnt))

# activation_date ---------------------------------------------------------

head(avi$activation_date)
range(avi$activation_date)
avi <- avi %>% mutate(mday = mday(activation_date), 
                      wday = wday(activation_date))
avi %>% select(contains("day")) %>% head()



# user_type ---------------------------------------------------------------

table(avi$user_type)

avi <- avi %>% mutate(user_type = factor(user_type))

avi %>% select(contains("user")) %>% head



# image, image_top1 -------------------------------------------------------

# img section



# join -------------------------------------------------------------

avi <- avi %>% mutate(txt = paste(title, description, sep = " "))




# NA recheck --------------------------------------------------------------

sapply(avi, function (x) sum(is.na(x)))



# drop variables ----------------------------------------------------------

avi <- avi %>% select(-item_id, -image, -title, -description, -activation_date)

head(avi)

glimpse(avi)


# txt ---------------------------------------------------------------------
library(magrittr)
library(tokenizers)
library(text2vec)
library(stopwords)


avi$txt %>% str_to_lower() %>% head()
avi %$% head(txt)

avi %>% head %$% str_to_lower(txt)
avi %>% head %$% str_to_lower(txt, "ru")
avi %>% tail %$% str_to_lower(txt)

avi %$% head(txt) %>% str_replace_all("[[:alpha:]]", " ")
avi %$% head(txt) %>% str_replace_all("[^[:alpha:]]", " ")

avi %$% head(txt) %>% str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ")


avi %$% head(txt) %>% str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ") %>% tokenize_word_stems(language = "russian")


avi %$% head(txt) %>% str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ") %>% tokenize_word_stems(language = "russian") %>% 
  itoken()

avi %$% head(txt) %>% str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ") %>% word_tokenizer(language = "russian")

it <- avi %$% head(txt) %>% str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ") %>% tokenize_word_stems(language = "russian") %>% 
  itoken()

it
str(it)
vect <- create_vocabulary(it, ngram = c(1, 1), stopwords = stopwords("ru")) %>%
  prune_vocabulary(term_count_min = 1, doc_proportion_max = 0.4, vocab_term_max = 12500) %>%
  vocab_vectorizer()
m_tfidf <- TfIdf$new(norm = "l2", sublinear_tf = T)
tfidf <-  create_dtm(it, vect) %>%
  fit_transform(m_tfidf)



?itoken
?prune_vocabulary

foo <- create_vocabulary(it, ngram = c(1, 1), stopwords = stopwords("ru"))
foo2 <- create_vocabulary(it, stopwords = stopwords("ru"))
foo == foo2
identical(foo, foo2)
identical(5, 5.0)
foo3 <- create_vocabulary(it, ngram = c(1, 2), stopwords = stopwords("ru"))
foo4 <- create_vocabulary(it, ngram = c(1, 3), stopwords = stopwords("ru"))
identical(foo, foo3)
View(foo4)
args(prune_vocabulary)
foobar <- prune_vocabulary(foo, term_count_min = 2)
foobar2 <- prune_vocabulary(foo, term_count_min = 2, doc_proportion_max = .2)
foobar3 <- prune_vocabulary(foo, term_count_min = 2, doc_proportion_min = .2)
foobar4 <- prune_vocabulary(foo, term_count_min = 2, vocab_term_max = 5)
?vocab_vectorizer
foobar5 <- vocab_vectorizer(foobar4)
# it <- tr_te %$%
#   str_to_lower(txt) %>%
#   str_replace_all("[^[:alpha:]]", " ") %>%
#   str_replace_all("\\s+", " ") %>%
#   tokenize_word_stems(language = "russian") %>% 
#   itoken()
# vect <- create_vocabulary(it, ngram = c(1, 1), stopwords = stopwords("ru")) %>%
#   prune_vocabulary(term_count_min = 3, doc_proportion_max = 0.4, vocab_term_max = 12500) %>% 
#   vocab_vectorizer()



# library(xgboost)
# library(Matrix)
# library(stringi)
# library(forcats)
avi100 <- avi %>% head(100)

# it <- avi100 %$%
#   str_to_lower(txt) %>%
#   str_replace_all("[^[:alpha:]]", " ") %>%
#   str_replace_all("\\s+", " ") %>%
#   tokenize_word_stems(language = "russian") %>%
#   itoken()

# vect <- create_vocabulary(it, ngram = c(1, 1), stopwords = stopwords("ru")) %>%
#   prune_vocabulary(term_count_min = 3, doc_proportion_max = 0.4, vocab_term_max = 12500) %>%
#   vocab_vectorizer()

# m_tfidf <- TfIdf$new(norm = "l2", sublinear_tf = T)
# tfidf <-  create_dtm(it, vect) %>%
#   fit_transform(m_tfidf)
# 
# rm(it, vect, m_tfidf); gc()
# 
dim(avi100)
library(Matrix)
dim(X)
glimpse(avi100)
library(skimr)
skim(avi100)


X <- avi100 %>%
  select(-txt) %>%
  sparse.model.matrix(~ . - 1, .) %>%
  cbind(tfidf)

dim(tfidf)
dim(sparse.model.matrix(~ . - 1, avi100))
dim(head(avi,100))
# #---------------------------
# cat("Preparing data...\n")
# X <- tr_te %>% 
#   select(-txt) %>% 
#   sparse.model.matrix(~ . - 1, .) %>% 
#   cbind(tfidf)
# 
# rm(tr_te, tfidf); gc()
# 
# dtest <- xgb.DMatrix(data = X[-tri, ])
# X <- X[tri, ]; gc()
# tri <- caret::createDataPartition(y, p = 0.9, list = F) %>% c()
# dtrain <- xgb.DMatrix(data = X[tri, ], label = y[tri])
# dval <- xgb.DMatrix(data = X[-tri, ], label = y[-tri])
# cols <- colnames(X)
# 
# rm(X, y, tri); gc()
# 
# #---------------------------
# cat("Training model...\n")
# p <- list(objective = "reg:logistic",
#           booster = "gbtree",
#           eval_metric = "rmse",
#           nthread = 8,
#           eta = 0.05,
#           max_depth = 18,
#           min_child_weight = 11,
#           gamma = 0,
#           subsample = 0.8,
#           colsample_bytree = 0.7,
#           alpha = 2.25,
#           lambda = 0,
#           nrounds = 5000)
# 
# m_xgb <- xgb.train(p, dtrain, p$nrounds, list(val = dval), print_every_n = 10, early_stopping_rounds = 50)
# 
# xgb.importance(cols, model = m_xgb) %>%   
#   xgb.plot.importance(top_n = 35)
# 
# #---------------------------
# cat("Creating submission file...\n")
# read_csv("../input/sample_submission.csv")  %>%  
#   mutate(deal_probability = predict(m_xgb, dtest)) %>%
#   write_csv(paste0("xgb_tfidf", m_xgb$best_score, ".csv"))