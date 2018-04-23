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
cd
basedir=$(pwd)
infinexbuilddir=$basedir"/infinextemp/"
infinexdir=$basedir"/infinex/"
infinexcoredir=$basedir"/.infinexcore/"
rm -r $infinexbuilddir
rm -r $infinexdir
rm -r $infinexcoredir
sudo git clone https://github.com/InfinexOfficial/infinex $infinexbuilddir
chmod -R 755 $infinexbuilddir
cd $infinexbuilddir
./autogen.sh
./configure
sudo make
mkdir $infinexdir
file=$infinexbuilddir"src/infinexd"
if [ ! -f "$file" ]
then
cd $infinexdir
wget https://github.com/InfinexOfficial/Infinex/releases/download/1.0/infinex-cli
wget https://github.com/InfinexOfficial/Infinex/releases/download/1.0/infinex-tx
wget https://github.com/InfinexOfficial/Infinex/releases/download/1.0/infinexd
else
cd $infinexbuilddir"src"
sudo strip infinexd
sudo strip infinex-cli
sudo strip infinex-tx
cp infinexd $infinexdir
cp infinex-cli $infinexdir
cp infinex-tx $infinexdir
fi
cd $infinexdir
chmod -R 755 $infinexdir
mkdir $infinexcoredir
./infinexd -daemon
sleep 10
masternodekey=$(./infinex-cli masternode genkey)
./infinex-cli stop
sleep 1
echo -e "maxconnections=256\nmasternode=1\nmasternodeprivkey=$masternodekey" >> /root/.infinexcore/infinex.conf
sleep 1
./infinexd -daemon
echo "Masternode private key: $masternodekey"
echo "Job completed successfully"
