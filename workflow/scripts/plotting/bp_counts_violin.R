# Imports 
library(GenomicRanges)
library(data.table)
library(ggplot2)
library(ggpubr)
library(stringr)

# Sourcing methods file
source("workflow/scripts/plotting/methods.R")


args <- commandArgs(trailingOnly = T)

if(length(args) < 1 | length(args) > 4) {
    stop("Usage: Rscript bp_counts_violin.R bp_summary chr_to_exclude condition_dt(optional) plot.pdf")
}


# Reading in the breakpoint file
print(str_glue("len of args = {length(args)}"))
brk_file <- fread(args[1])
chr_to_exclude_args <- args[2]
chr_to_exclude <- str_split(chr_to_exclude_args, ",")[[1]]
out_file <- args[4]


# when condition is provided
if(args[3] != "") {
    condition_dt <- fread(args[3])

    # Pre-processing the input
    ProcFile(brk_file, condition_dt)

    compare_conditions <- TRUE

} else {

    # Pre-processing the input
    ProcFile(brk_file)

    compare_conditions <- FALSE
}




# Counting the break points per cell
bp_count <- brk_file[!chrom %in% chr_to_exclude,
                     .N,
                     by = .(cell_name, condition)]
setnames(
    bp_count,
    "N",
    "count"
)
bp_count


pdf(out_file)
# plotting the bps
if(exists("condition_dt")) {

    ggplot(data = bp_count,
           aes(x = condition,
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
        stat_compare_means() +
        labs(y = "count") +
        ggtitle("All Breakpoints")
} else {

    ggplot(data = bp_count,
           aes(x = condition,
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
}

dev.off()





