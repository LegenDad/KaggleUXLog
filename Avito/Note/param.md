
# param_1, param_2, param_3

NA 처리 및 integer 변환
* factor 변환 후 integer 변환
* NA는 -1로 강제 할당 , 기존 NA였던 값 활용을 위한 파생변수 생성

```R
avi$p1_na <- is.na(avi$param_1) %>% as.integer()
avi$p2_na <- is.na(avi$param_2) %>% as.integer()
avi$p3_na <- is.na(avi$param_3) %>% as.integer()
table(avi$p1_na)
table(avi$p2_na)
table(avi$p3_na)
str(avi$param_1)
head(sort(table(avi$param_1), decreasing = T), 7)
avi <- avi %>% mutate(param_1 = param_1 %>% factor() %>% as.integer(),
                      param_2 = as.integer(factor(param_2)),
                      param_3 = as.integer(factor(param_3)))
head(sort(table(avi$param_1), decreasing = T), 7)

# avi$param_1 <- ifelse(is.na(avi$param_1), -1, avi$param_1)
avi <- avi %>% replace_na(list(param_1 = -1, param_2 = -1, param_3 =-1))
```

* 생성시킨 파생 변수와 NA 일치 여부 확인
* NA 처리 여부 확인
```R
nrow(avi[avi$param_1 ==-1, ]) == sum(avi$p1_na)
nrow(avi[avi$param_2 ==-1, ]) == sum(avi$p2_na)
nrow(avi[avi$param_3 ==-1, ]) == sum(avi$p3_na)
avi_na2 <- sapply(avi, function (x) sum(is.na(x)))
avi_na2[avi_na2>0]
str(avi$param_1)
```

```R

range(avi$param_1)
range(avi$param_2)
range(avi$param_3)
```

```R
pie(table(avi$param_1))
pie(table(avi$param_2))
pie(table(avi$param_3))
```

* param_3 분포가 극단적이어서 , fct_lump 활용
