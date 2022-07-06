from numpy import *
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
import matplotlib.pyplot as plt

m = 100
X = 6*random.rand(m,1)-3
y = 0.5*X**2+X+2+random.randn(m,1)
poly_features = PolynomialFeatures(degree=2,include_bias=False)
X_poly = poly_features.fit_transform(X)             # 平方项
# print(X_poly[:,0])
# print(X_poly[:,1])

# 线性回归
model = LinearRegression()                          # 导入模型
model.fit(X_poly,y)                                 # 训练模型
k1 = round(model.coef_[0][0],3)                     # 一次项系数
k2 = round(model.coef_[0][1],3)                     # 二次项系数
b = round(model.intercept_[0],3)                    # 截距
# print("k: %f" % k)
# print("b: %f" % b)

# 可视化
plt.scatter(X,y)                                    # 数据
X_axis = linspace(-3,3,100)                         # 回归模型
y_predict = b+k1*X_axis+k2*X_axis**2
l1, = plt.plot(X_axis,y_predict,linewidth=3,c='r')  
plt.legend(handles=[l1],labels=['y='+str(b)+'+'+str(k1)+'x'+'+'+str(k2)+'x^2'],loc='best')       
plt.xlabel('x')
plt.ylabel('y')
plt.title("Polynomial Regression")
plt.show()