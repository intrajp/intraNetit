#!/bin/bash

##
##  Copyright (C) 2021 Shintaro Fujiwara
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
## Version: v0.0.4
## Written by Shintaro Fujiwara
#################################

CVENUMBER="${1}"
CVENUMBER_FILE="${CVENUMBER}"

function get_access_vector()
{
    local av_str="${1}"
    if [ "${av_str}" == "L" ]; then
        AV="LOCAL"
    elif [ "${av_str}" == "N" ]; then
        AV="NETWORK"
    else
        AV="Unknown"
fi
}

wget -O "${CVENUMBER_FILE}" https://nvd.nist.gov/vuln/detail/"${CVENUMBER}"
sed -i -e 's///g' "${CVENUMBER_FILE}"
CWEID=$(grep -E "CWE-[0-9]+" "${CVENUMBER_FILE}" | xargs | sed -e 's/.*blank>//g' | sed -e 's/<.*//g' | sed -e 's///g')
VULNERABILITY_DATE=$(grep -Hrn "vuln-published-on" "${CVENUMBER_FILE}"| awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }' | sed -e 's///g')
VULNERABILITY_DATE_YEAR=$(echo "${VULNERABILITY_DATE}" | awk -F"/" '{ print $3"/" }' | sed -e 's///g')
VULNERABILITY_DATE_MONTH_DAY=$(echo "${VULNERABILITY_DATE}" | awk -F"/" '{ print $1"/"$2 }' | sed -e 's///g')
VULNERABILITY_DATE=$(echo "${VULNERABILITY_DATE_YEAR}${VULNERABILITY_DATE_MONTH_DAY}" | sed -e 's/^M//g')
VULNERABILITY_DESCRIPTION=$(grep -Hrn "vuln-analysis-description\"" "${CVENUMBER_FILE}")
VULNERABILITY_DESCRIPTION=$(echo "${VULNERABILITY_DESCRIPTION}" | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }' | sed -e 's///g')
VECTOR_STRING2=$(grep -Hrn "tooltipCvss2NistMetrics\">(AV" "${CVENUMBER_FILE}" | sed -e 's/.*>(//' | sed -e 's/).*//' | sed -e 's///g')
VECTOR_STRING3=$(grep -Hrn "CVSS\:3" "${CVENUMBER_FILE}" | sed -e 's/.*Metrics">//' | sed -e 's/<.*>//' | sed -e 's///g')
ATTACK_VECTOR2=$(echo "${VECTOR_STRING2}" | awk -F":" '{ print $2 }' | awk -F"/" '{ print $1}' | sed -e 's///g')
ATTACK_VECTOR3=$(echo "${VECTOR_STRING3}" | awk -F"/" '{ print $2 }' | awk -F":" '{ print $2}' | sed -e 's///g')
get_access_vector "${ATTACK_VECTOR2}"
ATTACK_VECTOR2="${AV}"
get_access_vector "${ATTACK_VECTOR3}"
ATTACK_VECTOR3="${AV}"
VALUE_VERSION2=$(grep -Hrn "version=2" "${CVENUMBER_FILE}")
VALUE_VERSION3=$(grep -Hrn "version=3" "${CVENUMBER_FILE}" -A2)
SCORE_AND_SEVERITY_VERSION2=$(echo "${VALUE_VERSION2}" | sed -e 's/.*label-.*">//' | sed -e 's/<.*>//' | sed -e 's/^M//g' | xargs)
SCORE_VERSION2=$(echo "${SCORE_AND_SEVERITY_VERSION2}" | awk -F" " '{ print $1 }' | sed -e 's///g')
SEVERITY_VERSION2=$(echo "${SCORE_AND_SEVERITY_VERSION2}" | awk -F" " '{ print $2 }' | sed -e 's///g')
VALUE_VERSION3=$(echo "${VALUE_VERSION3}")
SCORE_VERSION3=$(echo "${VALUE_VERSION3}" | awk -F"class=\"label" '{ print $2 }' | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }' | sed -e 's///g')
SCORE_AND_SEVERITY_VERSION3=$(echo "${SCORE_VERSION3}" | sed -e 's///g' |xargs)
SCORE_VERSION3=$(echo "${SCORE_AND_SEVERITY_VERSION3}" | awk -F " " '{ print $1 }' | sed -e 's///g')
SEVERITY_VERSION3=$(echo "${SCORE_AND_SEVERITY_VERSION3}" | awk -F" " '{ print $2 }' | sed -e 's///g')
echo ""
echo "CVENUMBER:${CVENUMBER}"
echo "VULNERABILITY_DATE:${VULNERABILITY_DATE}"
echo "VULNERABILITY_DESCRIPTION:${VULNERABILITY_DESCRIPTION}"
echo "CWEID:${CWEID}"
echo "VECTOR_STRING2:${VECTOR_STRING2}"
echo "ATTACK_VECTOR2:${ATTACK_VECTOR2}"
echo "SCORE_VERSION2:${SCORE_VERSION2}"
echo "SEVERITY_VERSION2:${SEVERITY_VERSION2}"
echo "VECTOR_STRING3:${VECTOR_STRING3}"
echo "ATTACK_VECTOR3:${ATTACK_VECTOR3}"
echo "SCORE_VERSION3:${SCORE_VERSION3}"
echo "SEVERITY_VERSION3:${SEVERITY_VERSION3}"

unlink "${CVENUMBER_FILE}"

exit 0
