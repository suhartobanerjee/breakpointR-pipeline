# Imports 
library(GenomicRanges)
library(data.table)
library(ggplot2)
library(ggpubr)
library(stringr)

# Sourcing methods file
source("workflow/scripts/plotting/methods.R")


args <- commandArgs(trailingOnly = T)

if(length(args) < 1 | length(args) > 5) {
    stop("Usage: Rscript bp_chr_counts_violin.R bp_summary chr_to_exclude condition_dt(optional) chr_len plot.pdf")
}


# Reading in the breakpoint file
print(str_glue("len of args = {length(args)}"))
brk_file <- fread(args[1])
chr_to_exclude_args <- args[2]
chr_to_exclude <- str_split(chr_to_exclude_args, ",")[[1]]

chr_len_dt <- fread(args[4], header = F)
setnames(
    chr_len_dt,
    c("V1", "V2"),
    c("chrom", "chr_len")
)

out_file <- args[5]

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


brk_file <- chr_len_dt[brk_file, on = "chrom"]


# Counting the break points per cell
bp_count <- brk_file[!chrom %in% chr_to_exclude,
                     .N / chr_len * 1e6,
                     by = .(cell_name, condition, chrom)]
bp_count


pdf(out_file,
    width = 20,
    height = 10
)
# plotting the bps
if(exists("condition_dt")) {

    ggplot(data = bp_count,
           aes(x = factor(chrom, levels = chr_len_dt$chrom),
               y = V1,
               fill = condition
           )
    ) +
        geom_violin() +
#         stat_summary(fun=mean,
#                      colour="darkred",
#                      geom="crossbar", 
#                      width = 0.5
#         ) + 
        geom_point(position = "jitter") +
        stat_compare_means() +
        labs(x = "chromosomes", y = "count / MB") +
        ggtitle("All Breakpoints")
} else {

    ggplot(data = bp_count,
           aes(x = factor(chrom, levels = chr_len_dt$chrom),
               y = V1
           )
    ) +
        geom_violin() +
#         stat_summary(fun=mean,
#                      colour="darkred",
#                      geom="crossbar", 
#                      width = 0.5
#         ) + 
        geom_point(position = "jitter") +
        labs(x = "chromosomes", y = "count / MB") +
        ggtitle("All Breakpoints")
}

dev.off()





