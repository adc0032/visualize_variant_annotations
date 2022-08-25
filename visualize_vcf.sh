#! /bin/bash

#SBATCH -J visualize_variants
#SBATCH -t 05:00:00
#SBATCH -N 1
#SBATCH -n 15
#SBATCH --mem 50G
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=adc0032@auburn.edu

## %x = job name, %j = job id

module load gatk/4.1.9.0
module load bcftools/1.11
module load vcftools/0.1.17
module load samtools/1.11
module load R/4.0.3
source activate 

## Variables: data(dd), working(wd), and save(sd) directory; jobfile for array(jf) output prefix(out)
dd=
wd=
sd=
jf=
out=

## Commands

# Moving into wd, if exists; if not generate the directory and its parent directories. Also silence directory exists message
if [ -d ${wd} ]; then
        cd ${wd}
else
	mkdir -p ${wd}
fi
### If this directory does not already exist, with necessary data to generate output, use ${dd} instead of ${wd} when referring to where your data is store. Make sure to add that path in Variables above w/o the trailing slash.

####
## Visualize VCF annotations (GATK -> R) 
####

# Generating Site Level Table
echo "Generating GATK annotation tables if necessary..."
if [ ! -s "${wd}/${out}.sitetable" ]; then
gatk VariantsToTable -V ${wd}/${out}.vcf.gz -O ${out}.sitetable -F CHROM -F POS -F QUAL -F DP -F FS -F QD -F SOR -F MQ -F ReadPosRankSum -F BaseQRankSum -F MQRankSum
fi

# Generating Sample Level Table
if [ ! -s "${wd}/${out}.sampletable" ]; then
gatk VariantsToTable -V ${wd}/${out}.vcf.gz -O ${out}.sampletable -F CHROM -F POS -F QUAL -GF AD -GF DP -GF GQ -GF PL -GF RGQ -GF PL -GF SB -GF GT
fi
### This table is a MESS ^ the annotations are combined with sample id such that there is a column and annotation combination for each sample. VCFtools/BCFtools might be best to use for sample level metrics

####
## Visualize VCF annotations (VCFtools -> R)
####

# Randomdly sampling 10% of the variants. If you want to use all of your data points, comment out lines up to the echo statement of site level annotations
### You will also likely want to remove the "_sample10" suffix for clarity
### This script generates sample level metrics, but does not plot them
### Don't forget that if your vcf data was not already in your working directory, you will need to add the ${dd}/ as a prefix to vcf file name

echo "Calculating Number of Total Variants"
varnum=`bcftools view -H ${out}.vcf.gz|wc -l`
echo "${out}.vcf.gz has ${varnum} variants before filtering"
echo "Storing Vcftools outputs for ${out}.vcf.gz in ${wd}"
echo "Randomly sampling 10% of the variants for visualization and filtering decisions"

if [ ! -s "${wd}/${out}_sample10.vcf" ]; then
bcftools view ${out}.vcf.gz |vcfrandomsample -r 0.10 > ${wd}/${out}_sample10.vcf 
fi

if [ ! -s "${wd}/${out}_sample10.vcf.gz" ]; then
bgzip ${wd}/${out}_sample10.vcf
tabix ${wd}/${out}_sample10.vcf.gz
fi

echo "Generating Site Level annotations from VCFtools"
vcftools --gzvcf ${wd}/${out}_sample10.vcf.gz --freq2 --max-alleles 2 --out ${wd}
vcftools --gzvcf ${wd}/${out}_sample10.vcf.gz --site-mean-depth --out ${wd}
vcftools --gzvcf ${wd}/${out}_sample10.vcf.gz --site-quality --out ${wd}
vcftools --gzvcf ${wd}/${out}_sample10.vcf.gz --missing-site --out ${wd}

echo "Generating Sample Level annotations from VCFtools"
vcftools --gzvcf ${wd}/${out}_sample10.vcf.gz --het --out ${wd}
vcftools --gzvcf ${wd}/${out}_sample10.vcf.gz --missing-indv --out ${wd}
vcftools --gzvcf ${wd}/${out}_sample10.vcf.gz --depth --out ${wd}

####
## Plotting GATK & VCFtools annotations (R)
####

GATKtab="${wd}/${out}.sitetable"

VCFdepth="${wd}/${out}.ldepth"
VCFfreq="${wd}/${out}.frq"
VCFmiss="${wd}/${out}.lmiss"
VCFqual="${wd}/${out}.lqual"

# Rscript uses tables provided as arguments; maintain order of VCFtool variables or titles will be incorrect in plots
### Adding an additional argument (a second or fifth argument to the commands below) will control the output PDF file name; see Rscript for details on the default output name
### Don't forget to update where the scripts can be found! I keep all of my scripts in a folder at my root directory, so these are oriented at root right now. 
Rscript ~/visualize_gatk_variants.R ${GATKtab} 
Rscript ~/visualize_vcf_variants.R ${VCFdepth} ${VCFfreq} ${VCFmiss} ${VCFqual}

echo "Annotation plots are complete. See ${wd} for final files"


