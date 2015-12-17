options(java.parameters = "-Xmx4g")
library(XLConnect)
#library(RODBC)
setwd("C:/app/R/")

# excel.file <- file.path("ES Opportunity 0924.xlsx")
# excel.data <- readWorksheetFromFile(excel.file, sheet=3)
custom.data <- excel.data
# the data for clustering:
#testdatacluster <- data.frame(levels(custom.data$"Opportunity.Type"),levels(custom.data$"Deal.Type"), as.numeric(custom.data$TCV))
#custom.f <- cbind(custom.data$"Opportunity.Type",custom.data$"Deal.Type", custom.data$TCV)~1

#library(poLCA)
#custom.lc <- poLCA(custom.f, custom.data, nclass=3, maxiter=3000, tol=1e-7)

# excel.channel <- odbcConnectExcel("ES Opportunity 0924.xlsx")
# write.table(excel.data, file="esoppdata2.txt", 
append=FALSE, sep=";", eol="\n", na="NA", dec=".", row.names=TRUE, qmethod=c("escape","double"), fileEncoding="")

# custom.data <- read.table("esoppdata2.txt", header=TRUE, sep=";", quote="\"", fill=TRUE)

barplot(custom.data$TCV, main="opportunity", names.arg="", xlab="opp", ylab="tcv")
#library(multcomp)
fit_tcv_tem <- aov(custom.data$TCV ~ custom.data$TEM)
summary(fit_tcv_tem)
library(gplots)
plotmeans(custom.data$TCV ~ custom.data$TEM, xlab="TCV", ylab="TEM", main="Mean Plot\nwith %95 CI")

industry_amid2_vn.f <- factor(custom.data$Industry.AMID.2.Vertical.Name)
summary(industry_amid2_vn.f)
# correlationship between TCV TEM FFYR FFEM
cor(custom.data[,c(40:43)], use="everything", method=c("pearson", "kendall", "spearman"))

sd(custom.data$TCV)
sd(custom.data$TEM)
sd(custom.data$FFYR)
sd(custom.data$FFEM)

custom_bussinessgroup.f <- factor(custom.data$BusinessGroup)

lm(custom.data$TCV~custom.data$TEM)

#library(ggplot2)
#ggplot(custom.data, aes(custom.data$TCV/100000, custom.data$TEM/100000)) + geom_point(aes(colour=custom.data$TCV, shape=custom.data$Status, size=custom.data$TEM)) + scale_x_continuous(limits=c(-1000,1000))

# Data mining my steps
# 1. What data I want?
# 2. Deal with unexpected values
# 3. Choose some Data Models
# 4. INput data to the data models
# 5. test
# 6. repeat 3~5
# 7. test

# I want to do some forecasting of the new business opportunity
# I want to do some latent class analysis
# I want to do some market segmentation


library(poLCA)

# use sql clauds to manipulate the data frame
#install.packages("sqldf")
#library(sqldf)

#TCVfact <- cut(custom.data$TCV, 20)

unique(custom.data$Opportunity.Primary.Competitor)

# factorize the string value
custom.data$Opportunity.Primary.Competitor <- factor(custom.data$Opportunity.Primary.Competitor)
custom.data$Deal.Type <- factor(custom.data$Deal.Type)
custom.data$Status <- factor(custom.data$Status)

plot(as.numeric(custom.data$Opportunity.Primary.Competitor), custom.data$Deal.Type)

#head(as.numeric(custom.data$Deal.Type))
#head(as.numeric(custom.data$Status))
#length(as.numeric(custom.data$Deal.Type))



library(neuralnet)

#trainingdata <- cbind(as.numeric(custom.data$Opportunity.Primary.Competitor[1:3800]), as.numeric(custom.data$Deal.Type[1:3800]), as.numeric(custom.data$Status[1:3800]))
#trainingdata.q1 <- cbind(as.numeric(custom.data$Opportunity.Primary.Competitor[1:3800]), as.numeric(custom.data$Deal.Type[1:3800]), as.numeric(custom.data$Status[1:3800]))
#head(trainingdata)
#testdata <- cbind(as.numeric(custom.data$Opportunity.Primary.Competitor[38001:42000]), as.numeric(custom.data$Deal.Type[38001:42000]), as.numeric(custom.data$Status[38001:42000]))

#colnames(trainingdata) <- c("competitor", "dealtype", "status")
#colnames(testdata) <- c("competitor", "dealtype", "status")

#net.q1 <- neuralnet(status~dealtype+competitor, trainingdata, hidden = 10)

# Used for regression
traininginput <- as.data.frame(runif(100, min=0, max=100))
trainingoutput <- sqrt(traininginput)
trainingdata <- cbind(traininginput, trainingoutput)

colnames(trainingdata) <- c("Input", "Output")

net.sqrt <- neuralnet(Output~Input, trainingdata, hidden = 10, threshold = 0.01)

print(net.sqrt)

plot(net.sqrt)

testdata <- as.data.frame((1:10)^2)

net.results <-  compute(net.sqrt, testdata)

ls(net.results)
print(net.results$net.result)

cleanoutput <-  cbind(testdata, sqrt(testdata), as.data.frame(net.results$net.result))

colnames(cleanoutput)<-c("Input", "Expected Output", "Neural Net Output")

print(cleanoutput)

# Used for classification
library(nnet)
# factorize the string value
custom.data$Opportunity.Primary.Competitor <- factor(custom.data$Opportunity.Primary.Competitor)
custom.data$Deal.Type <- factor(custom.data$Deal.Type)
custom.data$Status <- factor(custom.data$Status)
custom.data$ProductLineName <- factor(custom.data$ProductLineName)
custom.data$MOA_ServiceLine <- factor(custom.data$MOA_ServiceLine)
custom.data$BusinessGroup <- factor(custom.data$BusinessGroup)
custom.data$Industry.AMID.2.Segment.Name <- factor(custom.data$Industry.AMID.2.Segment.Name)

levels(custom.data$Industry.AMID.2.Segment.Name)
plot(as.numeric(custom.data$Opportunity.Primary.Competitor), custom.data$Deal.Type)

#head(as.numeric(custom.data$Deal.Type))
#head(as.numeric(custom.data$Status))
#length(as.numeric(custom.data$Deal.Type))

sampledata <-  sample(c(1:length(custom.data$Status)), 30000, replace=FALSE)
# Training data
classdata <- cbind(as.numeric(custom.data$Opportunity.Primary.Competitor[sampledata]), as.numeric(custom.data$Deal.Type[sampledata]), as.numeric(custom.data$ProductLineName[sampledata]),as.numeric(custom.data$MOA_ServiceLine[sampledata]), as.numeric(custom.data$BusinessGroup[sampledata]),as.numeric(custom.data$Industry.AMID.2.Segment.Name[sampledata]) )
classes <- custom.data$Status[sampledata]
#classes <- if custom.data$Status != "Won" 
plot(classdata)
levels(custom.data$Deal.Type)
library(ggplot2)
#ggplot(custom.data, aes(x=as.numeric(Opportunity.Primary.Competitor), y=as.numeric(Deal.Type), colour=Status))

# Test data
testclassdata <- cbind(as.numeric(custom.data$Opportunity.Primary.Competitor[-sampledata]), as.numeric(custom.data$Deal.Type[-sampledata]),as.numeric(custom.data$ProductLineName[-sampledata]),as.numeric(custom.data$MOA_ServiceLine[-sampledata]),as.numeric(custom.data$BusinessGroup[-sampledata]) ,as.numeric(custom.data$Industry.AMID.2.Segment.Name[-sampledata]))
testclasses <- custom.data$Status[-sampledata]

# Training network
net.class <- nnet(classes ~ ., data=classdata, size = 10, decay = 0.1, maxit = 10000, trace=F)

# Test network
preds <- predict(net.class, testclassdata, type="class")



#table(testclasses,preds)
# Precise of the network
sum( testclasses == preds)/nrow(testclassdata)
class.PR(preds, testclasses)
plot(c(1,1))

nrow(custom.data[custom.data$TCV<100,])
#custom.data <- custom.data[!(custom.data$TCV<1),]
nrow(custom.data)

daysdata <- data.frame(custom.data$Status, as.numeric(custom.data$Deal.Type),custom.data$Daysin01, custom.data$Daysin02, custom.data$Daysin03, custom.data$Daysin04, custom.data$Daysin04a,custom.data$Daysin04b, custom.data$Daysin05,custom.data$DaysinCurrentStage,as.numeric(custom.data$Opportunity.Primary.Competitor))
colnames(daysdata)
# daysdata <- daysdata[!(daysdata$custom.data.TCV < 100),]
nrow(daysdata)
head(daysdata)
sampledays <-  sample(c(1:nrow(daysdata)), 30000, replace=FALSE)
classes <- daysdata$custom.data.Status[sampledays]
resampledays <- sample(sampledays, 300000, replace = TRUE)
classes2 <- daysdata$custom.data.Status[resampledays]

# some pca things
library(psych)
pc <- principal(daysdata[sampledays,2:11], nfactors = 3)
pc
net3.day.class <- nnet(classes~., data=daysdata[sampledays,2:8], maxit=1000, Hess = T,entropy = T, size=30,trace=F)

pred3.days <- predict(net3.day.class, daysdata[-sampledays,2:8], type="class")
sum(pred3.days == daysdata$custom.data.Status[-sampledays])/length(pred3.days)


# end of pca things

#svm
library(e1071)
model.svm <- svm(classes~., data=daysdata[sampledays,2:11])
pred.svm <- predict(model.svm, daysdata[-sampledays,2:11])
#pred.svm <- fitted(model.svm)
sum(pred.svm==daysdata$custom.data.Status[-sampledays])/length(pred.svm)

# end of svm
net.day.class <- nnet(classes~., data=daysdata[sampledays,2:11], maxit=10000, Hess = T,entropy = T, size=30,trace=F)

net2.day.class <- nnet(classes2~., data=daysdata[resampledays,2:11], maxit=4000,Hess = T, size=30,trace=F)
pred2.days <- predict(net2.day.class, daysdata[-sampledays,2:11], type="class")
sum(pred2.days == daysdata$custom.data.Status[-sampledays])/length(pred2.days)


pred.days <- predict(net.day.class, daysdata[-sampledays,2:11], type="class")
sum(pred.days == daysdata$custom.data.Status[-sampledays])/length(pred.days)
# A good training
#good <- net.day.class


pred.days <- predict(net.day.class, daysdata[,2:11], type="class")
sum(pred.days == daysdata$custom.data.Status)/length(pred.days)









