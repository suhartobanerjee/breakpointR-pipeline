library(tidyverse)
library(dplyr)
library(gtools)
library(ggplot2)
library(ggside)
library(stringr)


args <- commandArgs(trailingOnly = T)

file=args[1]
chr_len <- read.table(args[2], sep = "\t", header = T)


bp=read.table(file, header = T)
bp


cellID <- str_split_i(bp$filenames, pattern = "\\.", i = 1) |>
    str_extract(string = _, regex("i\\d{3}"))
sample_name <- str_extract(bp$filenames, regex("P\\d{4}"))

bp <- cbind(bp,sample_name)
bp <- cbind(bp,cellID)
bp$chr <- gsub("^.{0,3}", "", bp$seqnames) #remove "chr" from chomosome names


bp <- bp %>% select(chr,start,end,sample_name,cellID)

# ##### Plotting bpXcell ##### 
# 
# d2p <- bp %>% group_by(cellID) %>% mutate(count = n()) %>% select(cellID,count)
# d2p <-unique(d2p)
# d2p$count<- as.integer(d2p$count)
# 
# p_bpxcell <- ggplot(d2p, aes(x=reorder(cellID,count), y=count))+
#   geom_bar(stat = "identity", fill="#e04646", alpha=.6, width=.7)+
#   xlab("Cell")+
#   ylab("BP number")+
#   coord_flip()+
#   theme_minimal()
# 
# p_bpxcell
# 
# ggsave("bpxcell.png", plot = p_bpxcell, device = "png", path = outdir)
# 
# ###### Plotting bpXchr, stratified by cell #####
# 
# len_file <- ("/data/gpfs-1/users/adapont_m/work/breakpointR/chr_lenght.csv")
# chr_len <- read.table(len_file, sep = "\t",col.names = c("chr","chr_len"))
# 
# bpxchrxcell <- bp %>% group_by(chr,cellID) %>% mutate(count = n()) %>% select(chr,cellID,count)
# bpxchrxcell <-unique(bpxchrxcell)
# bpxchrxcell$count<- as.integer(bpxchrxcell$count)
# bpxchrxcell <- merge(bpxchrxcell,chr_len)
# bpxchrxcell <- bpxchrxcell[mixedorder(bpxchrxcell$chr), ]
# bpxchrxcell$chr <- factor(bpxchrxcell$chr, levels = unique(bpxchrxcell$chr), ordered = T)
# bpxchrxcell <- bpxchrxcell %>% mutate(count_nor=(count/chr_len)*1000000)
# 
# p_bpxchrxcell <- ggplot(bpxchrxcell, aes(x=chr, y=count_nor*100)) +
#   geom_dotplot(binaxis='y', stackdir='center', dotsize = 0.08, color=NA, fill="#003a70", alpha=0.5)+
#   geom_boxplot(width=0.08, color="#003a70", alpha=0.2, linewidth=0.2) +
#   geom_violin(width=1.2, fill="#81ceff", color="#81ceff",  linewidth=0.2, alpha=0.5) +
#   scale_y_continuous(breaks = seq(0, max(bpxchrxcell$count), by = 2))+
#   theme_minimal() +
#   xlab("Chr") +
#   ylab("BP")
# 
# p_bpxchrxcell
# 
# ggsave("bpxchrxcell_count.png", plot = p_bpxchrxcell, device = "png", path = outdir)
# 
# 
# ##### Plotting bpSize Distr #####
# 
# bpSize <- bp %>% mutate(size=(end-start)/1000000)
# bpSize <- bpSize[mixedorder(bpSize$chr), ]
# bpSize$chr <- factor(bpSize$chr, levels = unique(bpSize$chr), ordered = T)
# 
# p_bpsize <- ggplot(bpSize, aes(x=size))+
#   geom_histogram(aes(y=after_stat(count)),fill="#8db9ca",alpha=0.5, position="identity",binwidth = 0.3, show.legend = FALSE)+
#   theme_minimal()
# 
# p_bpsize
# 
# ggsave("bpsize.png", plot = p_bpsize, device = "png", path = outdir)

##### NEW COOL PLOT ####
bpSize <- bp %>% mutate(size=(end-start)/1000000)
bpSize <- bpSize[mixedorder(bpSize$chr), ]
bpSize$chr <- factor(bpSize$chr, levels = unique(bpSize$chr), ordered = T)


d2p <- bp %>% group_by(cellID) %>% mutate(count = n()) %>% select(cellID,count)
d2p <-unique(d2p)
d2p$count<- as.integer(d2p$count)


bpSize <- merge(bpSize,chr_len)
bpSize <- bpSize %>% mutate(rel_start=width-start) %>% mutate(stand_start=start/1000000) %>% 
  mutate(chr_len_MB=width/1000000)
bpSize <- merge(bpSize,d2p)

bpSize <- bpSize[mixedorder(bpSize$chr), ]
bpSize$chr <- factor(bpSize$chr, levels = unique(bpSize$chr), ordered = T)

bpSize$chr_start <- 0

pdf(
    file = args[3],
    width = 40,
    height = 20
)
ggplot(bpSize, aes(x=stand_start, y=reorder(cellID,count))) +
  geom_point(alpha=0.5, color="#005670") +
  geom_point(bpSize, mapping = aes(x=chr_len_MB, y=reorder(cellID,count)), color= NA, fill=NA)+
  geom_point(bpSize, mapping = aes(x=chr_start, y=reorder(cellID,count)), color= NA, fill=NA)+
  scale_x_continuous(breaks = seq(0,250,50)) +
  geom_xsidehistogram(binwidth = 0.5, alpha= 0.5,size=0.5, color="#005670", fill="#005670") +
  scale_xsidey_continuous()+
  geom_ysidebar(width = 0.5,color="#00205b",size=0.05, fill="#005670", alpha=0.5)+
  facet_grid(~chr, scales = "free_x", space="free_x")+
  #force_panelsizes()
  theme_bw()+
  theme(axis.text.x = element_text(size=6, angle=45))+
  xlab(NULL)+
  ylab(NULL)+
  ggside(collapse="y")

dev.off()



# ggsave(args[3], device = "pdf", width = 40, height = 20)
