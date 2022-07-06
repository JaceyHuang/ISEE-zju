## 导入模型
from tensorflow.keras.datasets import mnist
from tensorflow.keras.models import *
from tensorflow.keras.layers import *
from tensorflow.keras.optimizers import *
from tensorflow.keras.callbacks import ModelCheckpoint
import matplotlib.pyplot as plt
import numpy as np

## 数据处理
(x_train, _), (x_test, _) = mnist.load_data()
x_train = x_train.astype('float32') / 255.
x_test = x_test.astype('float32') / 255.
x_train = np.reshape(x_train, (len(x_train), 28, 28, 1))
x_test = np.reshape(x_test, (len(x_test), 28, 28, 1))

## 添加噪声
noise_factor = 0.5
x_train_noisy = x_train + noise_factor * np.random.normal(loc=0.0, scale=1.0, size=x_train.shape) 
x_test_noisy = x_test + noise_factor * np.random.normal(loc=0.0, scale=1.0, size=x_test.shape) 
x_train_noisy = np.clip(x_train_noisy, 0., 1.) # clip这个函数将将数组中的元素限制在a_min, a_max之间，大于a_max的就使得它等于 a_max，小于a_min,的就使得它等于a_min
x_test_noisy = np.clip(x_test_noisy, 0., 1.)
print(x_test.shape)
print(x_test_noisy.shape)

## 搭建模型
input_img = Input(shape=(28, 28, 1))
x = Conv2D(32, 3, padding='same', activation='relu', kernel_initializer='he_normal')(input_img)
x = MaxPooling2D(pool_size=(2, 2))(x)
x =Conv2DTranspose(32, 2, strides=(2, 2), padding='same', activation='relu', use_bias=False, kernel_initializer='he_normal')(x) 


learning_rate = 1e-4
autoencoder = Model(input_img, x)
autoencoder.compile(optimizer = Adam(lr = learning_rate), loss='mean_squared_error')
# SGD、Adam、RMSprop、Nadam等

## 训练 
filepath="Auto-{epoch:02d}-{val_loss:.2f}.hdf5"
model_checkpoint = ModelCheckpoint(filepath, monitor='val_loss',verbose=1, save_best_only=True, period=2)

history =autoencoder.fit(x_train_noisy, x_train,
                epochs=30,
                batch_size=10,
                shuffle=True,
                validation_data=(x_test_noisy, x_test),
                callbacks=[model_checkpoint],)

## 画出训练过程 
plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title('Model loss')
plt.ylabel('Loss')
plt.xlabel('Epoch')
plt.legend(['Train', 'Test'], loc='upper left')
plt.show()

## 典型结果测试、可视化、计算误差
Inx_N=3
for inx in range(Inx_N):
    test_inp=x_test_noisy[inx,]
    test_inp=np.reshape(test_inp, (1,)+test_inp.shape) 
    results = autoencoder.predict(test_inp,batch_size=1)




