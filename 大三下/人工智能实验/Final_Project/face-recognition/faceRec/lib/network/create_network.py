import torch.nn as nn

from lib.network.fmobilenet import FaceMobileNet
from lib.network.resnet import ResIRSE
from lib.network.metric import ArcFace, CosFace


def create_network(cfg, class_num):
    if cfg.backbone == 'resnet':
        network = ResIRSE(cfg.embedding_size, cfg.drop_ratio).to(cfg.device)
    else:
        network = FaceMobileNet(cfg.embedding_size).to(cfg.device)

    if cfg.metric == 'arcface':
        metric = ArcFace(cfg.embedding_size, class_num).to(cfg.device)
    else:
        metric = CosFace(cfg.embedding_size, class_num).to(cfg.device)

    network = nn.DataParallel(network)
    metric = nn.DataParallel(metric)
    
    return network, metric