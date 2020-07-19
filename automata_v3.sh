# Author MrBulldops @bullsecSecurity
# Recommended Usage: Set this script to an alias in your .bashrc file, then run from a new directory
# Deploy Script: https://raw.githubusercontent.com/bull-sec/bbdeploy/master/deploy.sh (run this first!)


#!/bin/bash


RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;36m"
YELLOW="\033[1;33m"
CYAN="\033[1;35m"
RESET="\033[0m"

gitToken="<YOURTOKENHERE>"
shodanToken="<YOURTOKENHERE>"

URL=$1

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
    echo -e "${CYAN}"
    echo "
░█▀▀█ █░░█ ▀▀█▀▀ █▀▀█ █▀▄▀█ █▀▀█ ▀▀█▀▀ █▀▀█ 　 ▀█░█▀ █▀▀█ ░ █▀▀█ 
▒█▄▄█ █░░█ ░░█░░ █░░█ █░▀░█ █▄▄█ ░░█░░ █▄▄█ 　 ░█▄█░ █▄▀█ ▄ ░░▀▄ 
▒█░▒█ ░▀▀▀ ░░▀░░ ▀▀▀▀ ▀░░░▀ ▀░░▀ ░░▀░░ ▀░░▀ 　 ░░▀░░ █▄▄█ █ █▄▄█"
    echo -e "${RESET}"

    echo -e "\n"
    echo -e "${RED}AUTOMATA v0.3${RESET} by ${GREEN}@bullsecSecurity${RESET}"
    echo -e "\nTarget: ${RED}$URL${RESET}"
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


spiderEndpoints(){
    echo -e "${RED}--==[ Spidering All Discovered Endpoints ]==--${RESET}"
    echo -e "${GREEN}Hosts to scan: $(cat scans/$URL.live_hosts.txt | wc -l) ${RESET}"
    for x in $(cat scans/$URL.live_hosts.txt);do
        gospider -s $x -o scans/endpoints/
    done
}


doReport(){
    echo -e "${RED}--==[ Generating Report Contents ]==--${RESET}"
    sleep 1
    echo -e "${BLUE}"
    echo -e "Files generated: $(ls scans/ | wc -l)"
    echo -e "${RESET}"
    read -p "Press enter to continue"
    sleep 1
}


passiveScan(){
    enumSubs
    combineDomains
    doReport
}


noScreenshots(){
    enumSubs
    combineDomains
    getActiveHosts
    checkTechStack
    doReport
}


withScreenshots(){
    enumSubs
    combineDomains
    getActiveHosts
    checkTechStack
    takeScreenshots
    doReport
}


hazeDer(){
    enumSubs
    combineDomains
    getActiveHosts
    checkTechStack
    takeScreenshots
    spiderEndpoints
    doReport
}


justSpider(){
    spiderEndpoints
    doReport
}


justTechStack(){
    checkTechStack
    doReport
}


main_loop(){
    banner
    setupEnvironment
    echo -e "${GREEN}"
    echo "1. Passive Scan"
    echo "2. Full Scan (No Screenshots)"
    echo "3. Full Scan (With Screenshots)"
    echo "4. Full Scan + Spidering"
    echo "5. Just Spidering"
    echo "6. Just Check Tech Stack"
    echo -e "7. Exit\n ${RESET}" 
    local choice
    read -p "Enter choice [ 1 - 7] " choice
    case $choice in
        1) passiveScan ;;
        2) noScreenshots ;;
        3) withScreenshots ;;
        4) hazeDer ;;
        5) justSpider ;;
        6) justTechStack ;;
        7) echo -e "${GREEN}Thanks for playing!${RESET}" && rm 1 && rm 2 && exit 0;;
        *) echo -e "${RED}Error...${STD}" && sleep 2
    esac
}


while true; do
    main_loop
done
