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
## Version: v0.1.0
## Written by Shintaro Fujiwara
#################################
echo "This program creates a file in the current directory as file size by file type."
echo -n "Directory you want to know file size by file type:"
read DIRECTORY_GIVEN 
if [ ! -d "${DIRECTORY_GIVEN}" ]; then
    echo "${DIRECTORY_GIVEN} does not exist."
    exit 1
else
    echo "${DIRECTORY_GIVEN} exists."
    echo "I start."
fi
#################################
FILE_BASE_EXISTS="filedir_exists"
FILEDIR_TYPE="filedir_type"
FILEDIR_TYPE_PRE="filedir_type_pre"
FILEDIR_SIZE_PRE="filedir_size_pre"
FILEDIR_SIZE="filedir_size"
DATA_FILEDIR_TYPE="data_filedir_type"
DATA_FILEDIR_SIZE="data_filedir_size"
DATA_FILEDIR_TYPE_SIZE="data_filedir_type_size"
DATA_FILEDIR_TYPE_SIZE_SORT="data_filedir_type_size_sort"
OUTPUTDIR="output_intrajp"
FILE_COMPLETE2="${OUTPUTDIR}/file_complete2"
FILE_COMPLETE2_1="${OUTPUTDIR}/file_complete2_1"
FILE_COMPLETE2_2="${OUTPUTDIR}/file_complete2_2"
FILE_COMPLETE3="${OUTPUTDIR}/file_complete3"
OUTPUTFILE1="${OUTPUTDIR}/calculated_type_full_name"
OUTPUTFILE2="${OUTPUTDIR}/calculated_type_final"
FILE_COMPLETE_FINAL="${OUTPUTDIR}/data_file_size_final"

## entry point ##

find ${DIRECTORY_GIVEN} -type f -size +1c | xargs ls -l > "${FILEDIR_SIZE_PRE}"
grep -v "cannot open" "${FILEDIR_SIZE_PRE}" > "${FILEDIR_SIZE}"
unlink "${FILEDIR_SIZE_PRE}"
awk -F" " '{ print $9 }'  "${FILEDIR_SIZE}" > "${FILE_BASE_EXISTS}"
file -f "${FILE_BASE_EXISTS}" > "${FILEDIR_TYPE}"
awk -F" " '{ s = ""; for (i = 2; i <= NF; i++) s = s $i " "; print s }' "${FILEDIR_TYPE}" > "${DATA_FILEDIR_TYPE}"
awk -F" " '{ print $5 }'  "${FILEDIR_SIZE}" > "${DATA_FILEDIR_SIZE}"
rev "${FILEDIR_TYPE}" > "${FILEDIR_TYPE}2"
awk -F" " '{ s = ""; for (i = 2; i <= NF; i++) s = s $i " "; print s }' "${FILEDIR_TYPE}2" > "${FILEDIR_TYPE}3"
rev "${FILEDIR_TYPE}3" > "${FILEDIR_TYPE}4"
awk -F" " '{ print $1 }'  "${FILEDIR_TYPE}" > file_name_from_filetype
awk -F" " '{ print $9":" }'  "${FILEDIR_SIZE}" > file_name_from_filesize 
FILE_NAME_FROM_FILESIZE_COUNT=$(wc -c < file_name_from_filesize)
FILE_NAME_FROM_FILETYPE_COUNT=$(wc -c < file_name_from_filetype)

if [ "${FILE_NAME_FROM_FILESIZE_COUNT}" -eq "${FILE_NAME_FROM_FILETYPE_COUNT}" ]; then
    echo "Seems like filename from filesize and filename from filetype is the same."
    echo "OK to proceed."
    echo "I start in 5 seconds."
    sleep 5 
else
    echo "Something went wrong. Maybe you should tweak a file."
    exit 1
fi

unlink "${FILEDIR_TYPE}" 
unlink "${FILEDIR_TYPE}2" 
unlink "${FILEDIR_TYPE}3" 
unlink "${FILEDIR_TYPE}4" 
unlink "${FILEDIR_SIZE}" 
paste "${DATA_FILEDIR_SIZE}" "${DATA_FILEDIR_TYPE}" > "${DATA_FILEDIR_TYPE_SIZE}"
unlink "${DATA_FILEDIR_SIZE}"
unlink "${DATA_FILEDIR_TYPE}"
sort -t " " -k 2,2 "${DATA_FILEDIR_TYPE_SIZE}" > "${DATA_FILEDIR_TYPE_SIZE_SORT}"
unlink "${DATA_FILEDIR_TYPE_SIZE}"

SIZE_ALL=0
SIZE_ALL_AS_TYPE=0
TYPE_EACH_PRE=""
TYPE_EACH=""

if [ -d "${OUTPUTDIR}" ]; then
    rm -rf "${OUTPUTDIR}" 
fi
mkdir "${OUTPUTDIR}" 

function mashup_file_size ()
{
    SIZE_ALL=0
    SIZE_ALL_AS_TYPE_G=0
    SIZE_ALL_AS_TYPE_M=0
    SIZE_ALL_AS_TYPE_K=0
    SIZE_ALL_AS_TYPE=0

    local file="${1}"
    local outputfile="${2}"
    local cnt=1
    while read line 
    do
        SIZE_EACH=0
        TYPE_EACH=0
        if [ "${outputfile}" = "${OUTPUTFILE1}" ]; then
            SIZE_EACH=`echo $line | awk -F" " '{ print $1 }'`
            TYPE_EACH=`echo $line | awk -F" " '{ s = ""; for (i = 2; i <= NF; i++) s = s $i " "; print s }'`
        else
            SIZE_EACH=`echo $line | awk -F":" '{ print $1 }'`
            TYPE_EACH=`echo $line | awk -F":" '{ print $2 }'`
        fi
        if [ "${TYPE_EACH_PRE}" != "" ]; then
            if [ "${TYPE_EACH}" != "${TYPE_EACH_PRE}" ]; then
                if [ "${SIZE_ALL_AS_TYPE}" -gt 0 ]; then
                    echo "${SIZE_ALL_AS_TYPE}:${TYPE_EACH_PRE}" >> "${outputfile}"   
                fi
                if [ "${outputfile}" = "${OUTPUTFILE2}" ]; then
                    SIZE_ALL=$((SIZE_ALL_AS_TYPE + SIZE_ALL))
                fi
                SIZE_ALL_AS_TYPE=0
            fi
        fi
        TYPE_EACH_PRE="${TYPE_EACH}"
        SIZE_ALL_AS_TYPE=$((SIZE_EACH + SIZE_ALL_AS_TYPE))
        cnt=$((cnt + 1))
    done < "${file}" 
}

LINES=$(wc -l "${DATA_FILEDIR_TYPE_SIZE_SORT}" | awk '{ print $1 }')

GOON=1
if [ "${LINES}" -gt 1 ]; then
    mashup_file_size "${DATA_FILEDIR_TYPE_SIZE_SORT}" "${OUTPUTFILE1}" 
    echo "${SIZE_ALL_AS_TYPE}: ${TYPE_EACH_PRE}" >> "${OUTPUTFILE1}"
    if [ ! -e "${OUTPUTFILE1}" ]; then
        echo "${SIZE_ALL_AS_TYPE}: ${TYPE_EACH_PRE}" > "${FILE_COMPLETE_FINAL}"
        GOON=0
    fi
    if [ "${GOON}" = 1 ]; then
        unlink "${DATA_FILEDIR_TYPE_SIZE_SORT}" 
        ## here we want to cut long type name
        awk -F"," '{ print $1 }' "${OUTPUTFILE1}" >  "${FILE_COMPLETE2}"
        unlink "${OUTPUTFILE1}" 
        sort -t : -k 2,2 "${FILE_COMPLETE2}" > "${FILE_COMPLETE2_1}"
        mashup_file_size "${FILE_COMPLETE2_1}" "${OUTPUTFILE2}" 
        echo "${SIZE_ALL_AS_TYPE}: ${TYPE_EACH_PRE}" >> "${OUTPUTFILE2}"
        SIZE_ALL=$((SIZE_ALL_AS_TYPE + SIZE_ALL))
        unlink "${FILE_COMPLETE2}"
        unlink "${FILE_COMPLETE2_1}"
        sort -t : -n -r "${OUTPUTFILE2}" > ${FILE_COMPLETE_FINAL}
        unlink "${OUTPUTFILE2}" 
        echo "" >> "${FILE_COMPLETE_FINAL}"
        echo "${SIZE_ALL}:All files" >> "${FILE_COMPLETE_FINAL}"
    fi
else
    mv "${DATA_FILEDIR_TYPE_SIZE_SORT}" "${FILE_COMPLETE_FINAL}"
fi

unlink "${FILE_BASE_EXISTS}"

echo ""
echo "Check result: ${FILE_COMPLETE_FINAL}"
