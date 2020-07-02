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

##
## This script outputs file type size in certain directory.
## Create directory in certain path 
## Copy this file into it.
## Execute this script.
## Result file is  ./output_intrajp/data_file_size_final
##
## Written by shintaro fujiwara
##

echo "This program creates a file in the current directory as file size as types."
echo -n "Directory you want to know file size as types:"
read DIRECTORY_GIVEN 
if [ ! -d "${DIRECTORY_GIVEN}" ]; then
    echo "${DIRECTORY_GIVEN} does not exist."
    exit 1
else
    echo "${DIRECTORY_GIVEN} exists."
    echo "I start."
fi
FILE_BASE_EXISTS="filedir_exists"
FILEDIR_TYPE="filedir_type"
FILEDIR_TYPE_PRE="filedir_type_pre"
FILEDIR_SIZE="filedir_size"
DATA_FILEDIR_TYPE="data_filedir_type"
DATA_FILEDIR_SIZE="data_filedir_size"
DATA_FILEDIR_TYPE_SIZE="data_filedir_type_size"
DATA_FILEDIR_TYPE_SIZE_SORT="data_filedir_type_size_sort"
OUTPUTDIR="output_intrajp"
FILE_COMPLETE2="${OUTPUTDIR}/file_complete2"
FILE_COMPLETE3="${OUTPUTDIR}/file_complete3"
OUTPUTFILE1="${OUTPUTDIR}/calculated_type_full_name" ## save this file
OUTPUTFILE2="${OUTPUTDIR}/calculated_type_final"
FILE_COMPLETE_FINAL="${OUTPUTDIR}/data_file_size_final"

find ${DIRECTORY_GIVEN} -type f -size +1c -exec file {} \; > "${FILEDIR_TYPE_PRE}"
grep -v "cannot open" "${FILEDIR_TYPE_PRE}" > "${FILEDIR_TYPE}"
unlink "${FILEDIR_TYPE_PRE}"
awk -F":" '{ print $1 }' "${FILEDIR_TYPE}" > "${FILE_BASE_EXISTS}"

while read line 
do
    ## this will do
    ls -l "$line" 2>&1 | awk '{ print $5" "$9}'
done <	"${FILE_BASE_EXISTS}" > "${FILEDIR_SIZE}"

#
# check if the line numbers are the same. 

lines_filedir_type=$(wc -l "${FILEDIR_TYPE}" | awk '{ print $1 }')
lines_filedir_size=$(wc -l "${FILEDIR_SIZE}" | awk '{ print $1 }')

if [ $lines_filedir_type -eq $lines_filedir_size ]; then
    echo "filedir_type:${lines_filedir_type}"
    echo "filedir_size:${lines_filedir_size}"
    echo ""
    echo "OK to proceed."
    echo "I start in 10 seconds."
    sleep 10
else
    echo "filedir_type:${lines_filedir_type}"
    echo "filedir_size:${lines_filedir_size}"
    echo ""
    echo "Maybe you should tweak a file."
    exit 1
fi

awk -F":" '{ print ":"$2 }' "${FILEDIR_TYPE}" > "${DATA_FILEDIR_TYPE}"
unlink "${FILEDIR_TYPE}" 
awk '{ print $1 }' "${FILEDIR_SIZE}" > "${DATA_FILEDIR_SIZE}"
unlink "${FILEDIR_SIZE}" 
paste "${DATA_FILEDIR_SIZE}" "${DATA_FILEDIR_TYPE}" > "${DATA_FILEDIR_TYPE_SIZE}"
unlink "${DATA_FILEDIR_TYPE}"
unlink "${DATA_FILEDIR_SIZE}"
sort -t : -k 2 "${DATA_FILEDIR_TYPE_SIZE}" > "${DATA_FILEDIR_TYPE_SIZE_SORT}"
unlink "${DATA_FILEDIR_TYPE_SIZE}"

SIZE_ALL=0
SIZE_ALL_AS_TYPE=0
TYPE_EACH_PRE=""
TYPE_EACH=""
##

# add this line to the last of "moodledata_filedir_size_type_sort"
# 0 : eof
if [ -d "${OUTPUTDIR}" ]; then
    rm -rf "${OUTPUTDIR}" 
fi
mkdir "${OUTPUTDIR}" 

function mashup_file_size ()
{
    local file="${1}"
    local outputfile="${2}"
    local cnt=1
    while read line 
    do
        SIZE_EACH=""
        TYPE_EACH=""
        SIZE_EACH=`echo $line | awk '{ print $1 }'`
        TYPE_EACH=`echo $line | awk -F":" '{ print $2 }'`
        if [ "${TYPE_EACH_PRE}" != "" ]; then
            if [ "${TYPE_EACH}" != "${TYPE_EACH_PRE}" ]; then
                echo "${SIZE_ALL_AS_TYPE}:${TYPE_EACH_PRE}" >> "${outputfile}"   
                SIZE_ALL_AS_TYPE=0
            fi
        fi
        TYPE_EACH_PRE="${TYPE_EACH}"
        SIZE_ALL_AS_TYPE=$((SIZE_EACH + SIZE_ALL_AS_TYPE))
        if [ "${outputfile}" = "${OUTPUTFILE2}" ]; then
            SIZE_ALL=$((SIZE_EACH + SIZE_ALL))
        fi
        cnt=$((cnt + 1))
    done < "${file}" 
}


sed -i "$ a 0 : eof" "${DATA_FILEDIR_TYPE_SIZE_SORT}"
mashup_file_size "${DATA_FILEDIR_TYPE_SIZE_SORT}" "${OUTPUTFILE1}" 
unlink "${DATA_FILEDIR_TYPE_SIZE_SORT}" 
## here we want to cut long type name
awk -F"," '{ print $1 }' "${OUTPUTFILE1}" >  "${FILE_COMPLETE2}"
sed -i -e "s/:/ :/g" "${FILE_COMPLETE2}"
sed -i "$ a 0 : eof" "${FILE_COMPLETE2}" 

mashup_file_size "${FILE_COMPLETE2}" "${OUTPUTFILE2}" 
unlink "${FILE_COMPLETE2}"
sed -i -e "s/:/ :/g" "${OUTPUTFILE2}"
sort -t : -n -r "${OUTPUTFILE2}" > ${FILE_COMPLETE_FINAL}
unlink "${OUTPUTFILE2}" 
sed -i '/0 : eof/d' "${FILE_COMPLETE_FINAL}"
sed -i '/0 : empty/d' "${FILE_COMPLETE_FINAL}"
echo "" >> "${FILE_COMPLETE_FINAL}"
echo $SIZE_ALL" : All files (size)" >> "${FILE_COMPLETE_FINAL}"

unlink "${FILE_BASE_EXISTS}"

echo ""
echo "Check result: ${FILE_COMPLETE_FINAL}"
