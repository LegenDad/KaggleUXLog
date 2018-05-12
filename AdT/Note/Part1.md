# TalkingData AdTracking Fraud Detection Challenge - Part1  

---

![](../output/scoregraph.png)

Part1은 첫 시작부터 4월말까지의 경험으로 작성해 본다.   
중간 정리한 [발표 자료](https://github.com/LegenDad/KaggleUXLog/blob/master/AdT/Note/UX%20About%20AdTracking.pdf)와 크게 다른 내용은 없다.  

### Intro  
왜 Fraud Click을 찾아야 하는가?   

[![Video Label](https://i.kinja-img.com/gawker-media/image/upload/s--ZL-sFioc--/c_fit,f_auto,fl_progressive,q_80,w_636/wnus15o6tm4ekewlelgn.jpg)](https://i.kinja-img.com/gawker-media/image/upload/imuqp7dbsu41o3socgwi.mp4)  
Chinese Farm  

Fraud라는 용어 자체의 불편한 경험이 있지만,  
위 이미지 및 영상으로 대충 파악하고 해당 데이터 분석을 시작한다.  





### 파생 변수 생성에 대한 접근  

익숙치 않은 시각화을 통한 인사이트 도출 보다는 모델링을 해서 나온 결과를 통해  
변수별 중요도 파악을 해서 파생 변수 추가 삭제를 진행 하는 방법으로 진행했다.  
![](../output/001.png) ![](../output/002.png)


### 여러 알고리즘 별 결과 비교  

|  <center>Model</center> |  <center>Size</center> |  <center>Valid AUC</center> | <center>LB Score </center> |
|:--------|:--------:|--------:|-------:|
|**GLM** | *1천만* |*0.92* | *0.89*|
|**GLM** | *2천만* |*0.92* | *0.89*|
|**Decision Tree** | *1천만* |*0.92* | *0.65*|
|**Random Forest** | *1천만* |*memory limit* | *memory limit*|
|**XGB** | *1천만* |*0.97* | *0.91*|
|**XGB** | *2천만* |*0.97* | *0.90*|
|**XGB** | *5천만* |*0.97* | *0.94*|
|**LGBM** | *1천만* |*0.92* | *0.89*|
|**LGBM** | *2천만* |*0.92* | *0.93*|
|**LGBM with  Categorical Features** | *1천만* |*0.92* | *0.96*|  

* GLM
XGB, LGBM의 결과가 너무 우수해서 개선의 필요성을 느끼지 못했다
사용해보고 교차 분석 활용 경험 용도였다.
[code link](../Code/Glm_Tree_Sample.R)
```r
library(caret)
model <- train(factor(is_attributed)~., adtr, method = "glm",
               trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE))
```

* Decision Tree  
훈련은 잘되는 듯 했으나, 최종 스코어 점수가 많이 떨어진 경우  
과적합 해결을 위해 파라미터 수정이 필요했으나,   
마찬가지로 XGB, LGBM 결과와 너무 비교되서 배제했다.
