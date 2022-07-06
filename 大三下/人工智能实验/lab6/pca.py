from numpy import *
import matplotlib.pyplot as plt
from scipy.interpolate import make_interp_spline

def getDataSet(fileName, type):
    """从文件中读取数据集
    Args: 
      fileName: 文件路径
      type: 文件类型, 0: txt, 1: data
    Returns:
      dataMat: 数据矩阵
    """
    with open(fileName,"r") as f:
        flist = f.readlines()            # 以list的形式返回
        flines = len(flist)              # 读取文件的行数
        if type is 0:
            dataMat = zeros((flines,2))  # flines*2的矩阵
            # print(flist[0].strip())
            for i in range(0,flines):          
                line = flist[i].strip()  # 读取每一行的内容(去除头尾空白符)
                lineData = line.split("\t")  # 按TAB分割每行内容
                dataMat[i,:] = lineData[0:2] # 样本矩阵的第i行
        else:
            dataMat = zeros((flines,590))    # flines*590的矩阵
            # print(flist[0].strip())
            for i in range(0,flines):          
                line = flist[i].strip()  # 读取每一行的内容(去除头尾空白符)
                lineData = line.split(" ")     # 按空格分割每行内容
                dataMat[i,:] = lineData[0:590] # 样本矩阵的第i行
    return dataMat

def replaceNaNWithMean(dataMat):
    """将NaN替换为均值
    Args: 
      dataMat: 原始数据
      reconsMat: 重构后的数据
    Returns:
    """
    noNaNDataMat = dataMat
    numFeat = noNaNDataMat.shape[1]         # 特征数
    for i in range(numFeat):
    # 求该行的均值
        meanVal = mean(dataMat[nonzero(~isnan(dataMat[:,i]))[0],i]) 
        # 将NaN替换为均值
        noNaNDataMat[nonzero(isnan(noNaNDataMat[:,i]))[0],i] = meanVal   
    return noNaNDataMat

def show(dataMat, lowDDataMat, reconsMat, topNfeat):
    """可视化
    Args: 
      dataMat: 原始数据
      lowDDataMat: 降维后的数据
      reconsMat: 重构后的数据
      topNfeat: 用于区分图像
    Returns:
    """
    if topNfeat is 1:
        plt.figure(1)
    else:
        plt.figure(2)
    plt.subplot(1,2,1)
    if topNfeat is 1:
        plt.title("Data Comparison (topNfeat=1)")
    else:
        plt.title("Data Comparison (topNfeat=2)")
    l1 = plt.scatter(dataMat[:,0].tolist(),dataMat[:,1].tolist(),
                    marker='.',cmap='Blues',alpha=0.8,
                    linewidths=3)      # 原始数据
    l2 = plt.scatter(reconsMat[:,0].tolist(),reconsMat[:,1].tolist(),
                    marker='.',cmap='Blues',alpha=0.8,
                    linewidths=3)      # 重构后的数据
    plt.legend(handles=[l1,l2],labels=["Data Original",
                "Data Reconstructed"],loc='best')
    plt.xlabel("x")
    plt.ylabel("y")
    plt.subplot(1,2,2)
    if topNfeat is 1:
        y = zeros((lowDDataMat.shape[0],1))
        plt.scatter(lowDDataMat[:,0].tolist(),y,marker='.',cmap='Blues',
                    alpha=0.8,linewidths=3)     # 降维后的数据
    else:
        plt.scatter(lowDDataMat[:,0].tolist(),lowDDataMat[:,1].tolist(),
                    marker='.',cmap='Blues',alpha=0.8,
                    linewidths=3)                # 降维后的数据
    plt.title("Data Dimention Reduced")
    plt.draw()

def pca(dataMat, topNfeat=99999):
    """主成分分析
    Args: 
      dataMat: 需要处理的数据矩阵
      topNfeat: 需要保留的特征向量个数
    Returns:
      lowDDataMat: 降维后的数据矩阵
      reconsMat: 重构后的数据矩阵
    """
    dataMean = mean(dataMat, axis=0)              # 求各个特征的均值
    new_dataMat = dataMat - dataMean              # 零均值化
    # 协方差矩阵，new_dataMat每一行代替一个样本
    dataCov = cov(new_dataMat, rowvar=0) 
    # 特征值与特征矩阵，eigenVecs每一列代表一个特征向量
    eigenVals, eigenVecs = linalg.eig(mat(dataCov)) 
    # 对特征值从小到大排序        
    sortedEigenVals = argsort(eigenVals)                     
    # 保留前topNfeat个特征值
    remEigenVals = sortedEigenVals[:-(topNfeat+1):-1]  
    # 前topNfeat个特征值对应的特征向量  
    remEigenVecs = eigenVecs[:,remEigenVals]                
    lowDDataMat = new_dataMat * remEigenVecs                # 降维后的数据
    reconsMat = (lowDDataMat * remEigenVecs.T) + dataMean   # 重构数据
    return lowDDataMat, reconsMat

def main():
    # lab 4-1
    dataMat = getDataSet("testSet.txt",0)        # 获取数据矩阵
    lowDDataMat, reconsMat = pca(dataMat,1)      # 主成分分析, topNfeat=1
    show(dataMat, lowDDataMat, reconsMat, 1)     # 可视化
    lowDDataMat, reconsMat = pca(dataMat,2)      # 主成分分析, topNfeat=2
    show(dataMat, lowDDataMat, reconsMat, 2)     # 可视化

    # lab 4-2
    dataMat = getDataSet("secom.data",1)         # 获取数据矩阵
    noNaNDataMat = replaceNaNWithMean(dataMat)
    topNfeats = []                                # 可视化
    Re_errs = []
    for i in range(590):      
        lowDDataMat, reconsMat = pca(noNaNDataMat,i)   # 主成分分析
        Re_err = linalg.norm(noNaNDataMat-reconsMat)/linalg.norm(noNaNDataMat)              # 相对误差
        topNfeats.append(i)
        Re_errs.append(Re_err)
        print("topNfeat: %d, Re_err: %f" % (i,Re_err))
        if Re_err < 0.09:
            break
    print("The topNfeat is %d when the relative error rate is %f, which is less than 0.09." % (i,Re_err))
    model = make_interp_spline(topNfeats, Re_errs)    # 绘制平滑曲线
    xs = linspace(0,i,500)
    ys = model(xs)
    plt.figure(3)                                        # 可视化
    plt.plot(xs, ys)   
    plt.xlabel("topNfeat")
    plt.ylabel("Relative Error Rate")
    plt.show()

if __name__ == '__main__':
    main()