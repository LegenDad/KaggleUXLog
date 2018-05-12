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

익숙치 않은 시각화 보다는 모델링을 해서 나온 결과를 통해  
변수별 중요도 파악을 해서 파생 변수 추가 삭제를 진행 하는 방법으로 진행했다.  
