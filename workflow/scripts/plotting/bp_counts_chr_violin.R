# Imports 
library(GenomicRanges)
library(data.table)
library(ggplot2)
library(ggpubr)
library(stringr)
library(purrr)
library(gtools)

# Sourcing methods file
source("workflow/scripts/plotting/methods.R")


args <- commandArgs(trailingOnly = T)

if(length(args) < 1 | length(args) > 4) {
    stop("Usage: Rscript bp_chr_counts_violin.R bp_summary chr_to_exclude chr_len plot.pdf")
}


# Reading in the breakpoint file
print(str_glue("len of args = {length(args)}"))
brk_file <- fread(args[1])
chr_to_exclude_args <- args[2]
chr_len_dt <- fread(args[3], header = F)
out_file <- args[4]


# Pre-processing the input args
ProcFile(brk_file)
chr_to_exclude <- str_split(chr_to_exclude_args, ",")[[1]]
setnames(
    chr_len_dt,
    c("V1", "V2"),
    c("chrom", "chr_len")
)
brk_file <- chr_len_dt[brk_file, on = "chrom"]


# Counting the break points per cell
bp_count <- brk_file[!chrom %in% chr_to_exclude,
                     .N / chr_len * 1e6,
                     by = .(cell_name, sample, chrom)]
setnames(
    bp_count,
    "V1",
    "count"
)
bp_count


# taking the called chrs only
all_chr <- chr_len_dt[chrom %in% unique(brk_file$chrom), chrom]

# func to return the non called chr for each cell_name and sample
get_non_called_chr <- function(dt_slice) {

    return(all_chr[!all_chr %in% dt_slice[, chrom]])
}
excluded_chrs <- bp_count[, get_non_called_chr(.SD), by = .(cell_name, sample)]
setnames(
    excluded_chrs,
    "V1",
    "chrom"
)
excluded_chrs[, count := 0]

plot_dt <- rbind(bp_count, excluded_chrs)
chr_len_dt


pdf(out_file,
    width = 20,
    height = 15
)

ggplot(data = plot_dt,
       aes(x = factor(chrom, levels = mixedsort(unique(chrom))),
           y = count
       )
) +
    geom_violin() +
    stat_summary(fun=mean,
                 colour="darkred",
                 geom="crossbar", 
                 width = 0.5
    ) + 
    geom_point(position = position_jitter(w = 0.3, h = 0)) +
    labs(x = "chromosomes", y = "count / MB") +
    ggtitle("All Breakpoints")

dev.off()

