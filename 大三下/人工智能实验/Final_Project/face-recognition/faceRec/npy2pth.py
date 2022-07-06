import joblib
import torch
import os

if __name__ == '__main__':
    feature_dir_origin = './features/feature_dict.npy'
    if os.path.exists(feature_dir_origin):
        feature_dict = joblib.load(feature_dir_origin)
        feature_dir = './features/feature_dict.pth'
        torch.save(feature_dict, feature_dir)