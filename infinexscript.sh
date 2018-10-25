#!/bin/bash
if free | awk '/^Swap:/ {exit !$2}'; then
echo "Have swap"
else
sudo touch /var/swap.img
sudo chmod 600 /var/swap.img
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=4000
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
sudo make -j2
mkdir $infinexdir
file=$infinexbuilddir"src/infinexd"	
file2=$infinexbuilddir"src/infinex-cli"	
if [ ! -f "$file" ] || [ ! -f "$file2" ]	
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
cd $infinexdir	
fi
chmod -R 755 $infinexdir
./infinexd -daemon
sleep 30
masternodekey=$(./infinex-cli masternode genkey)
counter = 0
while [ "$masternodekey" == "" && $counter -le 3 ]
do
counter=$((counter+1))
sleep 10
masternodekey=$(./infinex-cli masternode genkey)
done
if [ "$masternodekey" == "" ]
then
echo "Fail to generate masternode privkey, please contact Infinex Discord Channel for help"
else
./infinex-cli stop
sleep 1
echo -e "maxconnections=873\nmasternode=1\nmasternodeprivkey=$masternodekey" >> $infinexcoredir"infinex.conf"
crontab -l | { cat; echo "@reboot ./infinex/infinexd -daemon"; } | crontab -
sleep 1
./infinexd -daemon
echo "Masternode private key: $masternodekey"
echo "Job completed successfully"
fi
