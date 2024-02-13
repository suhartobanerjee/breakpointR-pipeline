library(breakpointR)
library(doParallel)
library(parallel)
## Get some example files

args = commandArgs(trailingOnly=T)
# datafolder = args[1] 
# outputfolder = args[2]
# binsize= as.numeric(args[3])
# ncores = as.numeric(args[4])


# set chromosomes acc to species
if (args[15] == "human") {
    chrs <- paste0("chr", c(1:22, "X", "Y"))
} else if (args[15] == "mouse") {
    chrs <- paste0("chr", c(1:19, "X", "Y"))
}


print(paste("R: datafolder:", args[1]))
print(paste("R: outputfolder:", args[2]))
print(paste("R: binsize:", args[8]))
print(paste("R: ncores:", args[4]))
print(paste("R: chromosomes:", chrs))

## Run breakpointR
print("starting")
breakpointr(inputfolder = args[1],
            outputfolder = args[2],
            pairedEndReads = as.logical(args[3]),
            numCPU = as.numeric(args[4]),
            minReads = as.numeric(args[5]),
            maskRegions = args[6],
            reuse.existing.files = as.logical(args[7]),
            windowsize = as.numeric(args[8]),
            background = as.numeric(args[9]),
            binMethod = args[10],
            pair2frgm = as.logical(args[11]),
            min.mapq = as.numeric(args[12]),
            callHotSpots = as.logical(args[13]),
            filtAlt = as.logical(args[14]),
            chromosomes = chrs
)

# export wc_regions (useful for StrandPhaseR)
exportRegions(datapath=file.path(args[2],"data"), 
	file = file.path(args[2],"wc_regions.txt"), collapseInversions=F, minRegionSize= 5000000, state = 'wc')

print("R: breakpoint complete")
