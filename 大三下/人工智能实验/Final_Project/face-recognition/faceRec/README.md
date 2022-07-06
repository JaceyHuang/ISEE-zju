# Face Recognition

## 文件结构
1. 此项目的文件结构和说明如下：
    ```
    ├── FaceRec
      ├── configs
        ├── faceRec.yaml
      ├── features
        ├── feature_dict.npy
        ├── feature_dict.pth
      ├── lib
        ├── config
        ├── dataloader
        ├── mtcnn
        ├── network
        ├── train
      ├── models
        ├── faceRec
        ├── mtcnn
      ├── test.py
      ├── train.py
      ├── recognition.py
      ├── app.py
    ```

    | file | Intro |
    | ------ | ------ |
    | `configs` | config 文件，需要用到的一些全局变量可以在此处修改 |
    | `features` | 保存的人脸特征字典，形式为 `{identity: feature}` |
    | `lib` | 训练需要用到的一些文件，如 `dataloader` 以及网络的结构等 |
    | `models` | 网络模型的权重 |
    | `test.py` | 在LFW上测试模型的正确率 |
    | `train.py` | 训练代码 |
    | `recognition.py` | 人脸检测与识别所需用到的函数 |
    | `app.py` | 后端代码 |

## 运行
1. 命令行运行如下代码，测试模型正确率:
   ```
   python test.py
   ```
   如果不使用默认的`config`文件 `faceRec.yaml`，如 `yours.yaml`(可在其中修改全局参数，可用参数可见`lib/config/config.py`)，则运行下列代码:
   ```
   python cam_test.py --cfg_file yours.yaml
   ```

