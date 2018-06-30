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

### Text

### Image
