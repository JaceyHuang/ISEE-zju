from .yacs import CfgNode as CN
import torch
import argparse

cfg = CN()

cfg.backbone = 'fmobile' # [resnet, fmobile]
cfg.metric = 'arcface'  # [cosface, arcface]
cfg.embedding_size = 512
cfg.drop_ratio = 0.5

# data preprocess
cfg.input_shape = [1, 128, 128]

# dataset
cfg.train_root = '/home/jxhuang/faceRec/data/CASIA'
cfg.test_root = 'C:/Users/HP/Desktop/College/大学/大三下/人工智能实验/Final_Project/face-recognition/data/lfw/lfw_funeled_cropped'
cfg.test_list = "C:/Users/HP/Desktop/College/大学/大三下/人工智能实验/Final_Project/face-recognition/data/lfw/pairs.txt"


# training settings
cfg.checkpoints = "models/faceRec"
cfg.restore = True
cfg.restore_model = "18.pth"
cfg.test_model = "18.pth"
    
cfg.train_batch_size = 64
cfg.test_batch_size = 64

cfg.begin = 19
cfg.epoch = 25
cfg.optimizer = 'sgd'  # ['sgd', 'adam']
cfg.lr = 1e-1
cfg.lr_step = 10
cfg.lr_decay = 0.95
cfg.weight_decay = 5e-4
cfg.loss = 'focal_loss' # ['focal_loss', 'cross_entropy']
cfg.device = 'cuda' if torch.cuda.is_available() else 'cpu'

cfg.pin_memory = True  # if memory is large, set it True to speed up a bit
cfg.num_workers = 4  # dataloader

# test
cfg.threshold = 0.66
cfg.is_saving = False
cfg.is_1N = True
cfg.is_11 = False

cfg.save_ep = 1
cfg.save_latest_ep = 1

def create_cfg(args):
    cfg.merge_from_file(args.cfg_file)
    return cfg

parser = argparse.ArgumentParser()
parser.add_argument("--cfg_file", default="configs/faceRec.yaml", type=str)
args = parser.parse_args()
cfg = create_cfg(args)
