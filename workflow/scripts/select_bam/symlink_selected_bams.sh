#!/bin/bash


#rsync -avhPI
# copying the labels.tsv to output_bam dir
cp $1 $3/.

awk '$2 == 1 {print $1}' $1 \
    | parallel -j $(nproc) -I file ln -s $2/file $3/file
