# TalkingData AdTracking Fraud Detection Challenge - Part3

----

개인적으로 Discussion에 올라오는 브리핑 내용을 수집했으나

Part2에 소개한 CPMP가 상위권 유저들의 브리핑을 엮어서 글을 올렸다.  

[Link Url](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56481)

전체 내용에 대한 이해는 관련 지식 부족으로 설명은 못하지만,  
응용할 수 있는 포인트만 남겨본다.  

### 1위 :  [Link](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56475#latest-326715)

* negative down-sampling
* five raw categorical features (ip, os, app, channel, device)
* time categorical features (day, hour)
* click count within next one/six hours
* average attributed ratio of past clicks
* bagging : reply 살펴보면 사용한 코드 예시 있다.

<br>

### 2위 : [Link](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56328#latest-326651)

* two methods, LightGBM and NN

<br>

### 3위 : [Link](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56262)

* Kaggle Rank 1위인 bestfitting (유저들이 bot으로 오인한다는...)
* NN Model
* n-fold models

<br>
### 4위 : [Link1](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56243), [Link2](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56268), [Link3](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56545)

* Link2의 IP Leak Problem & Solution  
많은 유저들이 호평한 Idea, Score 0.0005 향상을 보장하는 기법   
데이터베이스 설계에 대한 이해력으로 추론되는 결과  
개인적으로 능력 부족으로 활용에는 실패  

* Link3은 Code Link

<br>

### 5위 : [Link1](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56406), [Link2](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56319)

* 파생 변수 700개 이상 생성
* click_time delta 간격을 2까지 이용
* Pseudo Labeling

<br>

### 6위 : [Link](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56283)

* test data 시간대를 valid로 활용
<br>

### 8위 : [Link](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56325)

* Statistics (mean/var)
* 74 features
<br>
### 9위 : [Link](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56279#latest-326008)

* Device 3032 : delete
* first click gets 16:00:00.00, second gets 16:00:00.01, next 16:00:00.02
<br>

### 11위 : [Link1](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56250), [Link2](https://www.kaggle.com/lperez/no-ram-fast-feature-engineering-with-big-query)

* 구글 빅쿼리 활용  
개인적으로 매우 매력적인 접근 방식  
모든 파생 변수 생성까지 20분 이내로 끝난다는 이점이 있다.
<br>
### 13위 : [Link](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56333)

* Use test supplement: it is crucial
Next, Prev Click 변수의 흐름을 유지해준다.
하지만 개인적으로 시도는 여러 차례 실패했다.  
* CV : 실질적인 활용이 궁금해지는...
* Careful with next click feature: a click at 14.30 in the test set
* R 사용 유저 중 최고 등수로 추정  

<br>

### 14위 : [Link](https://zhuanlan.zhihu.com/p/36580283)

* 중국어라서 어렵지만, CV와 NN 기법이 주요 포인트로 확

That's for the gold teams. More sharing from other teams below.

<br>

### 18위 : [Link](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56422#latest-326648)

* Use test supplement

<br>

### 22위 : [Link](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56571)

* click rate (duration/count)
* app entropy
* [LeaderBoard Plot](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56524)

<br>

### 28위 : [Link](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56368#latest-326234)


<br>
### 34위 : [Link](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion/56304)

* Pseudo Labeling
* test supplement
* R 유저  

<br>

더 많은 브리핑들이 있지만, 소개는 여기까지만 적겠다.

---

### 위 브링핑 중 중요 내용으로 생각되는 포인트

* negative down-sampling
1위 팀이 사용한 샘플링 방법  
is_atrributed값 0,1을 동등한 숫자로 사용했음

* test supplement 데이터 활용  
matching 파일이 있지만, 내공 부족으로 auc 향상에는 실패

* Psuedo Lableling  
성공하면 auc 향상에 크게 기여하는 것으로 추측  

* CV & Ensemble  
모든 상위 유저들이 시도하는데, 실질적 활용에 대한 아직 아이디어 없어서 아쉽다.



---



### 현재 응용 상황 및 마무리

여러 차례 test supplement 활용했지만, 좋은 결과를 보지 못했고, 다른 방법들로 개선 작업 중이다.

|  <center>Model</center> |  <center>Size</center> |  <center>Valid AUC</center> | <center>LB Score </center> |
|:--------|:--------:|--------:|-------:|
|**LGBM with  NextClick** | *1천만* |*0.97* | *0.9715*|
|**LGBM with  Next_Prev_Click** | *1천만* |*0.97* | *0.9709*|
|**LGBM with  NP2_Last_Click** | *1천만* |*0.97* | *0.9720*|  

Next, Prev 간격을 2까지 늘리고, `LastClick`를 추가하여 약간의 향상이 보여서 Size를 올려서 테스트 중이다.
