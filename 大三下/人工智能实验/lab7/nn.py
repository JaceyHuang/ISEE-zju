import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import make_interp_spline

def sigmoid(x):
    """
    sigmoid函数
    Param:
        x: 输入
    Return: 
        y: 对应的sigmoid函数值
    """
    y = 1./(1+np.exp(-x))
    return y

def mse(x, y):
    """
    计算均方误差
    Param:
        x, y: 输入
    Return:
        x与y的均方误差向量
    """
    MSEs = []
    for i in range(x.shape[1]):
        xi = x[:,i]                   # 列向量
        MSE = 0                       # 初始化
        for j in range(len(y)):
            square = (xi[j]-y[j])**2  # 平方和
            MSE += square
        MSE /= len(y)                 # 取平均
        MSEs.append(MSE)
    return MSEs

def creat_network(net_type, inputs, gts, epoch):
    """
    构造神经网络
    Param: 
        net_type: 网络的类型
        inputs: 数据输入
        gts: 正确值
        epoch: 训练轮数
    Return: 
        weight: 训练好的权重
    """
    weight = np.array([0,0,0]) # 初始化权重为[0,0,0]
    # weight = np.array([1,1,1]) # 初始化权重为[1,1,1]，行向量
    alpha = 0.9                # 参数
    if net_type == 'SGD':      # 随机梯度下降
        for i in range(epoch):
            for j in range(inputs.shape[0]):     # 每轮需要调整权重的次数
                # index = np.random.randint(inputs.shape[0]) # 随机取一行
                # input = inputs[index]
                input = inputs[j]                             # 依次选取
                output = sigmoid(np.dot(weight, input.T))  # 计算输出
                # e = gts[index] - output 
                e = gts[j] - output                        # 输出误差
                delta = alpha*output*(1-output)*e*input   # 误差更新值
                weight = weight + delta                    # 更新权重
    elif net_type == 'Batch':
        deltas = []
        for i in range(epoch):
            for j in range(inputs.shape[0]):               # 每一行
                input = inputs[j]
                output = sigmoid(np.dot(weight, input.T)) # 计算输出
                e = gts[j] - output                        # 输出误差
                delta = alpha*output*(1-output)*e*input   # 误差更新值
                deltas.append(delta)                       # 保存
            final_delta = sum(deltas)/len(deltas)
            weight = weight + final_delta
    return weight

def main():
    dataset = np.array([[0,0,1,0],[0,1,1,0],[1,0,1,1],[1,1,1,1]])
    inputs = dataset[:,0:3]       # 输入
    gts = dataset[:,3:4]          # ground truth
    outputs_SGD = []              # 初始化输出，利于可视化
    outputs_Batch = []
    epochs = 1000
    for epoch in range(1, epochs): 
        # 使用SGD构造神经网络
        nn_SGD = creat_network('SGD', inputs, gts, epoch) 
        # 使用Bacth构造神经网络
        nn_Batch = creat_network('Batch', inputs, gts, epoch) 
        output_SGD = sigmoid(np.dot(nn_SGD, inputs.T))     # SGD的结果
        output_Batch = sigmoid(np.dot(nn_Batch, inputs.T)) # Batch的结果
        outputs_SGD.append(output_SGD)                      # 保存结果
        outputs_Batch.append(output_Batch)
    outputs_SGD = np.array(outputs_SGD)
    outputs_Batch = np.array(outputs_Batch)
    print('Outputs of SGD:\n',outputs_SGD)
    print('Outputs of Batch:\n',outputs_Batch)
    MSE_SGD = mse(outputs_SGD.T, gts)                     # 均方误差
    MSE_Batch = mse(outputs_Batch.T, gts)
    epoch = np.linspace(1,epochs,epochs-1)
    model_SGD = make_interp_spline(epoch, MSE_SGD)       # 绘制平滑曲线
    model_Batch = make_interp_spline(epoch, MSE_Batch)   # 绘制平滑曲线  
    y_SGD = model_SGD(epoch)
    y_Batch = model_Batch(epoch)
    l1, = plt.plot(epoch, y_SGD)
    l2, = plt.plot(epoch, y_Batch)
    plt.legend(handles=[l1,l2],labels=["SGD","Batch"],loc='best')
    plt.title('MSE')
    plt.show()

if __name__ == "__main__":
    main()
