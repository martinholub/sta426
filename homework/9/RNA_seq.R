# Exercise 9 - Sta426
# Author: Martin Holub
# Date : 21/11/2017
------------------------
## Notes
# - write a shell script later
# - I do first two parts of assignement

## Useful snippets
# module load java
# module load new gcc/4.8.2 r/3.4.0
# module load gcc/4.8.2 star/2.4.2a
# bsub <script_file> -W 120 -n 8 -R "rusage[mem=4096]"
# bsub W 120 -n 8 -R "rusage[mem=4096]" "R --vanilla --slave < RNA_seq.R > result.out"
#
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
(cmd <- sprintf("%s index -t %s -i %s -p 4 -k 19", 
                path_to_salmon,
                paste0(reference_dir, "/Mus_musculus.GRCm38.cdna.ncrna.fa.gz"),
                paste0(output_dir, "/Mus_musculus.GRCm38.cdna.ncrna.sidx")))
system(cmd)

# Quantify transcript abundances
# Library is ISF
out_f <- gsub("\\..*", "", gsub("(.*)/([^\\.]+[\\.])","\\2", fastq.files[1]))
salmon_res <- sprintf("%s/%s",output_dir, out_f)
(cmd <- sprintf(
                #"%s quant -i %s -l A -r %s -o %s -p 8",
                "%s quant -i %s -l A -1 %s -2 %s -o %s -p 4 -k 19", #we have paired reads
                path_to_salmon,
                paste0(output_dir, "/Mus_musculus.GRCm38.cdna.ncrna.sidx"),
                fastq.files[1],
                fastq.files[2],
                salmon_res))
system(cmd)

# Inspect Result
system(sprintf("head %s/quant.sf", salmon_res))

## Read the fasta file in R using a function from the Biostrings package
cdna.ncrna <- Biostrings::readDNAStringSet(paste0(reference_dir, "/Mus_musculus.GRCm38.cdna.ncrna.fa.gz"))

## Go through the sequence names and extract the required information
tx2gene <- data.frame(t(sapply(names(cdna.ncrna), function(nm) {
  tmp <- strsplit(nm, " ")[[1]]
  tx <- tmp[1]
  gene <- gsub("gene:", "", tmp[grep("^gene:", tmp)])
  c(tx = tx, gene = gene)
})), stringsAsFactors = FALSE)

rownames(tx2gene) <- NULL
head(tx2gene)

# Import abundance estimates into R and summarize on gene level
files <- paste0(salmon_res, "/quant.sf")
names(files) <- out_f
files

txi <- tximport::tximport(files = files, type = "salmon", tx2gene = tx2gene, dropInfReps = TRUE)
head(txi$counts)

# Show an example of a figure
df = density(log2(txi$counts), bw ="SJ", kernel= "gauss", na.rm = TRUE)
png(filename = sprintf("%s/plot_densities_paired.png", output_dir))
plot(df)
dev.off()
