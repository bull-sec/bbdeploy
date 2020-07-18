# Author MrBulldops @bullsecSecurity
# Recommended Usage: Set this script to an alias in your .bashrc file, then run from a new directory
# Deploy Script: https://raw.githubusercontent.com/bull-sec/bbdeploy/master/deploy.sh (run this first!)


#!/bin/bash


RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"


URL=$1
shodanToken="<YOURSHODANTOKEN>"
gitToken="<YOURGITHUBTOKEN>"

# Usage                                                    
display_usage() {                                          
    echo "Usage: ./automata.sh target.com"                                      
}                                                          

if [ $# -le 0 ]                                                                                                        
then                                                       
    display_usage                              
    exit 1                                     
fi 


setupEnvironment(){
    mkdir -p shots
    mkdir -p scans
    mkdir -p report
    mkdir -p www
}


banner(){
    clear
    echo -e "\n"
    echo -e "${RED}AUTOMATA v2${RESET} by ${GREEN}@bullsecSecurity${RESET}"
    echo -e "Target: ${RED}$URL${RESET}"
}


enumSubs(){
    echo -e "${RED}\n--==[ Enumerating subdomains ]==--${RESET}"
    cd scans/
    echo -e "${GREEN}findomain running${RESET}"
    findomain-linux -t $URL --output=scans/ > /dev/null 2>&1
    cd ../
    echo -e "${BLUE}findomain completed${RESET}"
    echo -e "${GREEN}shosubgo running${RESET}"
    shosubgo_linux_1_1 -d $URL -s $shodanToken | tee scans/$URL.shosubgo_doms.txt > /dev/null 2>&1
    echo -e "${BLUE}shosubgo completed${RESET}"
    echo -e "${GREEN}github-search running${RESET}"
    python3 /root/tools/github-search/github-subdomains.py -t $gitToken -d $URL | tee scans/$URL.github-subdomains.txt > /dev/null 2>&1
    echo -e "${BLUE}github-search completed${RESET}"
}

combineDomains(){
    echo -e "${RED}\n--==[ Combining subdomains ]==--${RESET}"
    cat scans/$URL.shosubgo_doms.txt scans/$URL.txt scans/$URL.github-subdomains.txt | sort -u | tee scans/$URL.sorted.txt > /dev/null 2&>1
    echo -e "${BLUE}Combined results saved to scans/$URL.sorted.txt${RESET}"
}


getActiveHosts(){
    echo -e "${RED}\n--==[ Getting Active Hosts ]==--${RESET}"
    massdns -r /root/tools/wordlists/resolvers.txt scans/$URL.sorted.txt -o S -q | tee scans/$URL.massdns_results.txt > /dev/null 2>&1
    cat scans/$URL.massdns_results.txt | cut -d ' ' -f 1 | sed 's/.$//' | tee scans/$URL.hosts.clean.txt > /dev/null 2>&1
    cat scans/$URL.hosts.clean.txt | httprobe | sort | tee scans/$URL.live_hosts.txt > /dev/null 2>&1
    echo -e "${BLUE}Live hosts saved to scans/$URL.live_hosts.txt${RESET}"
}

checkTechStack(){
    echo -e "${RED}--==[ Attempting to Determine Tech Stack ]==--${RESET}"
    webanalyze -update
    echo -e "${GREEN}webanalyze running${RESET}"
    webanalyze -hosts scans/$URL.live_hosts.txt -output json | tee scans/$URL.tech_stack.json > /dev/null 2>&1
    echo -e "${BLUE}webanalyze completed${RESET}"
}


takeScreenshots(){
    echo -e "${RED}--==[ Taking Screenshots ]==--${RESET}"
    echo -e "${GREEN}Hosts to Scan: $(cat scans/$URL.live_hosts.txt | wc -l) ${RESET}"
    gowitness-linux-amd64 file -s scans/$URL.live_hosts.txt --destination shots/ > /dev/null 2>&1
    echo -e "${BLUE}Screenshots Taken: $(ls  shots/ | wc -l) ${RESET}"
}


cleanUp(){
    rm 1
    rm 2
    mv gowitness.db $URL.db
    rm apps.json
}


setupEnvironment
banner
enumSubs
combineDomains
getActiveHosts
checkTechStack
takeScreenshots
cleanUp
echo -e "${RED}Thanks for playing!${RESET}"


