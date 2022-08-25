# Visualizing Variant Annotations
It's important to visualize your data, particularly when making decisions on how to hard filter it!

These scripts were generated: 
- to create tables and plots from VCF files using GATK and VCFtools for quality filtering and data summaries.
- for use on Easley HPC at Auburn University. Scripts should work with any SLURM scheduler. 


# Usage

`visualize_vcf.sh` generates tables used by the two `.R` scripts to generate plots. 

Edits to be made by users for `visualize_vcf.sh`:

- updating SLURM header
- adding variable information (paths, prefixes, etc.) 
- generating a working directory prior to running the script OR providing a data directory (dd) path
- deciding whether to downsample data for VCFtools (optional edit)
- deciding whether to use an output file name other than the default (optional edit)


Edits to be made by users for the two `.R` scripts:

- removing/editing `xlim` arguments (and changing the titles to match)
- changing `geom_vline` arguments from GATK recommended hard filtering cut-off values

**See script comments for more details**

# Acknowledgements 

The R scripts were built from work generated in 2016 by Dr. Stephen Sefick as a Postdoc in the lab of Dr. Laurie Stevison at Auburn University 
