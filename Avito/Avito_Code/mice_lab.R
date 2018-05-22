#install.packages("mice")
library(mice)
empty_model <- mice(avi, maxit = 0)
str(empty_model)
method <- empty_model$method
predictorMatrix <- empty_model$predictorMatrix
newdata <- mice(avi, method, predictorMatrix, m=5)
newdata <- complete(newdata)

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