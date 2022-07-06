import torch
import os

def save_network(cfg, network, epoch, latest=False):
    model_dir = cfg.checkpoints
    backbone_path = cfg.checkpoints + "/" + str(epoch) + ".pth"
    torch.save(network.state_dict(), backbone_path)

    if latest:
        backbone_path = os.path.join(model_dir, "latest.pth")
    else: 
        backbone_path = os.path.join(model_dir, '{}.pth'.format(epoch))
    torch.save(network.state_dict(), backbone_path)
    
    # 清除过早的model
    pths = [
        int(pth.split('.')[0]) for pth in os.listdir(model_dir)
        if pth != 'latest.pth'
    ]
    if len(pths) <= 5:
        return
    os.system('rm {}'.format(
        os.path.join(model_dir, '{}.pth'.format(min(pths)))))