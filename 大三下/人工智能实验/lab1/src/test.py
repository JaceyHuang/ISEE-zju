from numpy import *
from os import *
import kNN

# 1-1
group,labels = kNN.createDataSet()
inData1 = [0,0]
inData2 = [0.8,0.7]
class1 = kNN.classify0(inData1,group,labels,3)
class2 = kNN.classify0(inData2,group,labels,3)
print("The class of [0,0] is "+class1+", and the class of [0.8,0.7] is "+class2+".\n")

# 1-2
group,labels = kNN.getDataSet("../datingTestSet2.txt")
normalGroup = kNN.normalize(group)
corRate = kNN.dateTest(normalGroup,labels)
print("The correct rate is %f.\n" % (corRate))

# 1-3
labels = kNN.getLabels("../trainingDigits")
fileList = listdir("../trainingDigits")              # 目录下所有的文件
listLen = len(fileList)                              # 文件数
group = zeros((listLen,1024))                        # 初始化数字矩阵
for i in range(0,listLen):
    group[i,:] = kNN.getVector("../trainingDigits/" + fileList[i])       # 获取该文件的数字向量
# print(group)
# print(labels)