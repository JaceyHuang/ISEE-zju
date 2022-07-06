from numpy import *
import matplotlib.pyplot as plt

def compute_Sw(A,B):
    """计算类内散度矩阵
    Args: 
      A: A类原始数据
      B: B类原始数据
    Returns:
      Sw: 类内散度矩阵
    """
    meanA = mean(A,axis=0)             # A类均值
    meanB = mean(B,axis=0)             # B类均值
    SwA = dot((A-meanA).T,A-meanA)     # A类散度矩阵
    SwB = dot((B-meanB).T,B-meanB)     # B类散度矩阵
    Sw = SwA + SwB                     # 类内散度矩阵
    return Sw

def compute_Sb(A,B):
    """计算类间散度矩阵
    Args: 
      A: A类原始数据
      B: B类原始数据
    Returns:
      Sw: 类间散度矩阵
    """
    meanA = mean(A,axis=0)                              # A类均值
    meanB = mean(B,axis=0)                              # B类均值
    colVec = (meanA-meanB).reshape(len(meanA-meanB),-1) # 列向量
    rowVec = (meanA-meanB).reshape(-1,len(meanA-meanB)) # 行向量
    Sb = dot(colVec,rowVec)                             # 类间散度矩阵
    return Sb

def lda(A,B):
    """计算投影矩阵
    Args: 
      A: A类原始数据
      B: B类原始数据
    Returns:
      W: 投影矩阵
    """
    Sw = compute_Sw(A,B)                    # 计算类内散度矩阵
    Sb = compute_Sb(A,B)                    # 计算类间散度矩阵
    mat = dot(linalg.inv(Sw),Sb)            # (Sw^-1)Sb
    eigenVals, eigenVecs = linalg.eig(mat)  # (Sw^-1)Sb的特征值和特征矩阵
    maxEigenVal = argmin(eigenVals)         # 取第一个特征值
    W = eigenVecs[maxEigenVal]              # 第一个特征值对应的特征向量 
    return W

def main():
    A = 10+3*random.random((30,2))     # A的取值范围是10-13
    B = 15+3*random.random((30,2))     # B的取值范围是15-18
    W = lda(A,B)                        # 投影矩阵
    data = append(A,B,axis=0)          # 整体样本
    lowDData = dot(data,W)             # 降维后的数据
    x = linspace(10,18.5,1500)
    y = W[1]/W[0]*x
    print("The projected line is y=%fx" %(W[1]/W[0]))
    l1, = plt.plot(x,y,linewidth=3,color="green")         # 投影直线
    l2 = plt.scatter(A[:,0].tolist(),A[:,1].tolist(),marker='.',
                   cmap='Blues',alpha=0.8,linewidths=3)   # A类原始数据
    l3 = plt.scatter(B[:,0].tolist(),B[:,1].tolist(),marker='.',
                   cmap='Blues',alpha=0.8,linewidths=3)   # B类原始数据
    plt.legend(handles=[l1,l2,l3],labels=["Dimension Reduction Line",
               "Original A","Original B"],loc='best')
    plt.xlabel("x")
    plt.ylabel("y")
    plt.show()

if __name__ == "__main__":
    main()