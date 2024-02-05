#!/bin/bash


# copying the labels.tsv to output_bam dir
cp $1 $3/.

awk '$2 == 1 {print $1}' $1 \
    | parallel -j $(nproc) -I file cp $2/file $3/file
