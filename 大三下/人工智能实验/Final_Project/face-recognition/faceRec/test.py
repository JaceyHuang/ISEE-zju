import os
from PIL import Image
import torch
import torch.nn as nn
import torchvision.transforms as T
import numpy as np
import time

from lib.config.config import cfg
from lib.network.load_network import load_network
from lib.network.fmobilenet import FaceMobileNet
from lib.network.resnet import ResIRSE

def _preprocess(images: list, transform) -> torch.Tensor:
    res = []
    for img in images:
        im = Image.open(img)
        im = transform(im)
        res.append(im)
    data = torch.cat(res, dim=0)  # shape: (batch, 128, 128)
    data = data[:, None, :, :]    # shape: (batch, 1, 128, 128)
    return data


def featurize(images: list, transform, net, device) -> dict:
    """featurize each image and save into a dictionary
    Args:
        images: image paths
        transform: test transform
        net: pretrained model
        device: cpu or cuda
    Returns:
        Dict (key: imagePath, value: feature)
    """
    data = _preprocess(images, transform)

    data = data.to(device)
    net = net.to(device)
    start = time.time()
    with torch.no_grad():
        features = net(data)
    time_cost = time.time() - start
    res = {img: feature for (img, feature) in zip(images, features)}
    return res, time_cost

def cosin_metric(x1, x2):
    return np.dot(x1, x2) / (np.linalg.norm(x1) * np.linalg.norm(x2))


def threshold_search(y_score, y_true):
    y_score = np.asarray(y_score)
    y_true = np.asarray(y_true)
    best_acc = 0
    best_th = 0
    for i in range(len(y_score)):
        th = y_score[i]
        y_test = (y_score >= th)
        acc = np.mean((y_test == y_true).astype(int))
        if acc > best_acc:
            best_acc = acc
            best_th = th
    return best_acc, best_th

def compute_accuracy(feature_dict, pair_list, test_root):
    with open(pair_list, 'r') as f:
        pairs = f.readlines()

    similarities = []
    labels = []
    for pair in pairs:
        img1, img2, label = pair.split()
        img1 = os.path.join(test_root, img1)
        img2 = os.path.join(test_root, img2)
        feature1 = feature_dict[img1].cpu().numpy()
        feature2 = feature_dict[img2].cpu().numpy()
        label = int(label)

        similarity = cosin_metric(feature1, feature2)
        similarities.append(similarity)
        labels.append(label)

    accuracy, threshold = threshold_search(similarities, labels)
    return accuracy, threshold

# Data Setup
def test():
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    transfrom = T.Compose([
        T.Grayscale(),
        T.Resize(cfg.input_shape[1:]),
        T.ToTensor(),
        T.Normalize(mean=[0.5], std=[0.5]),
    ])
    feature_dir = '../data/feature_dict.pth'

    if cfg.backbone == 'resnet':
        network = ResIRSE(cfg.embedding_size, cfg.drop_ratio).to(cfg.device)
    else:
        network = FaceMobileNet(cfg.embedding_size).to(cfg.device)

    network = nn.DataParallel(network)
    load_network(cfg, network)
    network.eval()
    
    batch_size = cfg.test_batch_size
    with open(cfg.test_list, 'r') as fd:
        pairs = fd.readlines()

    images = []
    labels = []
    count = 0
    pairList = [[] for i in range(len(pairs))]
    for pair in pairs:
        words = pair.split()
        if len(words)==3:
            image1 = cfg.test_root+'/'+words[0]+'/'+words[0]+'_'+ str(words[1]).zfill(4)+'.jpg'
            image2 = cfg.test_root+'/'+words[0]+'/'+words[0]+'_'+ str(words[2]).zfill(4)+'.jpg'
            if os.path.exists(image1) and os.path.exists(image2):
                images.append(image1)
                images.append(image2)
                labels.append(1)
                pairList[count] = [image1,image2,1]
                count+=1
        elif len(words)==4:
            image1 = cfg.test_root+'/'+words[0]+'/'+words[0]+'_'+ str(words[1]).zfill(4)+'.jpg'
            image2 = cfg.test_root+'/'+words[2]+'/'+words[2]+'_'+ str(words[3]).zfill(4)+'.jpg'
            if os.path.exists(image1) and os.path.exists(image2):
                images.append(image1)
                images.append(image2)
                pairList[count] = [image1,image2,0]
                count += 1
    del(pairList[-1])
    size = len(images)
    groups = []
    for i in range(0, size, batch_size):
        end = min(batch_size + i, size)
        groups.append(images[i: end])

    feature_dict = dict()
    total_time = 0
    for group in groups:
        # print(group)
        d, time_cost = featurize(group, transfrom, network, device)
        total_time = total_time + time_cost
        feature_dict.update(d)

    aver_time = total_time / size
    print('The time every picture cost on average is: ' + str(aver_time) + 's')

    torch.save(feature_dict, feature_dir)

    feature_dict = torch.load(feature_dir, map_location=device)

    similarities = []
    labels = []
    for s in pairList:
        img1 = s[0]
        img2 = s[1]
        label = s[2]
        # print(img1,img2,label)
        feature1 = feature_dict[img1].cpu().numpy()
        feature2 = feature_dict[img2].cpu().numpy()

        similarity = cosin_metric(feature1, feature2)
        similarities.append(similarity)
        labels.append(label)

    accuracy, threshold = threshold_search(similarities, labels)
    print('The accuracy on the test set is: ' + str(accuracy))

    '''
    similarity = np.asarray(similarity)
    label = np.asarray(label)
    predictedLabel = (similarity >= threshold)
    accuracy = np.mean((predictedLabel == label).astype(int))
    print('The accuracy on the test set is: '+str(accuracy))
    '''


if __name__ == '__main__':
    test()

