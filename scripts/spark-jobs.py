#!/usr/bin/python
# coding=utf-8

import sys
import requests
from bs4 import BeautifulSoup as BS

def findRunningApplicationsTable(soup):
        header = soup.find(string=" Running Applications ");

        if not header:
                return None
        rows = header.parent.find_next_sibling("table").find("tbody").find_all("tr")
        applications = {}
        for row in rows:
                id = row.find("td").find("a").string
                name = row.find("td").find_next_sibling("td").find("a")
                applications[id] = {'name': name.string, 'driver': name['href']}
        return applications

def printApps(apps):
        if len(apps):
                print "ID                       Name                      Driver"
                for app in apps:
                        print app+": {name} {driver}".format(**apps[app])

if len(sys.argv) < 2:
        print "Usage: spark-jobs.py host:port[,host:port ...]"
        exit(1)
masters = sys.argv[1].split(',')

pages = []
for master in masters:
        page = BS(requests.get("http://"+master).content,"html5lib")
        apps = findRunningApplicationsTable(page)
        if len(apps):
                print "Master: " + master
                printApps(apps)
                break
