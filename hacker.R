rm(list = ls())

set.seed(1)

setwd('C:/Impact/Extra/Kaggle/Titanic')

library(xgboost)
library(dplyr)
library(randomForest)

train <- read.csv('train_title.csv')
test <- read.csv('test_title.csv')

test$Survived <- -2

# train$PassengerId <- NULL
train$Name <- NULL
# test$PassengerId <- NULL
test$Name <- NULL

train$Tag <- 'Train'
test$Tag <- 'Test'

train_te <- train[complete.cases(train),]
test_te <- test[complete.cases(test),]
combined_te <- rbind(train_te,test_te)

combined <- rbind(train,test)

for(level in unique(combined$Title)){
  combined[paste("title", level, sep = "_")] <- ifelse(combined$Title == level, 1, 0)
}

combined$Sex <- ifelse(combined$Sex=='female',1,0)
combined_te$Sex <- ifelse(combined_te$Sex == 'female',1,0)


ageGroup <- group_by(combined_te,Sex,Pclass,Title)
ageGroup <- summarise(ageGroup,medianAge = median(Age))

combined <- merge(combined,ageGroup,c('Sex','Pclass','Title'))
combined$Age = ifelse(is.na(combined$Age),combined$medianAge, combined$Age)
combined$medianAge = NULL


combined$Embarked[combined$Embarked == ''] <- 'S'

for(level in unique(combined$Embarked)){
  combined[paste("Embarked", level, sep = "_")] <- ifelse(combined$Embarked == level, 1, 0)
}

combined$Embarked <- NULL

combined$Title <- NULL
combined$Ticket <- NULL
combined$Cabin <- NULL


X_train <- combined[combined$Tag == 'Train',]
X_train$Tag <- NULL
X_target <- as.numeric(X_train$Survived)
X_train$Survived <- NULL
X_test <- combined[combined$Tag == 'Test',]
X_test$Survived <- NULL
X_test$Tag <- NULL
X_ids <- X_test$PassengerId
# write.csv(X_test,"rand_test.csv",row.names = F)
X_train$PassengerId <- NULL
X_test$PassengerId <- NULL

cols <- c("Sex","Pclass","Age","SibSp","Parch","Fare","title_Mr","title_Mrs","title_Miss","title_Master","title_Royalty","title_Officer","Embarked_C","Embarked_S","Embarked_Q")
X_train[,cols] <- apply(X_train[,cols], 2, function(x) as.numeric(as.character(x)))
X_test[,cols] <- apply(X_test[,cols], 2, function(x) as.numeric(as.character(x)))

# model_xgb_cv <- xgb.cv(data=as.matrix(X_train), label=as.matrix(X_target), nfold=10, objective="binary:logistic", nrounds=200, eta=0.05, max_depth=6, subsample=0.75, colsample_bytree=0.8, min_child_weight=1, eval_metric="auc",missing=NA)
model_xgb <- xgboost(data=as.matrix(X_train), label=as.matrix(X_target), objective="reg:linear", nrounds=600, eta=0.2, max_depth=20, subsample=0.75, colsample_bytree=0.8, min_child_weight=1, eval_metric="auc",missing=NA)
importance <- xgb.importance(feature_names = cols, model = model_xgb)
pred <- predict(model_xgb, as.matrix(X_test),missing=NA)
prediction <- as.numeric(pred > 0.5)

submit <- data.frame("PassengerId"=X_ids, "Survived"=prediction)
write.csv(submit, "./ensemble/submit_xgb.csv", row.names=F)

