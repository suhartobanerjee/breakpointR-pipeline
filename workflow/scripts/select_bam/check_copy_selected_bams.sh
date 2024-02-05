#!/bin/bash

# Usage: ./check_files_exist_parallel.sh file_list.txt /path/to/dir

FILE_LIST=$1
DIR=$(dirname $FILE_LIST)


export DIR

check_file() {
    file=$1
    echo $file
    if [ ! -f "$DIR/$file" ]; then
    echo "File not found: $DIR/$file"
    return 1  # Return code 1 will be interpreted by parallel as an error
    fi
}
export -f check_file

awk '$2 == 1 {print $1}' $FILE_LIST \
    | parallel -I bam -j $(nproc) check_file bam

if [ $? -ne 0 ]; then
  echo "One or more files were not found."
  exit 1
else
  echo "All files found."
fi

