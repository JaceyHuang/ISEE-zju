from torchvision import datasets
from torch.utils.data import DataLoader
import torchvision.transforms as T


def create_dataset(cfg, training=True):
    train_transform = T.Compose([
        T.Grayscale(),
        T.RandomHorizontalFlip(),
        T.Resize((144, 144)),
        T.RandomCrop(cfg.input_shape[1:]),
        T.ToTensor(),
        T.Normalize(mean=[0.5], std=[0.5]),
    ])
    test_transform = T.Compose([
        T.Grayscale(),
        T.Resize(cfg.input_shape[1:]),
        T.ToTensor(),
        T.Normalize(mean=[0.5], std=[0.5]),
    ])
    
    if training:
        dataroot = cfg.train_root
        transform = train_transform
        batch_size = cfg.train_batch_size
    else:
        dataroot = cfg.test_root
        transform = test_transform
        batch_size = cfg.test_batch_size

    data = datasets.ImageFolder(dataroot, transform=transform)
    class_num = len(data.classes)
    loader = DataLoader(data, batch_size=batch_size, shuffle=True, pin_memory=cfg.pin_memory, num_workers=cfg.num_workers)
    return loader, class_num