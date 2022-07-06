import cv2
from PIL import Image
import torch
import torch.nn as nn
import torchvision.transforms as T
import numpy as np
import os
import operator

from lib.mtcnn.detector import FaceDetector
from lib.config.config import cfg
from lib.network.load_network import load_network
from lib.network.fmobilenet import FaceMobileNet
from lib.network.resnet import ResIRSE


def wrap_affine(frame, first_eye, second_eye, scale=1.):
    eye_center = ((first_eye[0] + first_eye[1])/2,
                  (second_eye[0] + second_eye[1])/2)
    dy = second_eye[1] - first_eye[1]
    dx = second_eye[0] - first_eye[0]
    rows, cols = frame.shape[:2]
    # 计算旋转角度
    angle = cv2.fastAtan2(dy, dx)
    rot = cv2.getRotationMatrix2D(eye_center, angle, scale=scale)

    # 自适应图片边框大小
    cos = np.abs(rot[0, 0])
    sin = np.abs(rot[0, 1])
    new_w = rows * sin + cols * cos
    new_h = rows * cos + cols * sin
    rot[0, 2] += (new_w - cols) * 0.5
    rot[1, 2] += (new_h - rows) * 0.5
    w = int(np.round(new_w))
    h = int(np.round(new_h))

    rot_img = cv2.warpAffine(frame, rot, dsize=(w, h))
    # rot_img = cv2.flip(rot_img, 0)
    return rot_img


def featurize(frame, transform, network, device, is_saving, identity=None):
    frame = transform(frame)[:, None, :, :]
    frame = frame.to(device)
    network = network.to(device)
    with torch.no_grad():
        feature = network(frame)
    if is_saving:
        ret = {identity: feature}
    else:
        ret = feature
    return ret


def cosin_metric(x1, x2):
    x1 = np.squeeze(np.asarray(x1))
    x2 = np.squeeze(np.asarray(x2))
    return np.dot(x1, x2) / (np.linalg.norm(x1) * np.linalg.norm(x2))


def recognize(is_saving, is_1N, is_11, frame, identity, search_identity):
    device = 'cuda' if torch.cuda.is_available() else 'cpu'

    detector = FaceDetector()
    transfrom = T.Compose([
        T.Grayscale(),
        T.Resize(cfg.input_shape[1:]),
        T.ToTensor(),
        T.Normalize(mean=[0.5], std=[0.5]),
    ])

    feature_dir = './features/feature_dict.pth'

    if os.path.exists(feature_dir):
        feature_dict = torch.load(feature_dir, map_location=device)
    else:
        feature_dict = {}

    if cfg.backbone == 'resnet':
        network = ResIRSE(cfg.embedding_size, cfg.drop_ratio).to(cfg.device)
    else:
        network = FaceMobileNet(cfg.embedding_size).to(cfg.device)

    network = nn.DataParallel(network)
    load_network(cfg, network)
    network.eval()

    similarities = {}

    # convert image
    pil_im = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
    bounding_box, facial_landmarks = detector.detect(pil_im)

    if len(bounding_box) != 1:
        if len(bounding_box) == 0:
            return('No face found!')
        else:
            return('Too many faces!')

    drawed_pil_im = detector.draw_bboxes(pil_im)
    drawed_frame = cv2.cvtColor(
        np.asarray(drawed_pil_im), cv2.COLOR_RGB2BGR)
    cv2.imshow("Face Detection", drawed_frame)

    # rotate image
    first_eye = np.array([facial_landmarks[0, 0], facial_landmarks[0, 5]])
    second_eye = np.array([facial_landmarks[0, 1], facial_landmarks[0, 6]])
    rot_frame = wrap_affine(frame, first_eye, second_eye)

    # detect again
    rot_pil_im = Image.fromarray(cv2.cvtColor(
        rot_frame, cv2.COLOR_BGR2RGB))  # 再次检测
    bounding_box, facial_landmarks = detector.detect(rot_pil_im)

    if len(bounding_box) != 1:
        if len(bounding_box) == 0:
            return('No face found!')
        else:
            return('Too many faces!')

    fin_frame = rot_frame[int(bounding_box[0, 1]): int(bounding_box[0, 3]),
                          int(bounding_box[0, 0]): int(bounding_box[0, 2])]

    # scale and recognition
    fin_frame = cv2.resize(fin_frame, (96, 112),
                           interpolation=cv2.INTER_CUBIC)
    fin_pil = Image.fromarray(cv2.cvtColor(fin_frame, cv2.COLOR_BGR2RGB))

    if is_saving:
        ret = featurize(fin_pil, transfrom, network,
                        device, is_saving, identity)
        feature_dict.update(ret)
        torch.save(feature_dict, feature_dir)
        return 'Saved successfully!'
    else:
        if is_1N:
            cur_feature = featurize(
                fin_pil, transfrom, network, device, is_saving)
            feature1 = cur_feature.cpu().numpy()
            for identity in feature_dict.keys():
                feature2 = feature_dict[identity].cpu().numpy()
                similarity = cosin_metric(feature1, feature2)
                similarities.update({identity: similarity})

            max_identity = max(similarities.items(),
                               key=operator.itemgetter(1))[0]
            return ('Identity is %s, and the similarity is %f' %
                    (max_identity, similarities[max_identity]))
        if is_11:
            cur_feature = featurize(
                fin_pil, transfrom, network, device, is_saving)
            feature1 = cur_feature.cpu().numpy()
            if search_identity in feature_dict.keys():
                feature2 = feature_dict[search_identity].cpu().numpy()
                similarity = cosin_metric(feature1, feature2)
                if similarity > cfg.threshold:
                    return ('Identity is %s, and the similarity is %f' %
                            (search_identity, similarity))
                else:
                    return ('Identity is not %s, while the similarity is %f!' % (
                        search_identity, similarity))
            else:
                return 'Not a known person!'

    cv2.destroyAllWindows()


def del_dict(del_identity):
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    feature_dir = './features/feature_dict.pth'

    if os.path.exists(feature_dir):
        feature_dict = torch.load(feature_dir, map_location=device)
    else:
        feature_dict = {}
    del feature_dict[del_identity]
    torch.save(feature_dict, feature_dir)
    return 'Deleted successfully!'


def person_list():
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    feature_dir = './features/feature_dict.pth'
    identities = []

    if os.path.exists(feature_dir):
        feature_dict = torch.load(feature_dir, map_location=device)
    else:
        feature_dict = {}

    for key in feature_dict.keys():
        identities.append(key)

    return identities
