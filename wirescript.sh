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
wirebuilddir=$basedir"/wiretemp/"
wiredir=$basedir"/wire/"
wirecoredir=$basedir"/.wire/"
rm -r $wirebuilddir
rm -r $wiredir
rm -r $wirecoredir
sudo git clone https://github.com/Social-Wallet-Inc/wire-core $wirebuilddir
chmod -R 755 $wirebuilddir
cd $wirebuilddir
./autogen.sh
./configure
sudo make
mkdir $wiredir
file=$wirebuilddir"src/wired"
if [ ! -f "$file" ]
then
echo "Job fail during compile, please re-run the script again!"
else
cd $wirebuilddir"src"
sudo strip wired
sudo strip wire-cli
sudo strip wire-tx
cp wired $wiredir
cp wire-cli $wiredir
cp wire-tx $wiredir
cd $wiredir
chmod -R 755 $wiredir
mkdir $wirecoredir
rpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
echo -e "rpcuser=wirerpc\nrpcpassword="$rpcpassword >> $wirecoredir"wire.conf"
./wired -daemon
sleep 10
masternodekey=$(./wire-cli masternode genkey)
./wire-cli stop
sleep 1
echo -e "masternode=1\nmasternodeprivkey="$masternodekey >> $wirecoredir"wire.conf"
sleep 1
./wired -daemon
echo "Masternode private key: $masternodekey"
echo "Job completed successfully"
fi
