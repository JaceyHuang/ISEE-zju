from Conv import *
from LoadMnistData import *
from Pool import *
import numpy as np
from scipy import signal

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

def softmax(x):
    """
    softmax函数
    Param:
        x: 输入
    Return: 
        y: 对应的softmax函数值
    """
    x = x - np.max(x)
    exp_x = np.exp(x)
    y = exp_x / np.sum(exp_x)
    return y

def ReLU(x):
    """
    ReLU函数
    Param:
        x: 输入
    Return:
        y: 对应的ReLU函数值
    """
    y = np.maximum(0, x)
    return y

def trainCNN(alpha, beta, batchSize, W1, W5, Wo, X, D, epochs):
    """
    训练CNN网络
    Param:
        alpha: 学习率
        beta: momentum参数
        batchSize: 每个batch的大小
        W1, W5, Wo: 网络的初始权重
        X: 图像
        D: 标签
        epochs: 训练轮数
    Return:
        W1, W5, Wo: 网络训练好的权重
    """
    m1 = np.zeros_like(W1)   # momentum 
    m5 = np.zeros_like(W5)
    mo = np.zeros_like(Wo)

    batchList = np.arange(0, X.shape[0], batchSize)

    for i in range(epochs):
        print('epoch: {}'.format(i))
        for index in range(len(batchList)):    # batch
            dW1 = np.zeros_like(W1)
            dW5 = np.zeros_like(W5)
            dWo = np.zeros_like(Wo)

            start = batchList[index]

            for j in range(start, start+batchSize):
                # 前向传输
                x = X[j, :, :]             # input, 28*28
                y1 = Conv(x, W1)           # 卷积层输出, 20*20*20
                y2 = ReLU(y1)              # 第二层输出, 20*20*20
                y3 = Pool(y2)              # 池化层输出, 10*10*20
                y4 = y3.reshape(2000, 1)   # 调整维度, 2000*1
                v5 = np.dot(W5, y4)        
                y5 = ReLU(v5)              # 第五层输出, 100*1
                v = np.dot(Wo, y5)
                y = softmax(v)             # 输出, 10*1

                # one-hot 编码
                gt = np.zeros((1, 10))     # 行向量, 1*10
                gt[0, D[j][0]] = 1

                # 后向传输
                e = gt.T - y               # 输出误差, 10*1
                delta = e                  # softmax导数为1, 10*1
                dWo += alpha*np.dot(delta, y5.T)  # 输出更新值, 10*100

                e5 = np.dot(Wo.T, delta)   # 第五层误差, 100*1
                delta5 = (v5>0)*e5         # 第五层delta, 100*1
                dW5 += alpha*np.dot(delta5, y4.T) # 第五层更新, 100*2000

                e4 = np.dot(W5.T, delta5)  # 第四层误差, 2000*1

                e3 = e4.reshape(y3.shape)  # 池化层误差, 10*10*20

                e2 = np.zeros_like(y2)     # 初始化第二层误差, 20*20*20
                W3 = np.ones_like(y2) / (2*2) 
                for c in range(20):
                    e2[:, :, c] = np.kron(e3[:, :, c], np.ones((2, 
                                           2)))*W3[:, :, c] 
                delta2 = (y2>0)*e2         # 第二层delta, 20*20*20

                delta1_x = np.zeros_like(W1) # 初始化卷积层delta
                for c in range(20):
                    delta1_x[:, :, c] = signal.convolve2d(x[:, :], 
                                   np.rot90(delta2[:, :, c], 2), 'valid')
                dW1 += delta1_x             # 卷积层更新值, 9*9*20

            dWo = dWo / batchSize      # 取平均
            dW5 = dW5 / batchSize
            dW1 = dW1 / batchSize

            mo = dWo + beta*mo         # momentum
            m5 = dW5 + beta*m5
            m1 = dW1 + beta*m1

            Wo = Wo + mo               # 更新权重
            W5 = W5 + m5
            W1 = W1 + m1
    return W1, W5, Wo

def testCNN(batchSize, X_test, D_test, W1, W5, Wo):
    """
    测试CNN网络
    Param:
        batchSize: 每个batch的大小
        X_test: 图像
        D_test: 标签
        W1, W5, Wo: 网络的权重
    Return:
        accuracy: 准确度
    """
    N = len(D_test)    # 测试集长度
    count = 0

    for i in range(X_test.shape[0]):
        # 前向传输
        x = X_test[i, :, :]        # input, 28*28
        y1 = Conv(x, W1)           # 卷积层输出, 20*20*20
        y2 = ReLU(y1)              # 第二层输出, 20*20*20
        y3 = Pool(y2)              # 池化层输出, 10*10*20
        y4 = y3.reshape(2000, 1)   # 调整维度, 2000*1
        v5 = np.dot(W5, y4)        
        y5 = ReLU(v5)              # 第五层输出, 100*1
        v = np.dot(Wo, y5)
        y = softmax(v)             # 输出, 10*1

        num = np.argmax(y)         # 判定的数字

        if D_test[i][0] == num:    # 识别正确
            count += 1

    accuracy = count / N
    return accuracy

def main():
    # 加载数据
    data, label = LoadMnistData('MNIST\\t10k-images-idx3-ubyte.gz', 
                                 'MNIST\\t10k-labels-idx1-ubyte.gz')
    data = np.divide(data, 255)
    X = data[0:8000, :, :]
    D = label[0:8000]

    # 初始化权重
    W1 = 0.01*np.random.randn(9, 9, 20)       # W1的维度为9*9*20
    W5 = 0.01*(2*np.random.rand(100, 2000)-1) # W5的维度为100*2000
    Wo = 0.01*(2*np.random.rand(10, 100)-1)   # Wo的维度为10*100

    # 初始化参数
    alpha = 0.01      # 学习率
    beta = 0.9        # momentum参数
    batchSize = 100   # batch的大小
    epochs = 5        # 训练轮数

    # 训练
    W1,W5,Wo = trainCNN(alpha, beta, batchSize, W1, W5, Wo, X, D,epochs)

    # 测试
    X_test = data[8000:10000, :, :]
    D_test = label[8000:10000]
    accuracy = testCNN(batchSize, X_test, D_test, W1, W5, Wo)
    print('The accuracy of the CNN net is {}'.format(accuracy))

if __name__ == '__main__':
    main()
