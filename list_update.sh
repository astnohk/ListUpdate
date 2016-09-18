#!/bin/sh

#----------------------------------------------------------------
# Config

SRC_DIR='/home/users/pictures'

#---------------------------------------------------------------

SRC_DIR_REG=`echo ${SRC_DIR} | sed -e 's/\//\\\\\\//g'`
DST_DIR_NAME='Update_List'
DST_DIR="${SRC_DIR}/${DST_DIR_NAME}"
DATE=`date +%Y_%m_%d`
YEAR=`echo ${DATE} | cut -d_ -f 1`
MONTH=`echo ${DATE} | cut -d_ -f 2`
DAY=`echo ${DATE} | cut -d_ -f 3`


# Check presence of destination directory
cd ${SRC_DIR}
if [ ! -d ${DST_DIR_NAME} ]; then
	echo "make destination directory"
	mkdir ${DST_DIR_NAME}
fi

# Change directory to $DST_DIR
cd ${DST_DIR}

if [ ! -f list_current ]; then
	echo "make list_current as null file"
	touch list_current
fi

# Get diff of filelist
(cd ${SRC_DIR}; find -type f -exec stat --format="%Z %n" {} +) | grep -v "${DST_DIR_NAME}" | sort -k 1 -t' ' > list_new
LIST=`diff -u list_current list_new | egrep "^\+" | egrep -v "\+\+" | sed -e 's/[^ ]\+[ ]//' | sed -e 's/ /|/g' | sed -e 's/\.//'`

# Create diff directory
NUM=`echo ${LIST} | sed -e 's/[:space:]//g' | wc -w`
if [ ${NUM} -ne 0 ]; then
	for NAME in ${LIST}
	do
		TRUENAME=`echo ${NAME} | sed -e 's/|/ /g'`
		TMP_DATE=`stat --format="%Z" ${SRC_DIR}${TRUENAME}`
		DIR_DATE=`date --date="@${TMP_DATE}" +%Y/%m/%d`
		BASENAME=`basename ${NAME} | sed -e 's/|/ /g'`
		DIR=`echo ${TRUENAME} | sed -e "s/\\/${BASENAME}//"`
		# Make directory
		echo "mkdir -p ${DIR_DATE}"
		mkdir -p ${DST_DIR}/${DIR_DATE}
		echo "        mkdir -p ${DIR}"
		mkdir -p "${DST_DIR}/${DIR_DATE}${DIR}"
		echo "                make symbolic link to ${TRUENAME}"
		ln -sf "${SRC_DIR}${TRUENAME}" "${DST_DIR}/${DIR_DATE}${DIR}/${BASENAME}"
	done
fi

# Update List
mv list_new list_current

