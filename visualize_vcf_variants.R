#!/usr/bin/env Rscript
# Check for command line arguments
args = commandArgs(trailingOnly=TRUE)

# Error without the 4 input file arguments (which should be the site-level tables generated with vcftools in visualize_vcf.sh)
# test if there is at least four arguments: if not, return an error
if (length(args)<4) {
  stop("At least four arguments after the script are required (input files - site tables from vcftools [*.ldepth,*.freq,*.lmiss,*.lqual]).n", call.=FALSE)
} else if (length(args)==4) {
  # default output file
  args[5] = paste(gsub(" ", "_", date()), "vcf_plots.pdf", sep = "_")
}


# load packages 
# vector of packages
packs <- c("tidyverse", "grid", "gtable", "gridExtra", )
# loop through and check for package, install if not present, and load library
for (pack in packs){
if (!require(pack)) install.packages('pack')
library(pack)
}



# VCFtools Annotations
## It may be helpful to comment out/remove the xlim argument the first time you plot your data - these values for xlims were chosen to improve visualization based on my data

# Generate density plots for site level metrics obtained via VCFtools
var_depth <- read_delim(args[1], delim = "\t", col_names = c("chr", "pos", "mean_depth", "var_depth"), skip = 1)
vd_plot <- ggplot(var_depth, aes(mean_depth)) + geom_density(fill = "forestgreen", colour = "black", alpha = 0.3) + theme_light() + xlim(0,100)
vd_plot <- vd_plot + ggtitle("Site Depth (Truncated @ 100)")
summary(var_depth$mean_depth)

var_freq <- read_delim(args[2], delim = "\t", col_names = c("chr", "pos", "nalleles", "nchr", "a1", "a2"), skip = 1)
var_freq$maf <- var_freq %>% select(a1, a2) %>% apply(1, function(z) min(z))
vf_plot <- ggplot(var_freq, aes(maf)) + geom_density(fill = "forestgreen", colour = "black", alpha = 0.3) + theme_light()
vf_plot <- vf_plot + ggtitle("MAF")
summary(var_freq$maf)

var_miss <- read_delim(args[3],  delim = "\t",col_names = c("chr", "pos", "nchr", "nfiltered", "nmiss", "fmiss"), skip = 1)
vm_plot <-ggplot(var_miss, aes(fmiss)) + geom_density(fill = "forestgreen", colour = "black", alpha = 0.3) + theme_light()
vm_plot <- vm_plot + ggtitle("Site Missingness")
summary(var_miss$fmiss)

var_qual <- read_delim(args[4], delim = "\t", col_names = c("chr", "pos", "qual"), skip = 1)
vq_plot <- ggplot(var_qual, aes(qual)) + geom_density(fill = "forestgreen", colour = "black", alpha = 0.3) + theme_light()
vq_plot <- vq_plot +xlim(0,1000)+ ggtitle("Site Quality (Truncated @ 1,000)")



# Generate PDF output of plots
pdf(args[5])
vq_plot
vd_plot
cat("Summary Stats for Variant Depth\n", summary(var_depth$mean_depth), "\n")
vm_plot
cat("Summary Stats for Variant Missingness\n", summary(var_miss$fmiss), "\n")
vf_plot
cat("Summary Stats for Allele Frequencey\n", summary(var_freq$maf), "\n")
dev.off()


