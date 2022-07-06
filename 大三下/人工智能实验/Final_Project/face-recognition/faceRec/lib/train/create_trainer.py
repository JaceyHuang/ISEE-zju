import torch.nn as nn
import torch.optim as optim

from lib.train.loss import FocalLoss

def create_trainer(cfg, network, metric):
    if cfg.loss == 'focal_loss':
        criterion = FocalLoss(gamma=2)
    else:
        criterion = nn.CrossEntropyLoss()

    if cfg.optimizer == 'sgd':
        optimizer = optim.SGD([{'params': network.parameters()}, {'params': metric.parameters()}], lr=cfg.lr, weight_decay=cfg.weight_decay)
    else:
        optimizer = optim.Adam([{'params': network.parameters()}, {'params': metric.parameters()}], lr=cfg.lr, weight_decay=cfg.weight_decay)

    scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=cfg.lr_step, gamma=0.1)

    return criterion, optimizer, scheduler