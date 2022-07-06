from numpy import *
from sklearn import svm, preprocessing
from sklearn.model_selection import train_test_split
from time import *

def getDataSet(fileName):
    """从文件中读取样本矩阵和类标签向量
    Args: 
      fileName: 文件路径
    Returns:
      group: 样本矩阵
      labels: 类标签向量
    """
    with open(fileName,"r") as f:
        flist = f.readlines()                      # 以list的形式返回
        flines = len(flist)                        # 读取文件的行数
        group = zeros((flines,6))                  # flines*6的矩阵
        labels = []                                # flines*1的向量
        # print(flist[0].strip())
        for i in range(0,flines):          
            line = flist[i].strip()                # 读取每一行的内容(去除头尾空白符)
            lineData = line.split(" ")             # 按空格分割每行内容
            group[i,:] = lineData[0:6]             # 样本矩阵的第i行
            labels.append(int(lineData[6]))        # 类标签向量的第i个
    lines = where(isnan(group))                    # 找到NaN所在的行
    group = delete(group,lines,axis=0)             # 删除NaN所在行
    labels = delete(labels,lines,axis=0)           # 保持labels和group长度一致
    # print(isnan(group).any())
    return group,labels


def getTestSet(fileName):
    """从测试文件中读取样本矩阵
    Args: 
      fileName: 文件路径
    Returns:
      group: 样本矩阵
    """
    with open(fileName,"r") as f:
        flist = f.readlines()                      # 以list的形式返回
        flines = len(flist)                        # 读取文件的行数
        group = zeros((flines,6))                  # flines*6的矩阵
        # print(flist[0].strip())
        for i in range(0,flines):          
            line = flist[i].strip()                # 读取每一行的内容(去除头尾空白符)
            lineData = line.split(" ")             # 按空格分割每行内容
            group[i,:] = lineData[0:6]             # 样本矩阵的第i行
    lines = where(isnan(group))                    # 找到NaN所在的行
    group = delete(group,lines,axis=0)             # 删除NaN所在行
    # print(isnan(group).any())
    return group


def saveTxt(filename,test_labels):
    """将预测标签写入txt文件
      Args: 
        fileName: 文件路径
        test_labels: 预测结果
      Returns:
    """
    with open(filename,"w") as f:
      for test_label in test_labels:
        f.write(str(test_label))                                     # 每行一个结果
        f.write('\n')


def main():
    length = 6000                                                    # 设置样本集长度
    init_group, init_labels = getDataSet("training.data")            # 从文件中获取数据
    index = random.choice(init_group.shape[0],length,replace=False)  # 从矩阵中随机取出一部分作为样本集
    group = init_group[index]                                        # 取出的样本矩阵
    labels = init_labels[index]                                      # 取出的类标签向量
    scaler = preprocessing.MinMaxScaler().fit(group)
    normalGroup = scaler.transform(group)                            # min-max归一化
    train_group, valid_group, train_labels, valid_labels = train_test_split(normalGroup,labels,test_size=0.1,random_state=0)  # 分出训练集和验证集
    print("Start training!")
    t = time()
    classifier = svm.SVC(C=1,kernel='rbf',gamma=10,decision_function_shape='ovr')
    classifier.fit(train_group,train_labels)
    t = time() - t
    print("Time cost: %fs" % t)

    test_group = getTestSet("testingNoAnswer.data")                                   # 获取测试集
    test_scaler = preprocessing.MinMaxScaler().fit(test_group)
    test_norm = test_scaler.transform(test_group)                                     # min-max归一化
    test_labels = classifier.predict(test_norm)                                       # 预测标签
    saveTxt("submit.txt",test_labels)

    print("Train set accuracy: ",classifier.score(train_group,train_labels))          # 检测准确度
    print("Validation set accuracy: ",classifier.score(valid_group,valid_labels))
    print("Test results saved successfully!")


if __name__ == '__main__':
    main()