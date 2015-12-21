data(iris)
# SVM
library(e1071)
library(ggplot2)
df <- read.csv("C:/aa/git2/practice/df.csv")
head(df)
nrow(df)
ggplot(df, aes(x=X, y=Y, color=factor(Label))) + geom_point()

# using logistic regression
logit.fit <- glm(Label~X+Y, family=binomial(link='logit'), data=df)
logit.predictions <- ifelse(predict(logit.fit)>0, 1, 0)
mean(with(df, logit.predictions== Label))

# using svm without hyperparameters
svm.fit <- svm(Label~ X+Y, data=df)
svm.fit
summary(svm.fit)
svm.predictions <- ifelse(predict(svm.fit) > 0, 1, 0)
mean(with(df, svm.predictions==Label))

df <- cbind(df, data.frame(Logit=ifelse(predict(logit.fit) > 0 , 1, 0), 
                           SVM=ifelse(predict(svm.fit) > 0 , 1, 0)))
#install.packages("reshape")
library(reshape)
predictions <- melt(df, id.vars=c('X', 'Y'))

head(predictions)
head(df)

ggplot(predictions, aes(x=X, y=Y, color=factor(value))) + geom_point() + facet_grid(variable ~.)

df <- df[, c('X', 'Y', 'Label')]
head(df)

linear.svm.fit <- svm(Label~X+Y, data=df, kernel='linear')
mean(with(df, ifelse(predict(linear.svm.fit)>0, 1, 0)==Label))

polynomial.svm.fit <- svm(Label~X+Y, data=df, kernel='polynomial')
mean(with(df, ifelse(predict(polynomial.svm.fit)>0, 1, 0)==Label))

# 0.7204
radial.svm.fit <- svm(Label~X+Y, data=df, kernel='radial')
mean(with(df, ifelse(predict(radial.svm.fit)>0, 1, 0)==Label))

sigmoid.svm.fit <- svm(Label~X+Y, data=df, kernel='sigmoid')
mean(with(df, ifelse(predict(sigmoid.svm.fit)>0, 1, 0)==Label))
# maybe I should try ANN
library(nnet)
ann.fit <- nnet(Label~ X+Y, data=df, size=6)
mean(with(df, ifelse(predict(ann.fit)==1, 1, 0)==Label))


df2 <- cbind(df, 
             data.frame(LinearSVM=ifelse(predict(linear.svm.fit)>0, 1, 0),
                        PolynomialSVM=ifelse(predict(polynomial.svm.fit)>0, 1, 0),
                        RadialSVM=ifelse(predict(radial.svm.fit)>0, 1, 0),
                        SigmoidSVM=ifelse(predict(sigmoid.svm.fit)>0, 1, 0),
                        ANN=ifelse(predict(ann.fit)>0, 1, 0)))

predictions <- melt(df2, id.vars=c('X', 'Y'))

#head(df[df$variable=='LinearSVM',])

ggplot(predictions, aes(x=X, y=Y, color=factor(value))) + geom_point() + facet_grid(variable ~ .)
head(df)


# polynomial with different degrees
# 0.4844
polynomial.degree3.svm.fit <- svm(Label~X+Y, data=df, kernel='polynomial', degree=3)
with(df, mean(ifelse(predict(polynomial.degree3.svm.fit)>0, 1, 0) == Label))

# 0.4844
polynomial.degree5.svm.fit <- svm(Label~X+Y, data=df, kernel='polynomial', degree=5)
with(df, mean(ifelse(predict(polynomial.degree5.svm.fit)>0, 1, 0) == Label))

# 0.5612
polynomial.degree10.svm.fit <- svm(Label~X+Y, data=df, kernel='polynomial', degree=10)
with(df, mean(ifelse(predict(polynomial.degree10.svm.fit)>0, 1, 0) == Label))

# 0.5536
polynomial.degree12.svm.fit <- svm(Label~X+Y, data=df, kernel='polynomial', degree=12)
with(df, mean(ifelse(predict(polynomial.degree12.svm.fit)>0, 1, 0) == Label))

# 0.5744
polynomial.degree8.svm.fit <- svm(Label~X+Y, data=df, kernel='polynomial', degree=8)
with(df, mean(ifelse(predict(polynomial.degree8.svm.fit)>0, 1, 0) == Label))

# 0.4844
polynomial.degree7.svm.fit <- svm(Label~X+Y, data=df, kernel='polynomial', degree=7)
with(df, mean(ifelse(predict(polynomial.degree7.svm.fit)>0, 1, 0) == Label))

# 0.5844
polynomial.degree6.svm.fit <- svm(Label~X+Y, data=df, kernel='polynomial', degree=6)
with(df, mean(ifelse(predict(polynomial.degree6.svm.fit)>0, 1, 0) == Label))
head(df)
df2 <- cbind(df, 
             data.frame(degree3SVM=ifelse(predict(polynomial.degree3.svm.fit)>0, 1, 0),
                        degree6SVM=ifelse(predict(polynomial.degree6.svm.fit)>0, 1, 0),
                        degree10SVM=ifelse(predict(polynomial.degree10.svm.fit)>0, 1, 0),
                        degree12SVM=ifelse(predict(polynomial.degree12.svm.fit)>0, 1, 0),
                        ANN=ifelse(predict(ann.fit)>0, 1, 0)))

predictions <- melt(df2, id.vars=c('X', 'Y'))

#head(df[df$variable=='LinearSVM',])

ggplot(predictions, aes(x=X, y=Y, color=factor(value))) + geom_point() + facet_grid(variable ~ .)

# Radial kernel with different cost hyperparameter
# 0.7204
radial.cost1.svm.fit <- svm(Label~X+Y, data=df, kernel='radial', cost=1)
with(df, mean(ifelse(predict(radial.cost1.svm.fit)>0, 1, 0) == Label))

# 0.7052
radial.cost2.svm.fit <- svm(Label~X+Y, data=df, kernel='radial', cost=2)
with(df, mean(ifelse(predict(radial.cost2.svm.fit)>0, 1, 0) == Label))

# 0.6996
radial.cost3.svm.fit <- svm(Label~X+Y, data=df, kernel='radial', cost=3)
with(df, mean(ifelse(predict(radial.cost3.svm.fit)>0, 1, 0) == Label))

# 0.694
radial.cost4.svm.fit <- svm(Label~X+Y, data=df, kernel='radial', cost=4)
with(df, mean(ifelse(predict(radial.cost4.svm.fit)>0, 1, 0) == Label))

# 
radial.cost15.svm.fit <- svm(Label~X+Y, data=df, kernel='radial', cost=15)
with(df, mean(ifelse(predict(radial.cost15.svm.fit)>0, 1, 0) == Label))

df2 <- cbind(df, 
             data.frame(COST1=ifelse(predict(radial.cost1.svm.fit)>0, 1, 0),
                        COST2=ifelse(predict(radial.cost2.svm.fit)>0, 1, 0),
                        COST3=ifelse(predict(radial.cost3.svm.fit)>0, 1, 0),
                        COST4=ifelse(predict(radial.cost4.svm.fit)>0, 1, 0),
                        COST15=ifelse(predict(radial.cost15.svm.fit)>0, 1, 0)))

predictions <- melt(df2, id.vars=c('X', 'Y'))

ggplot(predictions, aes(x=X, y=Y, color=factor(value))) + geom_point() + facet_grid(variable ~ .)


# Radial kernel with different gamma hyperparameter
# 0.7204
radial.gamma1.svm.fit <- svm(Label~X+Y, data=df, kernel='radial', gamma=1)
with(df, mean(ifelse(predict(radial.gamma1.svm.fit)>0, 1, 0) == Label))

# 0.7052
radial.gamma2.svm.fit <- svm(Label~X+Y, data=df, kernel='radial', gamma=2)
with(df, mean(ifelse(predict(radial.gamma2.svm.fit)>0, 1, 0) == Label))

# 0.6996
radial.gamma3.svm.fit <- svm(Label~X+Y, data=df, kernel='radial', gamma=3)
with(df, mean(ifelse(predict(radial.gamma3.svm.fit)>0, 1, 0) == Label))

# 0.694
radial.gamma4.svm.fit <- svm(Label~X+Y, data=df, kernel='radial', gamma=4)
with(df, mean(ifelse(predict(radial.gamma4.svm.fit)>0, 1, 0) == Label))

# 
radial.gamma15.svm.fit <- svm(Label~X+Y, data=df, kernel='radial', gamma=15)
with(df, mean(ifelse(predict(radial.gamma15.svm.fit)>0, 1, 0) == Label))

df2 <- cbind(df, 
             data.frame(GAMMA1=ifelse(predict(radial.gamma1.svm.fit)>0, 1, 0),
                        GAMMA2=ifelse(predict(radial.gamma2.svm.fit)>0, 1, 0),
                        GAMMA3=ifelse(predict(radial.gamma3.svm.fit)>0, 1, 0),
                        GAMMA4=ifelse(predict(radial.gamma4.svm.fit)>0, 1, 0),
                        GAMMA15=ifelse(predict(radial.gamma15.svm.fit)>0, 1, 0)))

predictions <- melt(df2, id.vars=c('X', 'Y'))

ggplot(predictions, aes(x=X, y=Y, color=factor(value))) + geom_point() + facet_grid(variable ~ .)
# sigmoid kernel with different gamma hyperparameters
# 0.478
sigmoid.gamma1.svm.fit <- svm(Label~X+Y, data=df, kernel='sigmoid', gamma=1)
with(df, mean(ifelse(predict(sigmoid.gamma1.svm.fit)>0, 1, 0) == Label))

# 0.4824
sigmoid.gamma2.svm.fit <- svm(Label~X+Y, data=df, kernel='sigmoid', gamma=2)
with(df, mean(ifelse(predict(sigmoid.gamma2.svm.fit)>0, 1, 0) == Label))

# 0.4816
sigmoid.gamma3.svm.fit <- svm(Label~X+Y, data=df, kernel='sigmoid', gamma=3)
with(df, mean(ifelse(predict(sigmoid.gamma3.svm.fit)>0, 1, 0) == Label))

# 0.4824
sigmoid.gamma4.svm.fit <- svm(Label~X+Y, data=df, kernel='sigmoid', gamma=4)
with(df, mean(ifelse(predict(sigmoid.gamma4.svm.fit)>0, 1, 0) == Label))

#
sigmoid.gamma8.svm.fit <- svm(Label~X+Y, data=df, kernel='sigmoid', gamma=8)
with(df, mean(ifelse(predict(sigmoid.gamma8.svm.fit)>0, 1, 0) == Label))

df2 <- cbind(df, 
             data.frame(GAMMA1=ifelse(predict(sigmoid.gamma1.svm.fit)>0, 1, 0),
                        GAMMA2=ifelse(predict(sigmoid.gamma2.svm.fit)>0, 1, 0),
                        GAMMA3=ifelse(predict(sigmoid.gamma3.svm.fit)>0, 1, 0),
                        GAMMA4=ifelse(predict(sigmoid.gamma4.svm.fit)>0, 1, 0),
                        GAMMA8=ifelse(predict(sigmoid.gamma8.svm.fit)>0, 1, 0)))

predictions <- melt(df2, id.vars=c('X', 'Y'))

ggplot(predictions, aes(x=X, y=Y, color=factor(value))) + geom_point() + facet_grid(variable ~ .)