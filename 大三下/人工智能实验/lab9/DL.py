import numpy as np

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

def DLReLU(X, D, epochs):
    """
    通过SGD训练方法、ReLu激活函数及BP规则, 构造四层深度学习网络
    Param:
        X: 输入矩阵
        D: Ground Truth
        epochs: 训练轮数
    Return:
        W1, W2, W3, W4: 每层的权重
    """
    # 初始化权重
    W1 = 2*np.random.random((20,25))-1
    W2 = 2*np.random.random((20,20))-1
    W3 = 2*np.random.random((20,20))-1
    W4 = 2*np.random.random((5,20))-1
    
    alpha = 0.01 # 学习率
    for i in range(epochs):
        for j in range(X.shape[0]):
            input = X[j].reshape(25,1)    # 依次选取输入，25*1
            
            # forward
            v1 = np.dot(W1, input)        # 第一层相乘结果，20*1
            y1 = ReLU(v1)                 # 第一层输出，20*1

            v2 = np.dot(W2, y1)           # 第二层相乘结果，20*1
            y2 = ReLU(v2)                 # 第二层输出，20*1

            v3 = np.dot(W3, y2)           # 第三层相乘结果，20*1
            y3 = ReLU(v3)                 # 第三层输出，20*1

            v4 = np.dot(W4, y3)           # 第四层相乘结果，5*1
            y4 = softmax(v4)              # 第四层输出，5*1
            
            # backward
            e4 = D[j].reshape(5,1) - y4   # 第四层输出误差，5*1
            delta4 = e4                    # softmax的导数取1
            dW4 = alpha*delta4*y3.T       # 第四层更新值，5*20

            e3 = np.dot(W4.T, delta4)     # 第三层输出误差，20*1
            delta3 = (v3>0)*e3            # 第三层delta，20*1
            dW3 = alpha*delta3*y2.T       # 第三层更新值，20*20

            e2 = np.dot(W3.T, delta3)     # 第二层输出误差，20*1
            delta2 = (v2>0)*e2            # 第二层delta，20*1
            dW2 = alpha*delta2*y1.T       # 第二层更新值，20*20

            e1 = np.dot(W2.T, delta2)     # 第一层输出误差，20*1
            delta1 = (v1>0)*e1            # 第一层delta，20*1
            dW1 = alpha*delta1*input.T    # 第一层更新值，20*25

            W1 = W1 + dW1                 # 第一层权重
            W2 = W2 + dW2                 # 第二层权重
            W3 = W3 + dW3                 # 第三层权重
            W4 = W4 + dW4                 # 第四层权重
    return W1, W2, W3, W4

def showReLU(X, W1, W2, W3, W4):
    """
    输出ReLU训练后的结果
    Param:
        X: 输入矩阵
        W1, W2, W3, W4: 每层的权重
    Return:
    """
    outputs = np.zeros((5,5))
    for i in range(X.shape[0]):
        input = X[i].reshape(25,1)    # 依次选取输入，25*1
        
        # forward
        v1 = np.dot(W1, input)        # 第一层相乘结果，20*1
        y1 = ReLU(v1)                 # 第一层输出，20*1

        v2 = np.dot(W2, y1)           # 第二层相乘结果，20*1
        y2 = ReLU(v2)                 # 第二层输出，20*1

        v3 = np.dot(W3, y2)           # 第三层相乘结果，20*1
        y3 = ReLU(v3)                 # 第三层输出，20*1

        v4 = np.dot(W4, y3)           # 第四层相乘结果，5*1
        output = softmax(v4)          # 第四层输出，5*1

        outputs[i,:] = output.reshape(1,5) # 保存结果
    print('实验6-1的训练结果为: \n', outputs, '\n')

def Dropout(y, p):
    """
    Dropout技巧
    Param:
        y: 输入向量
        p: Dropout rate
    Return:
        ym: 激活值
    """
    ym = np.zeros_like(y)             # 与y同样维度，全0
    n_remain = round(len(y)*(1-p))    # 保留的神经元数量
    idxs = np.random.choice(len(y), n_remain, False) # 保留的神经元索引
    ym[idxs] = 1/(1-p)                # 保留的神经元乘以1/(1-p)
    return ym

def DLDropout(X, D, epochs):
    """
    加入Dropout技巧, 构造四层深度学习网络
    Param:
        X: 输入矩阵
        D: Ground Truth
        epochs: 训练轮数
    Return:
        W1, W2, W3, W4: 每层的权重
    """
    # 初始化权重
    W1 = 2*np.random.random((20,25))-1
    W2 = 2*np.random.random((20,20))-1
    W3 = 2*np.random.random((20,20))-1
    W4 = 2*np.random.random((5,20))-1
    
    alpha = 0.01 # 学习率
    p = 0.2      # Dropout ratio
    for i in range(epochs):
        for j in range(X.shape[0]):
            input = X[j].reshape(25,1)    # 依次选取输入，25*1
            
            # forward
            v1 = np.dot(W1, input)        # 第一层相乘结果，20*1
            y1 = sigmoid(v1)              # 第一层输出，20*1
            y1 = y1*Dropout(y1, p)        # Dropout

            v2 = np.dot(W2, y1)           # 第二层相乘结果，20*1
            y2 = sigmoid(v2)              # 第二层输出，20*1
            y2 = y2*Dropout(y2, p)        # Dropout

            v3 = np.dot(W3, y2)           # 第三层相乘结果，20*1
            y3 = sigmoid(v3)              # 第三层输出，20*1
            y3 = y3*Dropout(y3, p)        # Dropout

            v4 = np.dot(W4, y3)           # 第四层相乘结果，5*1
            y4 = softmax(v4)              # 第四层输出，5*1
            
            # backward
            e4 = D[j].reshape(5,1) - y4   # 第四层输出误差，5*1
            delta4 = e4                    # softmax的导数取1
            dW4 = alpha*delta4*y3.T       # 第四层更新值，5*20

            e3 = np.dot(W4.T, delta4)     # 第三层输出误差，20*1
            delta3 = y3*(1-y3)*e3         # 第三层delta，20*1
            dW3 = alpha*delta3*y2.T       # 第三层更新值，20*20

            e2 = np.dot(W3.T, delta3)     # 第二层输出误差，20*1
            delta2 = y2*(1-y2)*e2         # 第二层delta，20*1
            dW2 = alpha*delta2*y1.T       # 第二层更新值，20*20

            e1 = np.dot(W2.T, delta2)     # 第一层输出误差，20*1
            delta1 = y1*(1-y1)*e1         # 第一层delta，20*1
            dW1 = alpha*delta1*input.T    # 第一层更新值，20*25

            W1 = W1 + dW1                 # 第一层权重
            W2 = W2 + dW2                 # 第二层权重
            W3 = W3 + dW3                 # 第三层权重
            W4 = W4 + dW4                 # 第四层权重
    return W1, W2, W3, W4

def showDropout(X, W1, W2, W3, W4):
    """
    加入Dropout技巧训练后的结果
    Param:
        X: 输入矩阵
        W1, W2, W3, W4: 每层的权重
    Return:
    """
    outputs = np.zeros((5,5))
    for i in range(X.shape[0]):
        input = X[i].reshape(25,1)    # 依次选取输入，25*1
        
        # forward
        v1 = np.dot(W1, input)        # 第一层相乘结果，20*1
        y1 = sigmoid(v1)              # 第一层输出，20*1

        v2 = np.dot(W2, y1)           # 第二层相乘结果，20*1
        y2 = sigmoid(v2)              # 第二层输出，20*1

        v3 = np.dot(W3, y2)           # 第三层相乘结果，20*1
        y3 = sigmoid(v3)              # 第三层输出，20*1

        v4 = np.dot(W4, y3)           # 第四层相乘结果，5*1
        output = softmax(v4)          # 第四层输出，5*1

        outputs[i,:] = output.reshape(1,5) # 保存结果
    print('实验6-2的训练结果为: \n', outputs)

def main():
    # 初始化X和D
    X = np.array([[0,1,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,1,1,1,0],
                  [1,1,1,1,0,0,0,0,0,1,0,1,1,1,0,1,0,0,0,0,1,1,1,1,1],
                  [1,1,1,1,0,0,0,0,0,1,0,1,1,1,0,0,0,0,0,1,1,1,1,1,0],
                  [0,0,0,1,0,0,0,1,1,0,0,1,0,1,0,1,1,1,1,1,0,0,0,1,0],
                  [1,1,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,0,1,1,1,1,1,0]])
    D = np.array([[1,0,0,0,0],
                  [0,1,0,0,0],
                  [0,0,1,0,0],
                  [0,0,0,1,0],
                  [0,0,0,0,1]])
    
    epochs = 10000                          # 训练轮数

    # lab 6-1
    W1, W2, W3, W4 = DLReLU(X, D, epochs)   # 训练权重
    showReLU(X, W1, W2, W3, W4)             # 输出训练后的结果

    # lab 6-2
    W1, W2, W3, W4 = DLDropout(X, D, epochs)  # 训练权重
    showDropout(X, W1, W2, W3, W4)            # 输出训练后的结果

if __name__ == '__main__':
    main()
