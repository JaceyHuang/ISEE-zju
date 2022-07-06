from numpy import *
import matplotlib.pyplot as plt

X = 2*random.rand(100,1)
y = 4+3*X+random.randn(100,1)                                # 高斯噪声

biasX = ones((100,1))
X_Mat = c_[biasX,X]                                           # 构造X矩阵
# print(X_Mat)

# 做线性回归
X_Mat_T = X_Mat.transpose()                                  # 转置
theta = dot(dot(linalg.inv(dot(X_Mat_T,X_Mat)),X_Mat_T),y)   # 矩阵乘法
b = round(float(theta[0]),3)                                 # 截距
k = round(float(theta[1]),3)                                 # 斜率

# 预测
x1 = [1,0]                                                   # x = 0
x2 = [1,2]                                                   # x = 2
y1 = dot(x1,theta)
y2 = dot(x2,theta)
print("(0,%f)" %y1)
print("(2,%f)" %y2)

# 可视化
plt.scatter(X, y)
X_axis = linspace(0,2,100)                                  # 回归模型
X_axis_Mat = c_[biasX,X_axis]
y_predict = dot(X_axis_Mat,theta)
l1, = plt.plot(X_axis,y_predict,linewidth=3,c='y')
plt.legend(handles=[l1],labels=['y='+str(b)+'+'+str(k)+'x'],loc='best')
plt.scatter([0],[y1],c='r')                                 # 预测结果x = 0
plt.scatter([2],[y2],c='r')                                 # 预测结果x = 2
plt.xlabel('x')
plt.ylabel('y')
plt.title("Linear Regression")
plt.show()