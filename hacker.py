# -*- coding: utf-8 -*-
import pandas as pd


train = pd.read_csv('train.csv')
test = pd.read_csv('test.csv')
train['Title'] = train['Name'].map(lambda Name:Name.split(',')[1].split('.')[0].strip())
test['Title'] = test['Name'].map(lambda Name:Name.split(',')[1].split('.')[0].strip())
Title_Dictionary = {
    "Capt": "Officer",
    "Col": "Officer",
    "Major": "Officer",
    "Jonkheer": "Royalty",
    "Don": "Royalty",
    "Sir": "Royalty",
    "Dr": "Officer",
    "Rev": "Officer",
    "the Countess": "Royalty",
    "Dona": "Royalty",
    "Mme": "Mrs",
    "Mlle": "Miss",
    "Ms": "Mrs",
    "Mr": "Mr",
    "Mrs": "Mrs",
    "Miss": "Miss",
    "Master": "Master",
    "Lady": "Royalty"

}
train['Title'] = train.Title.map(Title_Dictionary)
test['Title'] = test.Title.map(Title_Dictionary)
train.to_csv('train_title.csv',sep=',',index=False)
test.to_csv('test_title.csv',sep=',',index=False)