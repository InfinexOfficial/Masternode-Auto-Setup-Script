#!/bin/bash
if free | awk '/^Swap:/ {exit !$2}'; then
echo "Have swap"
else
sudo touch /var/swap.img
sudo chmod 600 /var/swap.img
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
mkswap /var/swap.img
sudo swapon /var/swap.img
sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
fi
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install nano htop git -y
sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common -y
sudo apt-get install libboost-all-dev -y
sudo apt-get install libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
sudo git clone https://github.com/InfinexOfficial/infinex temp
chmod -R 755 /root/temp
cd /root/temp
./autogen.sh
./configure
sudo make
cd /root/temp/src
sudo strip infinexd
sudo strip infinex-cli
sudo strip infinex-tx
mkdir /root/infinex
cp infinexd /root/infinex
cp infinex-cli /root/infinex
cp infinex-tx /root/infinex
cd /root/infinex
chmod -R 755 /root/infinex
mkdir /root/.infinexcore
./infinexd -daemon
sleep 3
masternodekey=$(./infinex-cli masternode genkey)
./infinex-cli stop
echo -e "maxconnections=256\nmasternode=1\nmasternodeprivkey=$masternodekey" >> /root/.infinexcore/infinex.conf
./infinexd -daemon
echo "Masternode private key: $masternodekey"
echo "Job completed successfully"
