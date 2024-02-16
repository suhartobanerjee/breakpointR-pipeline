# Imports 
library(GenomicRanges)
library(data.table)
library(ggplot2)
library(ggpubr)
library(stringr)
library(purrr)

# Sourcing methods file
source("workflow/scripts/plotting/methods.R")


args <- commandArgs(trailingOnly = T)

if(length(args) < 1 | length(args) > 4) {
    stop("Usage: Rscript bp_counts_violin.R bp_summary cell_list chr_to_exclude plot.pdf")
}


# Reading in the breakpoint file
print(str_glue("len of args = {length(args)}"))
brk_file <- fread(args[1])
cell_list <- fread(args[2])
chr_to_exclude_args <- args[3]
out_file <- args[4]
cell_list


# Pre-processing the input args
ProcFile(brk_file)
chr_to_exclude <- str_split(chr_to_exclude_args, ",")[[1]]
cell_list <- cell_list[prediction == 1]


# Counting the break points per cell
bp_count <- brk_file[!chrom %in% chr_to_exclude,
                     .N,
                     by = .(cell_name, sample)]
setnames(
    bp_count,
    "N",
    "count"
)
bp_count


# adding cells with no bps called
test <- map_vec(cell_list$cell, function(x) sum(str_detect(brk_file$filenames, x)))
excluded_cells_vec <- cell_list[which(test == 0), cell]
excluded_cells_vec

if(length(excluded_cells_vec) > 0) {

    excluded_cells <- data.table(cell_name = excluded_cells_vec,
                                 sample = bp_count[1, sample],
                                 count = 0
    )
    bp_count <- rbind(bp_count, excluded_cells)
}


pdf(out_file)
# plotting the bps
ggplot(data = bp_count,
       aes(x = sample,
           y = count
       )
) +
    geom_violin() +
    stat_summary(fun=mean,
                 colour="darkred",
                 geom="crossbar", 
                 width = 0.5
    ) + 
    geom_point(position = position_jitter(w = 0.1, h = 0)) +
    labs(x = "sample", y = "count") +
    ggtitle("All Breakpoints")

dev.off()





