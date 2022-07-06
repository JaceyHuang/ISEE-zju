from numpy import *
from os import listdir

def createDataSet():
    group = array([[1.0,1.1],[1.0,1.0],[0,0],[0,0.1]])
    labels = ['A','A','B','B']
    return group, labels

def classify0(inData,group,labels,k):
    """分类器
    Args:
      inData: 输入的测试样本
      group: 训练样本集
      labels: 训练样本集对应的标签
      k: 近邻数
    Returns:
      sortedClassCnt[0][0]: 测试样本的分类
    """
    groupLine = group.shape[0]              # 训练样本集大小
    inDataMat = tile(inData,(groupLine,1))  # 将输入样本转为groupSize*1的矩阵
    diffMat = inDataMat-group               # 输入样本与各个训练样本的差:[(x_1-x_2),(y_1-y_2)]
    sqDiffMat = diffMat**2                  # 平方:[(x_1-x_2)^2,(y_1-y_2)^2]
    sumSqVec = sqDiffMat.sum(axis=1)        # 按行相加:(x_1-x_2)^2+(y_1-y_2)^2
    distanceVec = sumSqVec**0.5             # 开方:sqrt((x_1-x_2)^2+(y_1-y_2)^2)
    sortedDist = distanceVec.argsort()      # 从小到大排序(下标)
    classCnt = {}                           # 字典数据类型
    for i in range(0,k):
        label = labels[sortedDist[i]]               # 距离从小到大排在第i位的训练样本的label
        classCnt[label] = classCnt.get(label,0)+1   # 使用get()读取键对应的值，若没有该键，则值初始化为0
    sortedClassCnt = sorted(classCnt.items(), key=lambda x: x[1], reverse=True) # 对字典按value排序
    # sortedClassCnt:[('B', 2), ('A', 1)]
    # print(sortedClassCnt[0][0]):B
    return sortedClassCnt[0][0]

def getDataSet(fileName):
    """从文件中读取训练样本矩阵和类标签向量
    Args: 
      fileName: 文件路径
    Returns:
      group: 训练样本矩阵
      labels: 类标签向量
    """
    with open(fileName,"r") as f:
        flist = f.readlines()              # 以list的形式返回
        flines = len(flist)                # 读取文件的行数
        group = zeros((flines,3))          # flines*3的矩阵
        labels = []                        # flines*1的向量
        # print(flist[0].strip())
        for i in range(0,flines):          
            line = flist[i].strip()                # 读取每一行的内容(去除头尾空白符)
            lineData = line.split("\t")            # 按tab分割每行内容
            group[i,:] = lineData[0:3]             # 训练样本矩阵的第i行
            labels.append(int(lineData[3]))        # 类标签向量的第i个
    return group,labels

def normalize(group):                       
    """归一化
    Args:
      group: 需要归一化的样本集
    Returns:
      normalGroup: 归一化后的样本集
    """
    maxData = group.max(axis=0)             # 每列的最大值
    minData = group.min(axis=0)             # 每列的最小值
    groupLine = group.shape[0]              # 矩阵的行数
    normalGroup = zeros((groupLine,3))      # groupLine*3的矩阵 
    Xmin = tile(minData,(groupLine,1))      # Xmin矩阵
    Xmax = tile(maxData,(groupLine,1))      # Xmax矩阵
    normalGroup = (group-Xmin)/(Xmax-Xmin)  # 线性归一化
    return normalGroup

def dateTest(normalGroup,labels):
    """测试配对效果
    Args: 
      normalGroup: 归一化后的样本集
      labels: 样本集对应的类标签向量
    Returns:
      1-errorCnt/testLen: 预测正确率
    """
    ratio = 0.1                             # 测试前10%的数据
    groupLen = normalGroup.shape[0]         # 输入的训练样本集行数
    testLen = int(groupLen*ratio)           # 测试样本集行数
    inData = zeros((testLen,3))             # 输入的测试样本集
    errorCnt = 0                            # 预测错误数
    for i in range(0,testLen):
        inData[i,:] = normalGroup[i,:]      # 测试样本矩阵的第i行
        testLabel = classify0(inData[i,:],normalGroup[testLen:groupLen,:],labels[testLen:groupLen],3)  # 前10%用作测试，后90%作为训练样本
        print("The result that kNN predicted for the %d th person is %d, and the right result is %d." % (i, testLabel, labels[i]))
        if (testLabel != labels[i]):
            errorCnt = errorCnt+1
    print("The number of errors is %d." % (errorCnt))
    return 1-errorCnt/testLen

def getVector(fileName):
    """将32*32的二进制图像矩阵转为1*1024的向量
    Args:
      fileName: 图像文件路径
    Returns:
      vec: 提取出的向量
    """
    with open(fileName,"r") as f:
        flist = f.readlines()              # 以list的形式返回
        flines = len(flist)                # 读取文件的行数
        vec = zeros((1,1024))              # 1*1024的向量
        for i in range(0,flines):
            line = flist[i].strip()        # 读取每一行的内容(去除头尾空白符)
            for j in range(0,32):
                vec[0,32*i+j] = line[j]    # 将数字存入向量中
    return vec

def getLabels(path):
    """从文件名中获取图像矩阵对应的类标签
    Args: 
      path: 文件夹路径
    Returns:
      labels: 类标签向量
    """
    labels = []                           # 保存标签
    fileList = listdir(path)              # 目录下所有的文件
    listLen = len(fileList)               # 文件数
    for i in range(0,listLen):
        fileName = fileList[i]                    # 文件名
        prefix = fileName.split(".")[0]           # 文件名前缀
        labels.append(int(prefix.split("_")[0]))  # 标签
    return labels