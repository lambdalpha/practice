#1. Load the xlsx data
Sys.setenv(JAVA_HOME='C:/Program Files/Java/jre7')
library(rJava)
library(xlsxjars)
library(xlsx)
data.mkt <- read.xlsx("C:/market.xlsx", 1)
library(arules)
trans <- as(split(data.mkt[,"ItemType"], data.mkt[,"Order.No"]), "transactions")
inspect(trans)

#2. Generate the rules
rules <- apriori(trans, parameter = list(minlen=2, supp=0.005, conf=0.5))
inspect(rules)
#3. Select top 100 rules sorted by lift as the candidate rule set for rule reduction
rules.cand <- head(sort(rules, by="lift"), 100)
inspect(rules.cand)

#4. Visualize the relationship among the candidate rules to to explore the interesting rule set
library(arulesViz)
plot(rules, measure=c("support", "lift"), shading="confidence")
plot(rules.cand, method="grouped")
subrules <- head(sort(rules, by="lift"), 40)

#5. Visualize the interesting rule set
inspect(subrules)
plot(subrules, method="graph", control=list(type="items"))
