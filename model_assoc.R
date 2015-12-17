#1. Load the xlsx data

data.mkt <- read.delim("C:/app/r/ship1214.csv", header = T, sep = ',', stringsAsFactors=F)
names(data.mkt)

data.mkt <- data.mkt[,c('product_model', 'sales_order_id')]

library(arules)
index <- duplicated(data.mkt)

data.mkt1 <- data.mkt[!index,]
data.mkt1 <- data.mkt1[data.mkt1$product_model != 'N/V',]
trans <- as(split(  data.mkt1[,"product_model"], data.mkt1[,"sales_order_id"]), "transactions")
#inspect(trans)

#2. Generate the rules
rules <- apriori(trans, parameter = list(minlen=2, supp=0.005, conf=0.5))
rules
head(inspect(rules))
#3. Select top 100 rules sorted by lift as the candidate rule set for rule reduction
rules.cand <- head(sort(rules, by="lift"), 100)
inspect(rules.cand)

#4. Visualize the relationship among the candidate rules to to explore the interesting rule set
library(arulesViz)
plot(rules, measure=c("support", "lift"), shading="confidence")
plot(rules.cand, method="grouped")
subrules <- head(sort(rules, by="lift"), 100)

#5. Visualize the interesting rule set
inspect(subrules)
plot(subrules, method="graph", control=list(type="items"))


save.image("c:/app/assoc.RData")

