#!/bin/bash

# $1: bam folder
# $2: species name file
# $3: chr lengths tsv


if [[ $(ls $1/*.bam | head -n1 | xargs -I bam samtools view -H bam | grep 'hg') ]]; then
    echo "human" > $2
fi
if [[ $(ls $1/*.bam | head -n1 | xargs -I bam samtools view -H bam | grep 'mm') ]]; then
    echo "mouse" > $2
fi


ls $1/*.bam \
    | head -n1 \
    | xargs -I bam samtools view -H bam \
    | awk '/chr([[:digit:]]{1,2}|X|Y)\t/ \
    {gsub(/SN:/, "", $2); gsub(/LN:/, "", $3);  print $2"\t"$3}' > $3


