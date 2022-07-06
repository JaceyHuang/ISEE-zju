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
    return np.array(MSEs)

def create_network(net_type, inputs, gts, epochs, beta=0):
    """
    构造神经网络，计算权重
    Params:
        net_type: 网络类型，前向或后向
        inputs: 数据输入
        gts: 正确值
        epochs: 训练轮数
        beta: momentum参数
    Return: 
        weight: 训练好的权重
        MSE: 训练结果与ground truth的均方误差
    """
    outputs_fp = []                   # 保存单次训练的结果
    outputs_bp = []
    if net_type == 'forward':         # 前向传输，SGD方法，单层网络
        weight = np.array([[0.1,0.5,0.8]])  # 初始化权重
        alpha = 0.9                   # 学习率
        for i in range(epochs):
            for j in range(inputs.shape[0]):     # 每轮需要调整权重的次数
                input = inputs[j].reshape(1,3)             # 依次选取
                output = sigmoid(np.dot(weight, input.T)) # 计算输出，1*1
                e = gts[j] - output                      # 输出误差，1*1
                delta = alpha*output*(1-output)*e*input # 误差更新值，1*3
                weight = weight + delta                  # 更新权重
            # 前向传输的结果
            output_fp = sigmoid(np.dot(weight, inputs.T))  
            outputs_fp.append(output_fp.reshape(4,))     # 保存结果
        outputs_fp = np.array(outputs_fp)
        MSE_fp = mse(outputs_fp.T, gts)                  # 均方误差
        # 输出训练后的结果和权重
        print('Output of forward:\n', output_fp.reshape(4,)) 
        print('Weight of forward:\n', weight, '\n')
        return weight, MSE_fp
    elif net_type == 'backward':                  # 后向传输
        weight_1 = np.array([[0.5,0.5,1],
                              [0.5,0.5,1],
                              [0.5,0.5,1],
                              [0.5,0.5,1]])        # 第一层权重
        weight_2 = np.array([[0.5,0.5,0.5,1]])   # 第二层权重
        alpha = 0.45                               # 学习率
        m_2_ = 0                                   # momentum参数
        m_1_ = 0
        for i in range(epochs):
            for j in range(inputs.shape[0]):
                input = inputs[j].reshape(1,3)    # 依次选取，1*3
                # 第一层输出，4*1
                output_1=sigmoid(np.dot(weight_1,input.T)).reshape(4,1)
                # 第二层输出，1*1
                output_2 = sigmoid(np.dot(weight_2, output_1)) 
                e_2 = gts[j] - output_2             # 第二层输出误差，1*1
                delta_2 = output_2*(1-output_2)*e_2  # 第二层delta，1*1
                # 后向传输，第一层误差，4*1
                e_1 = np.dot(weight_2.T, delta_2) 
                delta_1 = np.zeros((4,1))           # 第一层delta，4*1
                for k in range(4):
                    delta_1[k] = output_1[k]*(1-output_1[k])*e_1[k]      
                delta_w_2 = alpha*delta_2*output_1.T  # 第二层更新值，1*4
                # 第一层更新值，4*3
                delta_w_1 = alpha*np.dot(delta_1, input)  
                # 根据momentum调整方向，当不使用momentum时，beta默认为0
                m_2 = delta_w_2 + beta*m_2_   # momentum，1*4
                m_1 = delta_w_1 + beta*m_1_   # momentum，4*3
                weight_2 = weight_2 + m_2     # 第二层权重，1*4
                weight_1 = weight_1 + m_1     # 第一层权重，4*3
                m_2_ = m_2                    # 保存第二层的momentum更新值
                m_1_ = m_1                    # 保存第一层的momentum更新值
            # 后向传输第一层的结果，4*1
            output_bp_1 = sigmoid(np.dot(weight_1, inputs.T))  
            # 后向传输的结果，1*1
            output_bp = sigmoid(np.dot(weight_2, output_bp_1)) 
            outputs_bp.append(output_bp.reshape(4,))
        outputs_bp = np.array(outputs_bp)
        MSE_bp = mse(outputs_bp.T, gts)
        if beta == 0:
            print('Output of backward(without momentum):\n',
                   output_bp.reshape(4,))
            print('Weight of backward(without momentum):\n', weight_1, 
                  '\n', weight_2, '\n')
        else:
            print('Output of backward(momentum):\n', 
                  output_bp.reshape(4,))
            print('Weight of backward(momentum):\n', weight_1, '\n',
                   weight_2, '\n')
        return weight_1, weight_2, MSE_bp

def main():
    dataset = np.array([[0,0,1,0],[0,1,1,1],[1,0,1,1],[1,1,1,0]])
    inputs = dataset[:,0:3]       # 输入
    gts = dataset[:,3:4]          # ground truth
    epochs = 8000                 # 训练轮数
    # beta = 0.1                    # momentum参数
    # beta = 0.5
    beta = 0.9

    # 前向传输的权重和均方误差
    weight_fp, MSE_fp = create_network('forward', inputs, gts, epochs)

    # 后向传输的权重和均方误差(不使用momentum)
    weight_bp_1, weight_bp_2, MSE_bp = create_network('backward', 
                                         inputs, gts, epochs)

    # 后向传输的权重和均方误差(使用momentum)
    weight_bp_m_1, weight_bp_m_2, MSE_bp_m = create_network('backward', 
                                               inputs, gts, epochs, beta)

    epoch = np.linspace(0, epochs, epochs) 
    # 绘制平滑曲线
    model_fp = make_interp_spline(epoch, MSE_fp.reshape(epochs,)) 
    model_bp = make_interp_spline(epoch, MSE_bp.reshape(epochs,)) 
    model_bp_m = make_interp_spline(epoch, MSE_bp_m.reshape(epochs,)) 
    mse_fp = model_fp(epoch)
    mse_bp = model_bp(epoch)
    mse_bp_m = model_bp_m(epoch)
    
    plt.figure(1)                        # 实验5-2，可视化
    l1, = plt.plot(epoch, mse_fp)
    l2, = plt.plot(epoch, mse_bp)
    plt.legend(handles=[l1,l2],labels=["Forward","Backward"],loc='best')
    plt.title('MSE')
    plt.draw()

    plt.figure(2)                        # 实验5-3，可视化
    l2, = plt.plot(epoch, mse_bp)
    l3, = plt.plot(epoch, mse_bp_m)
    plt.legend(handles=[l2,l3],labels=["Without momentum", 
               "Momentum, beta=%.1f" % beta],loc='best')
    plt.title('MSE')
    plt.show()

if __name__ == '__main__':
    main()
