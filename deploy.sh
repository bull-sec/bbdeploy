#!/bin/bash

apt update
apt install wget curl git tar gzip nmap jq unzip tmux zsh build-essential -y
mkdir /root/tools
cd /root/tools

wget https://github.com/rverton/webanalyze/releases/download/v0.3.1/webanalyze_0.3.1_Linux_x86_64.tar.gz
tar xvf webanalyze_0.3.1_Linux_x86_64.tar.gz
rm webanalyze_0.3.1_Linux_x86_64.tar.gz

wget https://github.com/jaeles-project/gospider/releases/download/v1.1.0/gospider_1.1.0_linux_amd64.tar.gz
tar xvf gospider_1.1.0_linux_amd64.tar.gz
rm gospider_1.1.0_linux_amd64.tar.gz
rm README.md

wget https://github.com/ffuf/ffuf/releases/download/v1.0.2/ffuf_1.0.2_linux_amd64.tar.gz
tar xvf ffuf_1.0.2_linux_amd64.tar.gz
rm CHANGELOG.md
rm LICENSE
rm README.md
rm ffuf_1.0.2_linux_amd64.tar.gz

wget https://github.com/tomnomnom/httprobe/releases/download/v0.1.2/httprobe-linux-amd64-0.1.2.tgz
tar xvf httprobe-linux-amd64-0.1.2.tgz
rm httprobe-linux-amd64-0.1.2.tgz

wget https://github.com/sensepost/gowitness/releases/download/1.3.3/gowitness-linux-amd64
chmod +x gowitness-linux-amd64

wget https://github.com/Edu4rdSHL/findomain/releases/download/1.7.0/findomain-linux
chmod +x findomain-linux

wget https://github.com/OWASP/Amass/releases/download/v3.7.3/amass_linux_amd64.zip
unzip amass_linux_amd64.zip
mv amass_linux_amd64/amass /root/tools/amass
rm amass_linux_amd64.zip
rm -r amass_linux_amd64/

wget https://github.com/blechschmidt/massdns/archive/v0.3.zip
unzip v0.3.zip
cd /root/tools/massdns-0.3/
make
mv /root/tools/massdns-0.3/bin/massdns /root/tools/massdns
cd /root/tools
rm -r massdns-0.3/
rm v0.3.zip

wget https://github.com/sharkdp/bat/releases/download/v0.15.4/bat_0.15.4_amd64.deb
dpkg -i bat_0.15.4_amd64.deb
rm bat_0.15.4_amd64.deb

wget https://github.com/junegunn/fzf/archive/0.20.0.zip
unzip 0.20.0.zip
WORKDIR /root/fzf-0.20.0
bash ./install --all
WORKDIR /root/
rm 0.20.0.zip

wget https://github.com/lc/gau/releases/download/v1.0.2/gau_1.0.2_linux_amd64.tar.gz
tar xvf gau_1.0.2_linux_amd64.tar.gz
rm gau_1.0.2_linux_amd64.tar.gz
rm LICENSE
rm README.md


git clone https://github.com/danielmiessler/SecLists.git /root/tools/wordlists/seclists

wget https://github.com/BBerastegui/fresh-dns-servers/blob/master/resolvers.txt -O /root/tools/wordlists/resolvers.txt

# Environment
mkdir /root/.tmux
wget https://raw.githubusercontent.com/bull-sec/DotFiles/master/.tmux.conf-digi -O /root/.tmux.conf
cd /root/
ln -s /root/.tmux.conf

#git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
#wget https://raw.githubusercontent.com/bull-sec/DotFiles/master/.zshrc-digi -O /root/.zshrc

wget https://raw.githubusercontent.com/bull-sec/DotFiles/master/.bashrc -O /root/.bashrc

cd /root/
wget https://github.com/junegunn/fzf/archive/0.20.0.zip
unzip 0.20.0.zip
cd /root/fzf-0.20.0
bash ./install --all
cd /root/
rm 0.20.0.zip

#wget https://raw.githubusercontent.com/bull-sec/DotFiles/master/.passwd-digi
#mv .passwd-digi /etc/passwd

echo "Happy Hacking!" 
