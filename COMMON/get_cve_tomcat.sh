#!/bin/bash

##
##  Copyright (C) 2020 Shintaro Fujiwara
##
##  This script is free software; you can redistribute it and/or
##  modify it under the terms of the GNU Lesser General Public
##  License as published by the Free Software Foundation; either
##  version 2.1 of the License, or (at your option) any later version.
##
##  This script is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
##  Lesser General Public License for more details.
##
##  You should have received a copy of the GNU Lesser General Public
##  License along with this library; if not, write to the Free Software
##  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
##  02110-1301 USA
##
## Version: v0.0.1
## Written by Shintaro Fujiwara
#################################

FILENAME7="security-7.html"
FILENAME8="security-8.html"
FILENAME9="security-9.html"

if [ -e "${FILENAME7}" ]; then
    unlink "${FILENAME7}"
fi
if [ -e "${FILENAME8}" ]; then
    unlink "${FILENAME8}"
fi
if [ -e "${FILENAME9}" ]; then
    unlink "${FILENAME9}"
fi
FILENAME7_CVE="tomcat7_cve.txt"
FILENAME8_CVE="tomcat8_cve.txt"
FILENAME9_CVE="tomcat9_cve.txt"

wget -O "${FILENAME7}" https://tomcat.apache.org/"${FILENAME7}"
wget -O "${FILENAME8}" https://tomcat.apache.org/"${FILENAME8}"
wget -O "${FILENAME9}" https://tomcat.apache.org/"${FILENAME9}"

grep -Hrn "Important\|Moderate\|Low" "${FILENAME7}" -A 2 | grep -v "Important\|Moderate\|Low" | grep "CVE" | sed -e 's/.*nofollow">//' |sed -e 's/<.*>//' > "${FILENAME7_CVE}"
grep -Hrn "Important\|Moderate\|Low" "${FILENAME8}" -A 2 | grep -v "Important\|Moderate\|Low" | grep "CVE" | sed -e 's/.*nofollow">//' |sed -e 's/<.*>//' > "${FILENAME8_CVE}"
grep -Hrn "Important\|Moderate\|Low" "${FILENAME9}" -A 2 | grep -v "Important\|Moderate\|Low" | grep "CVE" | sed -e 's/.*nofollow">//' |sed -e 's/<.*>//' > "${FILENAME9_CVE}"

exit 0
