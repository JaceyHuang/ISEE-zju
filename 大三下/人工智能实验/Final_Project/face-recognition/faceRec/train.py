from lib.config.config import cfg
from lib.dataloader.create_dataset import create_dataset
from lib.network.create_network import create_network
from lib.network.load_network import load_network
from lib.network.save_network import save_network
from lib.train.create_trainer import create_trainer

import time

def train():
    dataloader, class_num = create_dataset(cfg, training=True)
    network, metric = create_network(cfg, class_num)
    criterion, optimizer, scheduler = create_trainer(cfg, network, metric)

    load_network(cfg, network)

    network.train()
    for epoch in range(cfg.begin, cfg.epoch):
        for data, labels in dataloader:
            # start = time.time()
            data = data.to(cfg.device)
            labels = labels.to(cfg.device)
            optimizer.zero_grad()
            embeddings = network(data)
            thetas = metric(embeddings, labels)
            loss = criterion(thetas, labels)
            loss.backward()
            optimizer.step()
            # end = time.time() - start
            # print('Time cost: %f, Loss: %f' % (end, loss))

        print('Epoch ' + str(epoch) + '/' + str(cfg.epoch) + ', Loss: }' + str(loss))

        if (epoch + 1) % cfg.save_ep == 0:
            save_network(cfg, network, epoch)
        
        if (epoch + 1) % cfg.save_latest_ep == 0:
            save_network(cfg, network, epoch, latest=True)

        scheduler.step()


if __name__ == '__main__':
    train()