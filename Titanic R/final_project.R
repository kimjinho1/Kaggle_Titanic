Sys.setenv(JAVA_HOME="C:/Program Files/Java/jdk-13.0.1")

## train ������ �ҷ�����
train = read.csv("titanic_train.csv",stringsAsFactor = FALSE)
dim(train) # 12�� 891�� -> ���� 12�� ������ 891��
head(train)
train_length =dim(train)[1]; train_length

## test ������ �ҷ�����
test = read.csv("titanic_test.csv")
test_id = test$PassengerId
dim(test) # 11�� 418�� -> ���� 11�� ������ 418�� -> target �����Ͱ� ����
head(test)

# train���� PassengerId�� �ʿ������ ����, train�� test�� ��ġ�� ���� 
# test�� PassengerId�� Survived�� ��� �и��Ѵ�.
target = data.frame(train$Survived)
colnames(target) = "Survived"; head(target)
train = train[-c(1, 2)]; colnames(train)

id = data.frame(test$PassengerId)
colnames(id) = "PassengerId"; head(id)
test = test[-1]; colnames(test)

df = rbind(train, test); dim(df)

## ������ ����
# PassengerId -> ��ȣ
# Survived -> ���� (0 = No; 1 = Yes)
# Pclass -> ��� Class (1 = 1st; 2 = 2nd; 3 = 3rd)
# name -> �̸�
# sex -> ����
# age	-> ����
# sibsp ->	�����ڸ�, ����� ���� ��
# parch	-> �θ��, ���� ���� ��
# ticket -> Ƽ�� ��ȣ
# fare ->	���
# cabin -> ����
# embarked ->	������(C = Cherbourg, Q = Queenstown, S = Southampton)
summary(df)


## missing value ã�� 
sapply(df, function(x) sum(is.na(x)))
# Age�� missing value�� �ִٰ� �ߴµ� �߸����. Age���� NA�� 
# �������� �ٸ� missing value�� �׳� �����̱� ������ �ν��� �ȵǾ��� �����̴�.
# �Ʒ����� ������� ���鿡�� NA�� ����־� �����.
df = lapply(df, function(x) 
  type.convert(replace(x, grepl("^\\s*$", trimws(x)), NA), as.is = TRUE)) 
df = as.data.frame(df)
# ������ ��� missing value�� ã�Ҵ�.
sapply(df, function(x) sum(is.na(x)))


## ������ ��ó��(��ȯ, ����)
## Fare�� missing-value�� �ϳ��̱� ������ �׳� ����� �ִ´�.
# S�� ä���൵ �� �� ����.
Fare_mean = mean(df$Fare[is.na(df$Fare) == FALSE]); Fare_mean
df$Fare[is.na(df$Fare) == TRUE] = Fare_mean

  
## Embarked���� S�� ������ ���� 70%�� �Ǳ� ������ 2���� missing value��
Embarked_summary = sort(summary(df$Embarked)); Embarked_summary
Embarked_S = Embarked_summary[4]
Embarked_S_per = Embarked_S / sum(Embarked_summary); Embarked_S_per
# Embarked�� missing value�� S�� ä��
df$Embarked[is.na(df$Embarked) == TRUE] = "S"
summary(df$Embarked)
sapply(df, function(x) sum(is.na(x)))


# Name, Ticket�� �����ͷ� ����ϱ� ���� �� ���� Cabin�� 
# missing value�� �ʹ� ���Ƽ� ����� �� ���� ������ ������ ����.
colnames(df)
head(df[c("Name", "Ticket")])
df = df[c("Pclass","Sex","Age","SibSp","Parch","Fare","Embarked")]
sapply(df, function(x) sum(is.na(x)))


## Sibsp �� Parch�� ���� 2���� �������� ���� �ʿ䰡 ����δ�.
# 2���� ���� ���� Family��� ������ �����Ϳ� �߰��Ѵ�.
df["Family_size"] = df["SibSp"] + df["Parch"]
head(df$Family_size)


## �ʿ���� �����͸� ������ �����Ѵ�.
df = df[c("Pclass","Sex","Age","Fare","Embarked","Family_size")]
head(df)


## Age�� ���� ������ �ؼ� missing-value�� ä���� �� ���� �� ����.
library(corrplot)
# missing-value�� ���� �����͸� �����ϰ� ����м��� ������
temp_df = df[is.na(df$Age) == FALSE & is.na(df$Fare) == FALSE,]; temp_df
head(temp_df)
cor(temp_df[-c(2,5)])
cor_coef = cor(temp_df[-c(2,5)])
# Age�� Pclass�� ���� ���� ���� ���踦 ���δ�. 
corrplot(cor_coef, method="circle")
# p-value�� 0.05���� �����Ƿ� �͹������� �Ⱒ
# -> Age�� Pclass�� ���Ǽ��� �ִ�.
cor.test(df$Age, df$Pclass)
# Pclass�� ���缭 Age�� ���� ä������
for(i in 1:3)
{
  df[df$Pclass == i & is.na(df$Age), "Age"] = 
              mean(df[df$Pclass == i, "Age"], na.rm=TRUE)
}
head(df$Age)


# �̷��� �л�м��� ���� ���� ������ ���� �߶� ������ ���´�.
temp = df 

############################## ������ ��ó���� �ߴ� ##############################


## python���� flatten�̶�� �Լ��� ����߾��µ� R���� ����Ѱ� �ִ� �� �����ѵ�
# �� ������ �ȵǼ� �Լ��� ���� �����غ��Ҵ�.
flatten = function(v, t, n, len)
{
  for(i in 1:len)
  {
    if(df[i, v] == t)
      df[i, n] = 1
    else
      df[i, n] = 0
  }
  return(df[n])
}
## Sex�� Male�� Female�� ������, Embarked�� C, Q, S�� ������.
len = dim(df)[1]; len
df["Male"] = flatten("Sex", "male", "Male", len)
df["Female"] = flatten("Sex", "female", "Female", len)
df["Embarked_C"] = flatten("Embarked", "C", "Embarked_C", len)
df["Embarked_Q"] = flatten("Embarked", "Q", "Embarked_Q", len)
df["Embarked_S"] = flatten("Embarked", "S", "Embarked_S", len)
head(df)


## ���ʿ��� ������(Sex, Embarked) ����
df = df[-c(2, 5)]
head(df)


## �ڿ� �� ����ȸ�ͺм�, ���� �� �����, Survived�� �ٸ� ������ ���� �м��� �ϱ� ���� 
## ó���� �����͸� train�� test�� �ٽ� ������.
train = df[1:train_length,] 
train = cbind(target, train) 
head(train); dim(train)

test = df[(train_length+1):dim(df)[1],]
head(test); dim(test)


## ���� Survived�� �ٸ� �������� ���踦 �м��غ���

## ����м��� ���� �׸�(boxplot)
cor_coef = cor(train)
corrplot(cor_coef, method="circle")
# ���⼭ Male�� Survived�� ���� ���� ���踦, Female�� Survived�� ���� ���� ���踦
# �����ٴ� ���� �� �� �ִ�. -> �̴� ������ �������� �������� �ξ� ���� ���̶�� �����ش�.

check = read.csv("titanic_train.csv")
table(check$Sex)
library(ggplot2)
ggplot(data=data, aes(x=Sex, y=Survived, color=Sex)) + geom_bar(stat = "identity")
# �̴� ���� ���� ��������ε� Ȯ���� �� �ִ�.
 
corrplot(cor_coef, method="circle") 
cor.test(train$Survived, train$Pclass) 
cor.test(train$Survived, train$Age) 
cor.test(train$Survived, train$Fare)
cor.test(train$Survived, train$Family_size)
cor.test(train$Survived, train$Male)
cor.test(train$Survived, train$Female)
cor.test(train$Survived, train$Embarked_C)
cor.test(train$Survived, train$Embarked_Q)
cor.test(train$Survived, train$Embarked_S)

# Family_size�� Embarked_Q�� �����ϰ� ���� p-value�� 0.05���� �����̹Ƿ� �͹������� �Ⱒ
# -> Family_size�� Embarked_Q�� ������ ������ �������� Survived�� ���Ǽ��� �ִ�. 

# Age�� Survived�� ū ���Ǽ��� ������ �˾Ҵµ� �׷��� �ʾҴ�.
# Data binning�� ���� �ʾƼ� �׷� �� ����...
# �׷��� ������ ���� ���踦 ������ �ִ� ���� �����ϴ� ���̰� ����� �� Ȯ���� ���� �� 
# ���ٴ� ���� �� �� �ִ�.


# Embarked�� ���� C�� Survived�� ���� ����, S�� Survived�� ���� ���踦 ���̴µ�
# �̴� S���� C���� �踦 ź ����� ���� �� Ȯ���� ���ٴ� ���� �����ش�.

# Pclass�� Survived�� ���� ���踦 ������ ���� ���� Pclass�� ��������(����� ��������) 
# �������� �ö��� Ȯ���� �� �ִ�.

# Fare�� Survived�� ���� ���� ���Ը� ���δ�. �̴� ����� ���� ����ϼ��� �� ��� ���� �ڸ��� 
# ž���߱� ������ ������ Ȯ���� ������ ���̶�� �� �� �ִ�.

# Fare�� Pclass�� ��ekd�� ū ���� ���踦 ������ �ִ�. Survived�� ���� ���Ǽ��� Ȯ���ϴ� ���� 
# �ƴϱ� ������ �����Ͱ� �� ���� temp(�տ��� ������)�����͸� ����Ѵ�.
cor.test(temp$Fare, temp$Pclass)
# Fare�� Pclass�� ���Ǽ��� �ְ� ���� ū ���� ���Ը� ���δ�.
# Pclass�� �������� ����� ������ Fare(ž�� ���)�� �� ���� ���̶�� �� �� �ִ�.
# �ڽ� ���ڷε� Ȯ���� ����
temp$Pclass = factor(temp$Pclass, label = c("������","����","������"))
temp$Pclass
boxplot(Fare~Pclass, data = temp)
# ���ó� �����Ҽ��� Fare�� ���ٴ� ���� Ȯ���� �� �ִ�.

# �տ� Fare, Pclass, Embarked�� �м��� ���� C�� ��ΰ� ���� �ڸ��̰� S�� �ΰ� ������ �ڸ��� 
# �Ŷ�� ������ �����ѵ�. �̿��л�м��� ���� �� ������ �´��� Ȯ���غ���

## �л�м�
library(psych)
library(car)
# ���Լ� ����
shapiro.test(temp$Fare) 
#shapiro.test(temp$Pclass) 
#shapiro.test(temp$Embarked) 
# ������ ����
chisq.test(temp$Pclass, temp$Embarked)
#chisq.test(temp$Fare, temp$Pclass)
#chisq.test(temp$Fare, temp$Embarked)
# ��л꼺 �˻�
leveneTest(Fare~Pclass, data = temp) 
leveneTest(Fare~Embarked, data = temp) 
leveneTest(Fare~Pclass*Embarked, data = temp) 
# �̿��л�м�
aov2 = aov(Fare~Pclass + Embarked + Pclass:Embarked, data = temp)
summary(aov2)
# Plclass, Embarked, Pclass*Embarked�� p-value�� 0.05 �����̹Ƿ� �͹����� �Ⱒ. ���Ǽ��� ����

## ��ȣ�ۿ� �׷��� �׸���
interaction.plot(x.factor = temp$Pclass,
                 trace.factor = temp$Embarked,
                 response = temp$Fare, function(x) mean(x),
                 type = "b", legend=TRUE,
                 xlab="���", ylab="���",
                 pch=c(1,19), col = c("red", "green"))

interaction.plot(x.factor = temp$Embarked,
                 trace.factor = temp$Pclass,
                 response = temp$Fare, function(x) mean(x),
                 type = "b", legend=TRUE,
                 xlab="�ڸ�", ylab="���",
                 pch=c(1,19), col = c("red", "green"))

# �׷����� �����ϴ� �� C�� ��ΰ� ���� �ڸ�, S�� ���ڰ� �� �ڸ��� �ƴϴ�. ������ ����� 
# ��� S�� ������ �� ����� ���Ұ�, ���� ����� ��� C�� S�� ����� ū ���̰� ����.
# �㳪 ������ ����� ��� C, Q, S ������ ����� ���� ���� �����ش�. �̰� ���� C�� S���� 
# ���� �ڸ���⺸�ٴ� �׳� ������ ������� C�� �� �� ��ȣ�� �� ����. 


### �տ��� �� �м��� �������� ����ϸ� �� Ÿ��Ÿ�� �����Ϳ��� ������       ###
### ���� �߿��� ��Ҵ� ����, ���, ���, ������, ����, ������ �� �����̴�. ###
### ���� ��� ���̰� ��� ����� ���� ������ �� Ȯ���� ���� ����,        ###
### ���̰� ���� ����� ���� ������ �������� ���� ���� ���̴�.              ###


### ���� �� ������

## ����ȸ�ͺм�
# Ÿ��Ÿ�� ������ �з������� ����ȸ�ͺм��� �ǹ̰� ������ 
# ����ȸ�ͺм��� �ϸ� ��� ������ �ñ��ؼ� �� �� �غ��ҽ��ϴ�.
plot(train)
pairs(Survived~., data=train, panel=function(x, y) {points(x, y, col="black")
  abline(lm(y~x), col="red", lwd=2)})
lm_out = lm(Survived~., data=train)
summary(lm_out)
# ó���� Ÿ��Ÿ�� �����͸� ����� ����ȸ�͸����� �������. ���⼭ ���Ǽ��� �ִ� ����ġ�� 
# p_value�� 0.05���Ͽ��� �͹������� �Ⱒ�� bias, Male, Female, Age, Pclass�̴�.
library(QuantPsyc)
lm.beta(lm_out)


## rpart(�ǻ��������)
# rpart�� ���̺귯���� ����ϸ� ���� �ǻ���������� ���� �� �ְ� �ǻ���������� ����
# � ������ ���� �߿������� ������ �м� ���� ���� Ȯ���� �� �ִ�.
library(rpart)
rpart_fit = rpart(Survived ~ ., data = train)
library(rpart.plot)
rpart.plot(rpart_fit)
# ���� ��(�Ѹ�)�� Male�� �ִµ� ������ ��� �������� 19%, ������ ��� 74%���� �� �� �ִ�.
# �Ʒ��� �������� ������ ��쿡 �������� �߿��� ��Ҵ� ���̰� ������ ��쿡�� ����̾���. 
# ������ ��� 6, 7�� �̻��̶�� �������� 17%����, 6, 7�� ����(�Ʊ�)�� ��� �������� 67%�� 
# ���� �� �� �ִ�. �̴� ������� �Ʊ���� ��Ե� �츮���� ����� ������ �����ش�. 
# ������ ���� �� ���̿� �������� ���� ���ǽ�Ű�� �Ͱ� ���� ��Ȳ�� �� ����.
# ������ ��� Pclass�� 3�̻�(������)�̸� �������� 50������, Pclass�� 3���� ������ ��������
# 95%�� �ȴ�. �̸� ���� ������ ���� ���ǽ��״ٴ� ���� �� �� �ִ�. ������ ��쵵 �� ���� ������ 
# ���� ���� ������ �߿��� ����� ����� �ִµ� ����� �� ���̰� ���ϴ�. ����, ����� �������
# �������� 12%�� �ݸ� ������ �������� 36%�� �ȴ�. �ǻ���������� ��ü������ ������� �� 
# ������ ���� �߿��� ��Ҵ� ����, ����, ������� �� �� �ִµ� �� ����� ���� �м� ����� ����.


# csv ���Ϸ� ����
write.csv(rpart_pred, file="rpart_pred.csv", row.names = FALSE)

## ���� �������� ����� ����.
# rpart ���� ��
# target�� Survived�� ���������� ����
train$Survived = factor(train$Survived, labels=c("0","1"))

# train �����͸� ����Ͽ� ���� ����
rpart_fit = rpart(Survived ~ ., data = train)

# test �����͸� ����Ͽ� Survived�� ����
rpart_pred = predict(rpart_fit, newdata=test, type="class")
rpart_pred = data.frame(rpart_pred); head(rpart_pred)

# kaggle�� Submission�� �����ϱ� ���� �� �̸��� Survived�� �ٲٰ� PassengerId�� �߰����ش�.
colnames(rpart_pred) = "Survived"
rpart_pred = cbind(id, rpart_pred); head(rpart_pred)

# csv ���Ϸ� ����
write.csv(rpart_pred, file="rpart_pred.csv", row.names = FALSE)

# �� ����Ǿ����� Ȯ��
check = read.csv("rpart_pred.csv"); head(check)

# ����������Ʈ ���� ��
library(randomForest)
# ����������Ʈ�� mtry��� �Ķ���Ͱ� �ֱ� ������ �ݺ����� �Ἥ ���� ���� ���� ã�ƾ� �Ѵ�.
# �̸� ���� train �����Ϳ��� �� train�����͸� �����. 
# Kaggle�� test �����Ϳ��� target�� ��� �̷������� �ϰ� �ǳ׿�...
# mtry�� ������ tree���� �� ���� ������ ����� �������� ���ϴ� �Ķ�����̴�.
n=nrow(train)
train_set=sample(n, floor(n/2))
test_set = train[-train_set,]

# ���� ��Ȯ���� mtry��  ���� ����Ʈ�� ����(������ 9���̱� ������ 1���� 9���� �ݺ��Ѵ�)
best_rf_mse =  0
for(i in 1:9)
{
  # train�� train_set�� ����Ͽ� ���� ����
  rf_fit = randomForest(Survived~., data = train[train_set,], mtry = i)
  
  # train�� test_set�� ����Ͽ� Survived�� ����
  rf_pred = predict(rf_fit, newdata=test_set, type= 'response')
  
  # ��Ȯ�� ����
  mean <- mean(rf_pred == train$Survived[-train_set])
  
  # ���� ������ ���� ���� �����ϴ� �κ�
  if(mean > best_rf_mse)
  {
    best_rf_mse = mean
    random_forest_fit = rf_fit
    best_mtry = i
  }
}


# ���� ���� ������ ���� mtry�� 3�̰� ��Ȯ���� 85.2% �����̴�. 
# ��� train_set ������ ���� ����� �� �� �ٲ��.
best_mtry; best_rf_mse
#importance(random_forest_fit) 
# mtry�� best_mtry(3)�� ���ϰ� test �����͸� ����Ͽ� Survived�� ����
random_forest_fit = randomForest(Survived~., data = train[train_set,], mtry = best_mtry)
random_forest_pred = predict(random_forest_fit, newdata = test)
random_forest_pred = data.frame(random_forest_pred); head(random_forest_pred)

# kaggle�� Submission�� �����ϱ� ���� �� �̸��� Survived�� �ٲٰ� PassengerId�� �߰����ش�.
colnames(random_forest_pred) = "Survived"
random_forest_pred = cbind(id, random_forest_pred); head(random_forest_pred)

# csv ���Ϸ� ����
write.csv(random_forest_pred, file="random_forest_pred.csv", row.names = FALSE)

# �� ����Ǿ����� Ȯ��
check = read.csv("random_forest_pred.csv"); head(check)

### Kaggle�� ���� rpart�� ����������Ʈ�� ������ ����� �����ߴ�.
# rpart -> 0.77511 -> 6500 ��
# ����������Ʈ -> 0.77551 -> 6500 ��
# �ظ��ϸ� ����������Ʈ�� ���� ������ ���ٰ� �����ϸ� ���������� ���� ������ ���͹��ȴ�. 
# ��� train_set�� ������ Ȯ���� ���� ����. 
# ��ü������ ������ ���̱� ���ؼ��� Age�� Fare�� binning�ؾ� �� �� ����.
# �ƴϸ� Age���� ���� ���� missing value�� ������ �ִ� �����͸� Pclass�� ���� ä�����µ�, 
# �� ����� �� �� �����Ѵٸ� ������ ���� ���� ���� �� ����.

# �׳� ����������Ʈ�� train �ϴ� �ھƺ���. ���� �� �� ���� �� ����.

########################## ������ �� �б⵿�� �����ϼ̽��ϴ�! ##########################