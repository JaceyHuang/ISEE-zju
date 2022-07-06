import os
import torch

def load_network(cfg, network, is_training=False):
    checkpoints = cfg.checkpoints
    os.makedirs(checkpoints, exist_ok=True)

    if cfg.restore:
        weights_path = os.path.join(checkpoints, cfg.restore_model)
        network.load_state_dict(torch.load(weights_path, map_location=cfg.device))