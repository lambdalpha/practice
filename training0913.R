install.packages('e1071')
install.packages('randomForest')
install.packages('adabag')
install.packages('tree')
install.packages('fpc')
install.packages('msm')
install.packages('recommenderlab')

setwd('c:/app/R')

newsdf <- read.delim('C:/app/R/newsdf.txt', header=T, encoding='uft-8')
newsdf[,2] <- as.factor(newsdf[,2])
set.seed(1234)
testindices <- sample(c(1:length(newsdf[,2])),500)
trainindices <- c(1:length(newsdf[,2]))
trainindices <- trainindices[-testindices]

#Discretization
for(i in c(3:length(newsdf))){
  tempvec <- newsdf[[i]]
  tempvec[tempvec>=1] <- 1
  tempvec[tempvec<1] <- 0
  newsdf[[i]] <- tempvec
}

#transform to Factor type
for(i in c(3:length(newsdf))){
  newsdf[[i]] <- as.factor(newsdf[[i]])
}

newsdf[[3]]
#evaluation
accCal <- function(res1, res2){
  evares <- table(res1, res2)
  sum <- 0
  for(i in c(1:5)){
    sum <- sum + evares[i,i]
  }
  return(sum/5)
}

save.image('c:/app/r/train.RData')
load('c:/app/r/train.RData')
help(svm)
#NB
library(e1071)
newsnbm <- svm(Label~.,data=newsdf[-testindices,-1],kernel = 'radial', type='nu-classification')
newsnbres <- predict(newsnbm, newsdf[testindices,-1])
table(newsnbres, newsdf[testindices,2])
accCal(newsnbres, newsdf[testindices,2])

summary(newsnbm)


library(adabag)
help(boosting)
newsnbm <- boosting(Label~.,data=newsdf[-testindices,-1], boos=F, mfinal=5)
newsnbres <- predict(newsnbm, newsdf[testindices,-1])
table(newsnbres, newsdf[testindices,2])
accCal(newsnbres, newsdf[testindices,2])


#movie recommendation
library(recommenderlab)
data(MovieLense)
evaScheme <- evaluationScheme(MovieLense, method="split", train=0.8, given = 15, goodRating=4)

algorithms <- list(
  "random items" = list(name="RANDOM", param=NULL),
  "popular items" = list(name="POPULAR", param=NULL),
  "item-based CF" = list(name="IBCF", param=list(method="cosine")),
  "item-based CF" = list(name="IBCF", param=list(method="jaccard")),
  "item-based CF" = list(name="IBCF", param=list(method="pearson")),
  "user-based CF" = list(name="UBCF", param=list(method="cosine")),
  "user-based CF" = list(name="UBCF", param=list(method="jaccard")),
  "user-based CF" = list(name="UBCF", param=list(method="pearson"))
)
results <- evaluate(evaScheme, algorithms, n=c(1, 3, 5, 10, 15, 20))
plot(results, annotate=TRUE)

library(class)

