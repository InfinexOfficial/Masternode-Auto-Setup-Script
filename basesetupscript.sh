
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
sudo apt full-upgrade -y
sudo apt-get install nano htop git inotify-tools -y
sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common -y
sudo apt-get install libboost-all-dev -y
sudo apt-get install libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
echo -e "#!/bin/bash\nwhile :\ndo\nif pgrep infinexd >/dev/null 2>&1\nthen\n:else\n./infinex/infinexd -daemon\nfi\nsleep 10\ndone" >> autorestart.sh
echo -e "if [ -f /root/infinexd ]; then\nif [ -f /root/infinex-cli ]; then\npkill autorestart.sh\n./infinex/infinex-cli stop\nrm /root/.infinexcore/banlist.dat\nrm /root/.infinexcore/netfulfilled.dat\nrm /root/.infinexcore/peers.dat\nrm /root/.infinexcore/debug.log\nsleep 1\nmv /root/infinexd /root/infinex/\nmv /root/infinex-cli /root/infinex/\nsleep 1\nnohup ./autorestart.sh > autorestart.log 2>&1&\nfi\nfi" >> auto.sh
shutdown -r now
