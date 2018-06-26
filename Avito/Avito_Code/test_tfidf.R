
a01 <- "The snow glows white on the mountain tonight"
a02 <- "Not a footprint to be seen"
a03 <- "A kingdom of isolation"
a04 <- "And it looks like I'm the queen"
a05 <- "The wind is howling like this swirling storm inside"
a06 <- "Couldn't keep it in, heaven knows I've tried"
a07 <- "Don't let them in, don't let them see"
a08 <- "Be the good girl you always have to be"
a09 <- "Conceal, don't feel, don't let them know"
a10 <- "Well, now they know"
a11 <- "Let it go, let it go"
a12 <- "Can't hold it back anymore"
a14 <- "Turn away and slam the door"
a15 <- "I don't care what they're going to say"
a16 <- "Let the storm rage on"
a17 <- "The cold never bothered me anyway"

dd <- data.frame(a=c(1:17), b=NA)
dd$b <- c(a01, a02, a03, a04, a05, a06, 
               a07, a08, a09, a10, a11, a12, 
               a13, a14, a15, a16, a17)

library(magrittr)
library(text2vec)
library(tokenizers)

dd %$% str_to_lower(b) %>% str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ") %>% word_tokenizer()

dd %$% str_to_lower(b) %>% str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ") %>% tokenize_words()

dd %$% str_to_lower(b) %>% str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ") %>% tokenize_word_stems()


it1 <- dd %$% str_to_lower(b) %>% str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ") %>% word_tokenizer() %>% itoken()

it2 <- dd %$% str_to_lower(b) %>% str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ") %>% tokenize_words() %>% itoken()

it3 <- dd %$% str_to_lower(b) %>% str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ") %>% tokenize_word_stems() %>% itoken()

identical(it1, it2)
identical(it1, it3)
identical(it2, it3)

library(stopwords)
vect1 <- create_vocabulary(it1, ngram = c(1, 1), 
                           stopwords = stopwords("en")) %>%
  prune_vocabulary(term_count_min = 1, doc_proportion_max = 0.4) %>%
  vocab_vectorizer()

vect2 <- create_vocabulary(it2, ngram = c(1, 1), 
                           stopwords = stopwords("en")) %>%
  prune_vocabulary(term_count_min = 1, doc_proportion_max = 0.4) %>%
  vocab_vectorizer()

vect3 <- create_vocabulary(it3, ngram = c(1, 1), 
                           stopwords = stopwords("en")) %>%
  prune_vocabulary(term_count_min = 3, doc_proportion_max = 0.4) %>%
  vocab_vectorizer()
identical(vect1, vect2)
identical(vect1, vect3)
identical(vect2, vect3)

# tokenization vs stemming 
# swirling vs swirl
# going vs go

dd
dd %$% str_to_lower(b) %>% str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ") %>% tokenize_word_stems()

it <- dd %$% str_to_lower(b) %>% str_replace_all("[^[:alpha:]]", " ") %>% 
  str_replace_all("\\s+", " ") %>% tokenize_word_stems() %>% 
  itoken()

it$iterable
it$length


create_vocabulary(it)
create_vocabulary(it, stopwords = stopwords("en"))
# create_vocabulary(it, ngram = c(2,2), stopwords = stopwords("en"))

create_vocabulary(it, stopwords = stopwords("en")) %>% 
  prune_vocabulary()
create_vocabulary(it, stopwords = stopwords("en")) %>% 
  prune_vocabulary(term_count_min = 3)
create_vocabulary(it, stopwords = stopwords("en")) %>% 
  prune_vocabulary(term_count_min = 3, doc_proportion_max = 0.4)
create_vocabulary(it, stopwords = stopwords("en")) %>% 
  prune_vocabulary(term_count_min = 3, doc_proportion_max = 0.4, 
                   vocab_term_max = 2)

create_vocabulary(it, stopwords = stopwords("en")) %>% 
  prune_vocabulary(term_count_min = 2)

create_vocabulary(it, stopwords = stopwords("en")) %>% 
  prune_vocabulary(term_count_min = 3)

create_vocabulary(it, stopwords = stopwords("en")) %>% 
  prune_vocabulary(term_count_min = 3) %>% vocab_vectorizer()


vect <- create_vocabulary(it, stopwords = stopwords("en")) %>% 
  prune_vocabulary(term_count_min = 3) %>% vocab_vectorizer()

vect


m_tfidf1 <- TfIdf$new()
m_tfidf2 <- TfIdf$new(norm = "l2")
m_tfidf3 <- TfIdf$new(norm = "l2", sublinear_tf = T)
create_dtm(it, vect)
create_dtm(it, vect) %>% fit_transform(m_tfidf1)
create_dtm(it, vect) %>% fit_transform(m_tfidf2)
create_dtm(it, vect) %>% fit_transform(m_tfidf3)
tf <- create_dtm(it, vect) %>% fit_transform(m_tfidf3)

library(Matrix)

m_tfidf <- TfIdf$new(norm = "l2", sublinear_tf = T)

identical(tfidf1, tfidf2)
identical(tfidf1, tfidf3)
identical(tfidf2, tfidf3)
sum(tfidf1)
sum(tfidf2)
sum(tfidf3)

dd %>% sparse.model.matrix(~.-1, .) %>% cbind(tfidf3)
dd %>% sparse.model.matrix(~.-1, .)
dd %>% sparse.model.matrix(~.-1, .) %>% cbind(tf)
