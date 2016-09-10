# -*- coding: utf-8 -*-

from sklearn.ensemble import RandomForestClassifier
from sklearn import cross_validation
import pandas as pd
import numpy as np
from sklearn.ensemble import ExtraTreesClassifier

train = pd.read_csv('rand_train.csv')
test = pd.read_csv('rand_test.csv')
print test.isnull().any().any()
print train.columns

predictors = ["Sex","Pclass","Age","SibSp","Parch","Fare","title_Mr","title_Mrs","title_Miss","title_Master","title_Royalty","title_Officer","Embarked_C","Embarked_S","Embarked_Q"]

y = train['Survived']
y = np.array(y).astype(int)

alg = RandomForestClassifier(
    random_state=1,
    n_estimators=5000,
    n_jobs=-1
)
# print 'loading score'
# scores = cross_validation.cross_val_score(
#     alg,
#     train[predictors],
#     y
# )
# print(scores.mean())

lr = ExtraTreesClassifier(n_estimators=5000,n_jobs=-1)
# scores = cross_validation.cross_val_score(
#     lr,
#     train[predictors],
#     y
# )
# print(scores.mean())
print 'RFAlgo Started'
alg.fit(train[predictors],y)
predictions =alg.predict(test[predictors])
submissions = pd.DataFrame({
    "PassengerId": test["PassengerId"],
    "Survived": predictions
})
submissions.to_csv('submit_rf.csv', sep=',',index=None )
print 'LRAlgo Started'
lr.fit(train[predictors],y)
predictions = lr.predict(test[predictors])
submissions = pd.DataFrame({
    "PassengerId": test["PassengerId"],
    "Survived": predictions
})
submissions.to_csv('submit_lr.csv', sep=',',index=None )