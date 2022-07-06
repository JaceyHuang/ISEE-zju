from numpy import *
from sklearn import datasets
from sklearn.linear_model import LogisticRegression
import matplotlib.pyplot as plt

# 加载数据
iris = datasets.load_iris()
X = iris["data"][:,3:]
y = (iris["target"]==2).astype(int)

# 分类器
classifier = LogisticRegression()                                  # 导入模型
classifier.fit(X,y)                                                # 训练模型
width = linspace(0,3,100)                                          # 预测
probability = classifier.predict_proba(reshape(width,[len(width),1]))
# probability = classifier.predict(reshape(width,[len(width),1]))  # 预测类别

# 可视化
l1, = plt.plot(width,probability[:,0],linewidth=3)
l2, = plt.plot(width,probability[:,1],linewidth=3)
# l1, = plt.plot(width,probability,linewidth=3)
plt.legend(handles=[l1,l2],labels=["Not Iris-Vir","Iris-Vir"],loc='best')
# plt.legend(handles=[l1],labels=["Iris-Vir"],loc='best')
plt.xlabel('Width/cm')
plt.ylabel('Probability')
# plt.ylabel('Category')
plt.title("Logistic Regression")
plt.show()