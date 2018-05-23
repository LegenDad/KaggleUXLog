#install.packages("mice")
library(mice)
empty_model <- mice(avi, maxit = 0)
str(empty_model)
method <- empty_model$method
predictorMatrix <- empty_model$predictorMatrix
newdata <- mice(avi, method, predictorMatrix, m=5)
newdata <- complete(newdata)


library(data.table)
ttr <- fread("../../Data/Titanic/train.csv")
tte <- read.csv("../../Data/Titanic/test.csv")
head(ttr)
head(tte)
na_cnt <- sapply(ttr, function(x) sum(is.na(x)))
na_cnt
sum(is.null(ttr$Embarked))
str(ttr$Embarked)
table(ttr$Embarked)
168 + 77 +644
library(mice)

empty_model <- mice(ttr, maxit = 0)
method <- empty_model$method
predictorMatrix <- empty_model$predictorMatrix
newtr <- mice(ttr, method, predictorMatrix, m=5)
newtr <- complete(newtr)
head(newtr)
na_cnt2 <- sapply(newtr, function(x) sum(is.na(x)))


?complete
?mice
# initialize an empty model to take the parameters from
empty_model <- mice(punjab_gdp, maxit=0) 
method <- empty_model$method
predictorMatrix <- empty_model$predictorMatrix

# first make a bunch of guesses...
imputed_data <- mice(punjab_gdp, method, predictorMatrix, m=5)
# then pick one for each variable
imputed_data <- complete(imputed_data)