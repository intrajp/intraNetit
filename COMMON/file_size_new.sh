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
## Version: v0.1.0
## Written by Shintaro Fujiwara
#################################

FILE_TEMP1="intrajp_tmp1"
FILE_TEMP2="intrajp_tmp2"
FILE_TEMP3="intrajp_tmp3"
FILE_TEMP4="intrajp_tmp4"
RESULT_FILE="intrajp_file_type_result.txt"

function usage()
{
    echo $0 "<directory name>"
    echo "Result file will be made as ${FILE_TEMP4}"
}

function test0()
{
    if [ -z "${1}" ]; then
        echo "Please give directory name."
        usage 
        exit 1
    fi

    { LANG=C; find "${1}" -type f -exec file {} \; -exec du -c {} \; ; } > "${FILE_TEMP1}" ; sed -i '/total/d' "${FILE_TEMP1}"
}

function test1()
{ 
    local odd=
    local line_num=1
    local size_type_this=""

    while read line
    do
        if [ $((line_num % 2)) -eq 0 ]; then
            size_this=$(echo "${line}" | awk -F" " '{ print $1 }')
            echo "${line}"":""${size_type_this}"
        else
            size_type_this=$(echo "${line}" | awk -F":" '{ print $2 }')
        fi
        line_num=$((line_num + 1))
    done < "${FILE_TEMP1}" > "${FILE_TEMP2}"
}

function test2()
{
    sort -t":" -k2 "${FILE_TEMP2}" > "${FILE_TEMP3}"
}

function test3()
{
    last_line=$(wc -l < "${FILE_TEMP3}")
}

function test4()
{
    local size_file_type=0
    local size_all=0
    local file_type_pre=""
    local line_num=0

    while read line
    do
        size_this=0
        file_type_this=""

        size_this=$(echo "${line}" | awk -F" " '{ print $1 }')
        file_type_this=$(echo "${line}" | awk -F":" '{ print $2 }')
        if [ ! "${file_type_pre}" == "${file_type_this}" ] && [ "${line_num}" -ne 0 ] ; then
            echo "${size_file_type}"" ""${file_type_pre}"
            size_file_type=0
        fi
        size_file_type=$((size_file_type + size_this))
        file_type_pre="${file_type_this}"
        line_num=$((line_num + 1))
        if [ "${line_num}" == "${last_line}" ] && [ "${file_type_pre}" != "${file_type}" ]; then
            echo "${size_this}"" ""${file_type_this}"
        fi
        size_all=$((size_all + size_this))
        if [ "${line_num}" == "${last_line}" ]; then
            echo "${size_all}"" ""Total"
        fi
    done < "${FILE_TEMP3}" > "${FILE_TEMP4}" 
}

function test5()
{
    sort -n -r -k1 "${FILE_TEMP4}" > "${RESULT_FILE}"    
}

test0 "${1}"
test1
test2
test3
test4
test5

echo "Please check ${RESULT_FILE}."

exit 0
