library(tidyverse)
library(knitr)
library(skimr)
library(DT)
library(lubridate)
set.seed(0)
avi <- read_csv("../input/train.csv")
y <- avi$deal_probability

avi <- avi %>% 
  select(-deal_probability) %>% 
  mutate(p1_na = is.na(param_1) %>% as.integer(), 
         p2_na = is.na(param_2) %>% as.integer(), 
         p3_na = is.na(param_3) %>% as.integer(), 
         dsc_na = is.na(description) %>% as.integer(), 
         img_na = is.na(image) %>% as.integer(), 
         dsc_len = str_length(description), 
         dsc_capE = str_count(description, "[A-Z]"), 
         dsc_capR = str_count(description, "[А-Я]"), 
         dsc_cap = str_count(description, "[A-ZА-Я]"), 
         dsc_pun = str_count(description, "[[:punct:]]"), 
         dsc_dig = str_count(description, "[[:digit:]]"), 
         title_len = str_length(title), 
         title_capE = str_count(title, "[A-Z]"), 
         title_capR = str_count(title, "[А-Я]"), 
         title_cap = str_count(title, "[A-ZА-Я]"), 
         title_pun = str_count(title, "[[:punct:]]"), 
         title_dig = str_count(title, "[[:digit:]]"), 
         param_1 = factor(param_1) %>% as.integer(), 
         param_2 = factor(param_2) %>% as.integer(), 
         param_3 = factor(param_3) %>% fct_lump(prop=0.00005) %>% as.integer(), 
         user_id = factor(user_id) %>% fct_lump(prop=0.00002) %>% as.integer(), 
         city = factor(city) %>% fct_lump(prop=0.0003) %>% as.integer(), 
         category_name = factor(category_name) %>% as.integer(), 
         region = factor(region), 
         parent_category_name = factor(parent_category_name), 
         user_type = factor(user_type), 
         mday = mday(activation_date) %>% as.factor(), 
         wday = wday(activation_date) %>% as.factor(),
         price = log1p(price), 
         txt = paste(title, description, sep = " ")) %>% 
  select(-item_id, -image, -title, -description, -activation_date) %>% 
  replace_na(list(param_1 = 0, param_2 =0 , param_3 = 0, 
                  dsc_len = 0, dsc_pun = 0, dsc_dig = 0, 
                  dsc_capE = 0, dsc_capR = 0, dsc_cap = 0, 
                  price = -1, image_top_1 = -1))
  
glimpse(avi)

library(magrittr)
library(tokenizers)
library(text2vec)
library(stopwords)
library(Matrix)
library(pryr)

it <- avi %$% 
  str_to_lower(txt) %>% 
  str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ") %>% 
  tokenize_word_stems(language = "russian") %>% 
  itoken()

vect <- create_vocabulary(it, stopwords = stopwords("ru")) %>%  
  prune_vocabulary(term_count_min = 3, doc_proportion_max = 0.4, 
                   vocab_term_max = 12500) %>% 
  vocab_vectorizer()

m_tfidf <- TfIdf$new(norm = "l2", sublinear_tf = T)
tfidf <- create_dtm(it, vect) %>% fit_transform(m_tfidf)

mem_used()
rm(it, vect, m_tfidf); gc()

X <- avi %>% select(-txt) %>% sparse.model.matrix(~.-1, .) %>% cbind(tfidf)

mem_used()
rm(avi, tfidf); gc()


library(xgboost)
# tri <- caret::createDataPartition(y, p = 0.7, list = F)
# is(tri)
tri <- caret::createDataPartition(y, p = 0.7, list = F) %>% c()
is(tri)
dtest <- xgb.DMatrix(data = X[-tri,])
X <- X[tri,]
idx <- caret::createDataPartition(y[tri], p=0.9, list = F) %>% c()
dtrain <- xgb.DMatrix(data = X[idx,], label = y[tri][idx])
dval <- xgb.DMatrix(data = X[-idx,], label = y[tri][-idx])

# object_size(X)
# object_size(y)
# rm(X, y, tri); gc()

p <- list(objective = "reg:logistic", 
          booster = "gbtree", 
          eval_metric = "rmse", 
          nthread = 8, 
          eta = 0.05, 
          max_depth = 18, 
          min_child_weight = 11, 
          gamma = 0, 
          subsample = 0.8, 
          colsample_bytree = 0.7, 
          alpha = 2.25, 
          lambda = 0, 
          nrounds = 50)

m_xgb <- xgb.train(p, dtrain, p$nrounds, list(val=dval), 
                   print_every_n = 10, early_stopping_rounds = 50)

xgb.importance(colnames(dtrain), m_xgb) %>% xgb.plot.importance(top_n = 20)

pred <- predict(m_xgb, dtest)
range(pred)
?rmse
library(ModelMetrics)
rmse(y[-tri], pred)



#---------------------------
read_csv("../input/sample_submission.csv")  %>%  
  mutate(deal_probability = predict(m_xgb, dtest)) %>%
  write_csv(paste0("xgb_tfidf", m_xgb$best_score, ".csv"))

