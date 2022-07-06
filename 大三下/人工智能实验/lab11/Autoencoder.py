from tensorflow.keras.datasets import mnist
from tensorflow.keras.models import *
from tensorflow.keras.layers import *
from tensorflow.keras.optimizers import *
from tensorflow.keras.callbacks import ModelCheckpoint
import matplotlib.pyplot as plt
import numpy as np

if __name__ == '__main__':
    ## 数据处理
    (x_train, _), (x_test, _) = mnist.load_data()
    x_train = x_train.astype('float32') / 255.
    x_test = x_test.astype('float32') / 255.
    x_train = np.reshape(x_train, (len(x_train), 28, 28, 1))
    x_test = np.reshape(x_test, (len(x_test), 28, 28, 1))

    x_train = x_train[:10000]
    x_test = x_test[0:10000]

    ## 添加噪声
    noise_factor = 0.5
    x_train_noisy = x_train + noise_factor * np.random.normal(loc=0.0, scale=1.0, size=x_train.shape) 
    x_test_noisy = x_test + noise_factor * np.random.normal(loc=0.0, scale=1.0, size=x_test.shape) 
    x_train_noisy = np.clip(x_train_noisy, 0., 1.) 
    x_test_noisy = np.clip(x_test_noisy, 0., 1.)

    input_img = Input(shape=(28, 28, 1))

    # 编码器
    x = Conv2D(32, 3, padding='valid', activation='relu', kernel_initializer ='he_normal')(input_img)
    x = MaxPooling2D(pool_size=(2, 2))(x)
    x = Conv2D(32, 2, padding='valid', activation='relu', kernel_initializer='he_normal')(x)
    encoded = MaxPooling2D(pool_size=(2, 2))(x)

    # 解码器
    x = Conv2DTranspose(32, 6, strides=(2, 2), padding='valid', activation='relu', use_bias=False, kernel_initializer='he_normal')(encoded)
    x = Conv2D(32, 3, padding='valid', activation='relu', kernel_initializer='he_normal')(x)
    decoded = Conv2DTranspose(1, 2, strides=(2, 2), padding='valid', activation='relu', use_bias=False, kernel_initializer='he_normal')(x)

    learning_rate = 1e-4
    autoencoder = Model(input_img, decoded)
    autoencoder.compile(optimizer = Adam(lr = learning_rate), loss='mean_squared_error')  # Adam
    # autoencoder.compile(optimizer = Adagrad(lr = 0.01), loss='mean_squared_error')        # Adagrad
    # autoencoder.compile(optimizer = SGD(lr = 0.01), loss='mean_squared_error')            # SGD

    ## 训练 
    filepath="./records/Auto-{epoch:02d}-{val_loss:.2f}.hdf5"
    model_checkpoint = ModelCheckpoint(filepath, monitor='val_loss',verbose=1, save_best_only=True, period=5)

    history = autoencoder.fit(x_train_noisy, x_train,
                    epochs=50,
                    batch_size=10,
                    shuffle=True,
                    validation_data=(x_test_noisy, x_test),
                    callbacks=[model_checkpoint])

    ## 画出训练过程 
    plt.figure(0)
    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('Model loss')
    plt.ylabel('Loss')
    plt.xlabel('Epoch')
    plt.legend(['Train', 'Test'], loc='upper left')
    plt.show()

    ## 典型结果测试、可视化、计算误差
    Inx_N = 10
    errs = []
    results = []
    for inx in range(Inx_N):
        test_inp = x_test_noisy[inx, ]
        test_inp = np.reshape(test_inp, (1, )+test_inp.shape) 
        result = autoencoder.predict(test_inp, batch_size=1)
        err = np.linalg.norm(x_test[inx].reshape(28,28)-result.reshape(28,28))/np.linalg.norm(x_test[inx].reshape(28,28))
        results.append(result)
        errs.append(err)
    
    xlabel = np.linspace(0, Inx_N, Inx_N, endpoint=False)
    plt.figure(1)
    plt.plot(xlabel, errs)
    plt.title('Relative error')
    plt.ylabel('error')
    plt.xlabel('n')
    plt.show()
    print('The average relative error is %f.' % (np.sum(errs)/len(errs)))

    plt.figure(2)
    plt.subplot(1,3,1)
    plt.imshow(x_test[0].reshape(28,28))
    plt.title('Original number')
    plt.subplot(1,3,2)
    plt.imshow(x_test_noisy[0].reshape(28,28))
    plt.title('Noised number')
    plt.subplot(1,3,3)
    plt.imshow(results[0].reshape(28,28))
    plt.title('Denoised number')
    plt.show()
