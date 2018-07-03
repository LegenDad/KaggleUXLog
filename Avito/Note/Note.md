Avito Demand Prediction Challenge
===


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [My Intro About Avito](#my-intro-about-avito)
* [Feature](#feature)
	* [Categorical](#categorical)
	* [Numerical](#numerical)
	* [Text](#text)
	* [Image](#image)

<!-- /code_chunk_output -->

## My Intro About Avito

Avito Demand Prediction Challenge에 대한 접근 포인트는 순위나 점수 향상을 위한 접근이 아닌 생소한 부분에 대한 학습의 목적이 강해서, 결과 보다는 과정 상에서 얻은 학습의 결과를 추후 다른 데이터 활용의 용이함을 위하여 적어본다.  


## Feature

Avito Demand Prediction Challenge의 Data에는 숫자형 특성, 분류형 특성, 텍스트 특성, 이미지 특성이 모두 들어가 있다. deal_probability을 예측하기 위해 이런 특성들을 활용하는 모델을 생성하기 위해서는 각각의 특성 별로 처리해야 하는 과정이 달랐고, 수행 과정에서의 경험을 남겨본다.


### Categorical

region, city, category, param 등 일반적으로 명목형 변수로 분류 할 수 있는 변수들을 모델링에 효과적으로 활용 할 수 있는 경험에 대한 기록

* factor 변환
* factor 덩어리화
* factor for onehotencoding

```R
avi <- avi %>%
  mutate(param_1 = factor(param_1) %>% as.integer(),
         param_2 = factor(param_2) %>% as.integer())
```
이런 방식으로 factor 특성으로 변경하고, integer 형식으로 변경을 하게 되면, 모델 생성에 숫자형 특성을 유지할 수 있는데...

![](../output/avito_param.png)

위 이미지를 보면 param_3의 경우, 한 factor가 50%를 넘는 점유율을 보이고 있고, 이대로 활용하기에는 모델링에 문제를 야기할 수 있는 느낌을 준다. 이런 경우 전체 factor의 수를 줄이는 방법에 대한 고민을 하게 되는데, 이 고민 해결을 도움을 줄 수 있는 하나의 방법으로 일정 수치 이하의 factor들을 묶음 처리 할 수 있다. 해당 방법 구현의 방법 중 하나로 `fct_lump` 사용을 학습했다.

```R
avi <- avi %>%
  mutate(param_3 = factor(param_3) %>% fct_lump(prop=0.00005) %>% as.integer(),
         user_id = factor(user_id) %>% fct_lump(prop=0.00002) %>% as.integer(),
         city = factor(city) %>% fct_lump(prop=0.0003) %>% as.integer())
```

다음으로,
위의 경우들은 factor 특성을 전부 수치화했지만...
factor의 특성을 분명하게 유지하고 싶다면...
고민해야 할 방법!
ADTracking에서는 LGBM모델을 이용해서 `categorical_feature`를 추가해줘서 이 부분을 커버했지만, 이 자료의 경우는 모델링을 하기 위한 데이터 형태를 모델 매트릭스로 만드는 게 목적이라 모델링에서 처리하는 방법보다는 직접 데이터 자체에 그 성격을 부여하는 방법을 고민하게 되었고, 이 방법은 일종의 `one hot enconding`과도 그 성격이 같다는 생각이 든다. 모델 행렬을 만드는 부분에서 다시 언급될 부분이어서, wrangling 과정에서는 원하는 factor 특성 유지를 위해서는 숫자형 형태로 바꾸지 않고 factor 변환까지만 유지한다.

```R
avi <- avi %>%
  mutate(region = factor(region),
         parent_category_name = factor(parent_category_name),
         user_type = factor(user_type),
         mday = mday(activation_date) %>% as.factor(),
         wday = wday(activation_date) %>% as.factor()
```

<br>


### Numerical

같은 숫자이지만 `integer`와 달리 double의 특성을 가지는 수치형 자료의 경우, 모델링에 category 특성을 부여하기에는 적당하지 않고, 그냥 사용하기에는 찝찝한 느낌을 주는 숫자 특성이다. 그렇지만, 수학의 천재들의 업적 덕에 이 광범위한 숫자들의 분포를 효과적으로 모델링에 적용하는 방법이 있음을 알게 되었다. 시각화나 EDA를 함에 있어서 범위가 매우 넓은 경우, 효과적으로 보이기 위해 `scale_x_log10`을 활용하는 것 처럼, 모델링을 위한 wrangling 작업에도 `log` 또는 `log1p`는 어마어마한 상승 효과를 보여준다. 이 글에서 보여주지는 않지만, `Santander Value Prediction Challenge`의 target의 경우도 아주 넓은 분포를 가지고 있지만, 해당 target을 `log`를 활용하게 되면 정규분포와 비슷한 모양을 가지게 된다.

```R
avi <- avi %>%
  mutate(price = log1p(price))
```
변환 코드은 위 코드처럼 간단하다.
`log`와 `log1p`의 차이는,
수학적으로는 뭔가... 차이가 크겠지만,
그냥 검색 사이틀 통해서 둘의 그래프를 살펴보면, 직관적으로 데이터 분석을 위해서는 어떤 것을 사용해야 할 지 느낌이 온다.


### Text

일단 text에서는 `feature engineering`을 위해 필요 파생 변수를 생성해주고 진행했다. 텍스트의 길이를 추출해서 integer 속성을 뽑아내고, 각각의 텍스트에 대문자, 특수문자, 숫자의 카운트 또한 intger 속성으로 뽑아냈다.
```R
avi <- avi %>%
  mutate(dsc_len = str_length(description),
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
         txt = paste(title, description, sep = " "))
```

파생 변수 생성 후에는, text와 descrpiton을 하나의 항목으로 합치고, 이 문장에 대한 `tfidf`을 계산하여 이를 변수화 한다. 텍스트 분석에 있어서 `text2vec`, `word2vec`, `FastText` 같은 방법을 활용한다. 상위권자들의 soloution에는 `FastText`를 많이 사용한 듯 하고, 본인은 `text2vec`을 사용법을 학습했다.

1. 텍스트 정제
2. word_stems 생성 후 token 생성
3. token을 이용 불용어 처리한 term, doc 수 추출
4. prune_vocabulary를 통해 가지 치기
5. term, doc 표를 벡터화
6. 벡터를 DTM(Documnet Term Matrix)으로 변환
7. tfidf 모델 생성
8. dtm을 TfIdf모델로 변환

위와 같은 과정이 끝나면, dtm에 tfidf값이 들어가 있는 매트릭스가 만들어 진다.
데이터로 바로 학습하는 것이 어려워서, 테스트로 일정 문장을 만들고 학습을 해 봤다. [학습연습코드](Avito/Avito_Code/test_tfidf.R)



``` R
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
```



### Image
