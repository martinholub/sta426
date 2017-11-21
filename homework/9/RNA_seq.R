# Exercise 9 - Sta426
# Author: Martin Holub
# Date : 21/11/2017

## Notes
# - write a shell script later

## Useful snippets
# module load java
# module load new gcc/4.8.2 r/3.4.0
# module load gcc/4.8.2 star/2.4.2a
# bsub -W 120 -n 8 -R "rusage[mem=4096]"
# wget "ftp://ftp.ensembl.org/pub/release-90/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.alt.fa.gz"
# wget "ftp://ftp.ensembl.org/pub/release-90/gtf/mus_musculus/Mus_musculus.GRCm38.90.gtf.gz"
# wget "ftp://ftp.ensembl.org/pub/release-90/fasta/mus_musculus/cdna/Mus_musculus.GRCm38.cdna.all.fa.gz"
# wget "ftp://ftp.ensembl.org/pub/release-90/fasta/mus_musculus/ncrna/Mus_musculus.GRCm38.ncrna.fa.gz"
# curl "https://portals.broadinstitute.org/single_cell/bulk_data/dronc-seq-single-nucleus-rna-seq-on-mouse-archived-brain/all/594941" -o cfg.txt
# curl -K cfg.txt
------------------------
  

# Prepare paths
data_dir <- "/cluster/scratch/mholub"
output_dir <- "/cluster/home/mholub/output"
reference_dir <- "/cluster/scratch/mholub/reference"
path_to_fastqc <- "/cluster/home/mholub/Software/FastQC/fastqc"
# path_to_hisat2_build <- "/cluster/home/mholub/Software/hisat2-2.1.0/hisat2-build"
# path_to_hisat2 <- "/cluster/home/mholub/Software/hisat2-2.1.0/hisat2"
# path_to_samtools <- "/cluster/home/mholub/Software/samtools/bin/samtools"
path_to_salmon <- "/cluster/home/mholub/Software/Salmon-0.8.2_linux_x86_64/bin/salmon"


# Find files
fastq.files <- list.files(path = data_dir, pattern = ".fastq.gz$", full.names = TRUE)
(cmd <- sprintf("head %s", fastq.files[1]))
system(cmd)

# Do quality control on a sample file
system(sprintf("mkdir -p %s/qc", output_dir))
(cmd <- sprintf("%s -o %s/qc %s",  path_to_fastqc, output_dir, fastq.files[1]))
system(cmd)

# Merge coding and noncoding RNA reference files
(cmd <- sprintf("cat %s %s > %s",
                paste0(reference_dir, "/Mus_musculus.GRCm38.cdna.all.fa.gz"), 
                paste0(reference_dir, "/Mus_musculus.GRCm38.ncrna.fa.gz"), 
                paste0(reference_dir, "/Mus_musculus.GRCm38.cdna.ncrna.fa.gz")))
system(cmd)

## Index reference transcriptome for use with Salmon
(cmd <- sprintf("%s index -t %s -i %s -p 4 -k 20",
                path_to_salmon,
                paste0(reference_dir, "/Mus_musculus.GRCm38.cdna.ncrna.fa.gz"),
                paste0(output_dir, "/Mus_musculus.GRCm38.cdna.ncrna.sidx")))
system(cmd)

# Quantify transcript abundances
out_f <- gsub("\\..*", "", gsub("(.*)/([^\\.]+[\\.])","\\2", fastq.files[1]))
salmon_res <- sprintf("%s/%s",output_dir, out_f)
(cmd <- sprintf("%s quant -i %s -l A -r %s -o %s -p 8",
                path_to_salmon,
                paste0(output_dir, "/Mus_musculus.GRCm38.cdna.ncrna.sidx"),
                fastq.files[1],
                salmon_res))
system(cmd)

# Inspect Result
system(sprintf("head %s/quant.sf", salmon_res))