#!/bin/bash
#
#SBATCH -J breakpointR
#SBATCH -o ./logs/%10x_%j.out
#SBATCH -e ./logs/%10x_%j.out
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --time=2-00:00
#SBATCH --mem-per-cpu=4G

# INPUT: CL option 
# $1 should be organism: {'human'/'mouse'} 
# $2 should be bam dir, 
# $3 output dir, 
# $4 binsize

# startup
echo "launching script at $(date)"
echo "SLURM_JOB_ID = $SLURM_JOB_ID, SLURM_JOB_NAME = $SLURM_JOB_NAME"

# moving other log file to archive
find ./logs -type f -maxdepth 1 -not -name *$SLURM_JOB_ID* -exec mv {} ./logs/archive/. \;
echo "previous logs moved to archive"

# activate conda env
source ~/.bashrc
conda activate breakpointR

# Test input dir/files exist
[ ! -d $2 ] && { "ERROR: input bam dir $2 does not exist" ; exit ; }
nbam=$(ls $2/*bam | wc -l)
[ ! $nbam -ge 1 ] && { "ERROR: no bam files were found in $2" ; exit ; }

# set a default value of binsize
# -z checks if $4 is empty
# if [ -z "$4" ]; then
#     BINSIZE=3000000
# else
#     BINSIZE=$4
# fi

echo "input bam dir set to: $2"
echo "output will be written to: $3"
echo "using binsize $BINSIZE"


Rscript ./$1/exec/breakpointR_exec.R \
	$2 \
	$3 \
	${4:-3000000} \
	$(nproc)

