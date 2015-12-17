# This is P4, may use recurrent neural network for clustering
#library(RSNNS)
#library(class)
install.packages('')
library(monmlp)

doublemoon <- function(r1, r2, d) {
  
}

x <- runif(2000, -2, 2)
y <- runif(2000, -2, 2)

z <- cbind(x,y)
nrow(z)
colnames(z) <- c("x", "y")

rad <- z[z[,1]^2+z[,2]^2<4,]
nrow(rad)

plot(rad)

x <- c( 1,2, 4, 3)
y <- c(1, 2, 3, 4)

convolve(x,x, type="circular")

set.seed(1234)
data(iris)
data.iris=iris
d1 <- iris[,1]+iris[,2]+iris[,3]+data.iris[,4]
head(d1)
d2 <- data.iris[,1]*data.iris[,2] + data.iris[,1]*data.iris[,3] + data.iris[,1]*data.iris[,4] + data.iris[,2]*data.iris[,3] + data.iris[,2]*data.iris[,4] + data.iris[,3]*data.iris[,4]
head(d2)
d3 <- data.iris[,1]*data.iris[,2]*data.iris[,3]+data.iris[,1]*data.iris[,2]*data.iris[,4] + data.iris[,1]*data.iris[,3]*data.iris[,4] + data.iris[,2]*data.iris[,3]*data.iris[,4]
head(d3)
d4 <- data.iris[,1]*data.iris[,2]*data.iris[,3]*data.iris[,4]
head(d4)



data.iris2 <- cbind(d1, d2,d3,d4)
data.iris3 <- cbind(d1,d2,d3,d4,iris[,5])
colnames(data.iris3) <- c("d1", "d2", "d3", "d4", "Species")
head(data.iris2)
sample.iris <- sample(c(1: length(iris[[1]])), 100)
sample2.iris <- sample(sample.iris, 10000, replace=TRUE)
library(nnet)
train.iris2 <- data.iris2[sample2.iris, ]
train.class2 <- class.iris[sample2.iris]
test.iris2 <- data.iris2[-sample.iris,]
test.class2 <- class.iris[-sample.iris]
iris.net2 <- nnet(train.class2~., data=train.iris2, size=10,maxit = 1000,trace=F, Hess = T)

pred.iris2 <- predict(iris.net2, test.iris2, type = "class")
sum(test.class2==pred.iris2)                      
pred.iris2.all <- predict(iris.net2, data.iris2, type="class")
sum(pred.iris2.all == iris[,5])

tree2 <- rpart(Species~., method = "class", data=as.data.frame(data.iris3[sample.iris,]), control = rpart.control(minsplit = 2))
pred.tree2 <- predict(tree2,as.data.frame( data.iris3[-sample.iris, 1:4]), type ="class")
sum(pred.tree2 == data.iris3[-sample.iris,5])
pred.tree2.all <- predict(tree2,as.data.frame( data.iris3[, 1:4]), type ="class")
sum(pred.tree2.all == data.iris3[,5])


library(monmlp)
set.seed(123)
data1 <- runif(100, -0.5, 0.5)
data2 <- runif(100, -0.25, 0.75)

data3 <- cbind(data2, data1)

data4 <- runif(50, -1.5, -0.5)
data5 <- runif(50, -1,1)
data6 <- cbind(data4, data5)

data7 <- runif(25, -1.5, 1)
data8 <- runif(25, 1,1.25)
data9 <- cbind(data7, data8)

data10 <- runif(25, -1.5, 1)
data11 <- runif(25, -1.25,-1)
data12 <- cbind(data10, data11)


data <- rbind(data3, data6, data9, data12)

x <- seq(-2,2, length=20)
y <- seq(-2,2, length=20)
target <- make.target(c(100, 100), low=0)

tt <- c(2,2,-2,2,2,-2,-2,-2)
dim(tt) <- c(2,4)
tt <- t(tt)
plot(tt[,1], tt[,2], type="n", xlab = "",ylab = "")
points(data[,1],data[,2], pch=15, col=c(rep(2,100), rep(3,100)))
target <- c(rep(0,100), rep(1,100))

head(target)
head(data[,1])
head(data[,2])

set.seed(127)
t1.nn <- monmlp.fit(x=data,y=matrix(target), hidden1 = 3, n.ensemble = 15, monotone = 1, bag=TRUE)


z <- monmlp.predict(x=data, weights = t1.nn)
library(ROCR)
plot(performance(prediction(z,target), "tpr", "fpr"))

data(crabs)
head(crabs)
head(iris)


library(e1071)
data(iris)
attach(iris)

model <- svm(Species~., data=iris)
print(model)
x <- subset(iris, select = -Species)

y <- Species

model <- svm(x,y, probability = TRUE)

print(model)
pred <- predict(model, x)
summary(model)
pred <- fitted(model)
head(pred)
sum(pred==Species)

pred <- predict(model,x, decision.value=TRUE, probability=TRUE)
attr(pred, "decision.values")[1:4,]
attr(pred, "probabilities")[1:4,]

detach(iris)

library(kohonen)
data(wines)
set.seed(7)

training <- sample(nrow(wines), 120)
Xtraining <- scale(wines[training,])
Xtest <-scale(wines[-training,], center = attr(Xtraining,"scaled:center"), scale=attr(Xtraining, "scaled:scale"))
bdk.wines <- bdk(Xtraining, factor(wine.classes[training]), grid=somgrid(5,5, "hexagonal"))
bdk.prediction <- predict(bdk.wines, newdata=Xtest)
table(wine.classes[-training], bdk.prediction$prediction)


data(iris)
set.seed(7)
sample.iris <- sample(nrow(iris), 100)
irisdata <- iris[,1:4]
head(irisdata)
irisclass <- iris[,5]
traindata.iris <- scale(irisdata[sample.iris,])
testdata.iris <- scale(irisdata[-sample.iris,], center = attr(traindata.iris,"scaled:center"), scale=attr(traindata.iris, "scaled:scale"))

bdk.iris <- bdk(traindata.iris, factor(irisclass[sample.iris]), grid=somgrid(20,10, "hexagonal"))
bdk.iris.pred <- predict(bdk.iris, newdata = testdata.iris)
table(irisclass[-sample.iris], bdk.iris.pred$prediction)
