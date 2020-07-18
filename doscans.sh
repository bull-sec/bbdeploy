#!/bin/bash

URL=$1

findomain-linux -t $URL -o

mkdir $1

massdns -r /root/tools/wordlists/resolvers.txt tesla.com.txt -o S > $1/results.txt

cat $1/results.txt | cut -d ' ' -f 1 | sed 's/.$//' > $1/clean.txt

cat $1/clean.txt | httprobe > $1/live_hosts.txt
