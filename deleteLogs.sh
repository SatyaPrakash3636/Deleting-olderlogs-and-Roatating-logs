#!/bin/bash

SCRIPT_DIR=`pwd`
DIR_PATH="/logs/tiblog"
FILE_NAME_1="emsdata.log.*"
FILE_NAME_2="startEMS.out.*"
FILE_NAME_3="startEMS.out"
LOG_FILE="$SCRIPT_DIR/deletedFiles.log"
ERROR_LOG="$SCRIPT_DIR/delFilesError.log"

{
echo >> $ERROR_LOG
echo "#########################################################" >> $ERROR_LOG
echo `date` >> $ERROR_LOG
echo "#########################################################" >> $ERROR_LOG
echo >> $LOG_FILE
echo "*****************************************************************************" >> $LOG_FILE
echo "`date` : Removing 60 days old emsdata.log.* files" >> $LOG_FILE
echo "*****************************************************************************" >> $LOG_FILE
echo >> $LOG_FILE
find $DIR_PATH -type f -name $FILE_NAME_1 -mtime +60 -exec ls -ltr -- {} \; \
-exec rm -rf -- {} \; \
-exec printf "Removed ‘%s’\n" {} \; >> $LOG_FILE
echo >> $LOG_FILE
echo "*****************************************************************************" >> $LOG_FILE
echo "`date` : Removing 60 days old startEMS.out.* files" >> $LOG_FILE
echo "*****************************************************************************" >> $LOG_FILE
echo >> $LOG_FILE
find $DIR_PATH -type f -name $FILE_NAME_2 -mtime +60 -exec ls -ltr -- {} \; \
-exec rm -rf -- {} \; \
-exec printf "Removed ‘%s’\n" {} \; >> $LOG_FILE
echo >> $LOG_FILE

echo "*****************************************************************************" >> $LOG_FILE
echo "`date` : Rotating startEMS.out log files" >> $LOG_FILE
echo "*****************************************************************************" >> $LOG_FILE

find $DIR_PATH -type f -name $FILE_NAME_3 -exec du -sk {} \; > $SCRIPT_DIR/size.txt

i=1
lines=`wc -l $SCRIPT_DIR/size.txt | cut -d' ' -f1`

while [ $i -le $lines ]
do

size=`cat size.txt | sed -n "$i p" | cut -f 1`
file=`cat size.txt | sed -n "$i p" | cut -f 2`

if [ $size -ge 50000 ]
then
   echo "`date` : $file is greater than or equal to 50 M, the size is $size K. Rotating the file" >> $LOG_FILE
   cp $file $file.$(date +%d.%m.%y_%T)
   > $file
if [ $? -eq 0 ]
then
echo "`date` :: SUCCESS - $file has been Rotated" >> $LOG_FILE
echo >> $LOG_FILE

else
echo "`date` :: ERROR - $file has not been Rotated" >> $LOG_FILE
fi

fi
   (( i=i+1 ))
done
} 2>> $ERROR_LOG
