import numpy as np
from sklearn import datasets
import matplotlib.pyplot as plt
from pca import *

def compute_W(data,n_neighbour,t):
    """计算邻接矩阵
    Args: 
      data: 数据集
      n_neighbour: 邻接点个数
      t: 热核参数
    Returns:
      W: 邻接矩阵
    """
    sum = np.sum(np.square(data),1)   # 计算任意两个样本之间的距离平方
    sqrDist = np.add(np.add(-2*np.dot(data, data.T), sum).T,sum)
    oriW = np.exp(-sqrDist/t)         # 初步计算W，未区分近邻关系
    dimen = oriW.shape[0]             # W的维度
    W = np.zeros((dimen,dimen))       # 初始化W
    for i in range(dimen):        # 找到与每个样本最近的n_neighbour个样本
        index = np.argsort(sqrDist[i])[1:1+n_neighbour]
        W[i,index] = oriW[i,index]    # 保存W_{i,j}
        W[index,i] = oriW[index,i]    # 对称性
    return W

def LPP(data,n_dim,n_neighbour,t):
    """使用LPP降维
    Args: 
      data: 数据集
      n_dim: 希望降到的维度
      n_neighbour: 邻接点个数
      t: 热核参数
    Returns:
      lowDData: 降维后的矩阵
    """
    W = compute_W(data,n_neighbour,t)  # 建立邻接矩阵
    dimen = data.shape[0]
    D = np.zeros((dimen,dimen))
    for i in range(dimen):             # 计算D矩阵
        D[i,i] = np.sum(W[i])
    L = D - W                           # 计算L矩阵
    XDXT = np.dot(np.dot(data.T,D),data)        # 计算XDXT
    XLXT = np.dot(np.dot(data.T,L),data)        # 计算XLXT
    matrix = np.dot(np.linalg.pinv(XDXT),XLXT)  # (XDXT)^(-1)XLXT
    eigValues,eigVecs = np.linalg.eig(matrix)   # 特征值分解
    sortedIndex = np.argsort(eigValues)         # 对特征值从小到大排序
    sortedEigValues = eigValues[sortedIndex]    # 按下标排序
    start = 0
    while sortedEigValues[start] < 1e-6:
        start += 1
	# 不接近0的前n_dim个特征值的索引
    remEigenIndex = sortedIndex[start:start+n_dim]
    remEigVecs = eigVecs[:,remEigenIndex]           # 特征值对应的特征向量
    lowDData = np.dot(data,remEigVecs)              # 降维
    return lowDData

def main():
    data = datasets.load_digits().data  # 导入数据集
    label = datasets.load_digits().target
    sum = np.sum(np.square(data),1)     # 计算任意两个样本之间的距离平方
    sqrDist = np.add(np.add(-2*np.dot(data, data.T), sum).T,sum)
    t = 0.01*np.max(sqrDist)            # 设定热核参数
    lowDData = LPP(data,2,5,t)          # lpp降维
    pca_lowDData,reconsMat = pca(data,2)  # pca降维
    plt.subplot(1,2,1)                   # LPP降维后数据可视化
    l1 = plt.scatter(lowDData[:,0],lowDData[:,1],c=label,marker='.',
                      cmap='Blues',alpha=0.8,linewidths=3) 
    plt.title("Data After LPP")
    plt.subplot(1,2,2)                   # PCA降维后数据可视化
    l2 = plt.scatter(pca_lowDData[:,0].tolist(),
                      pca_lowDData[:,1].tolist(),c=label,marker='.', 
                      cmap='Blues',alpha=0.8,linewidths=3) 
    plt.title("Data After PCA")
    plt.show()

if __name__ == "__main__":
    main()
