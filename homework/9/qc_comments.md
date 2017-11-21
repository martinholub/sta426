## Exercise 9
Author: Martin Holub

---

## Asssignement 1 - FASTQC
### Basic Statistics
  * no sequence flagged as poor quality (why?)
  * all sequences short (20bp, RNA-Seq)
  * expected GC content (52%)

### Perbase Sequence Quality
  * quality is in expected and good range
  * blue lines indicate mean
  * red lines indicate median
  * no variance (?)

### Per tile sequence quality
  * In acordance with previous, no variance, only good quality

### Per sequence quality scores
  * No bimodality, OK

### Per base sequence content
  * Biased composition at the end, FASTQC issues warning as difference between G C > 10% (_Is this a sign of an adaptor? But the sequences are only 20bp already. Also note the overepresented sequence._)

### Per sequence GC content
  * The experimental distribution follows the theroetical one

### Per Base N Content
  * 0% everywhere, ideal

### Sequence Length Distribution
  * Sequences are very short - RNA-Seq

### Duplicate Sequences
  * high percentage of sequences with high duplication level (_Partly probobably because they are very short. Probably also due to [PCR](https://www.nature.com/articles/nmeth.4407#methods) step?_)
  * _"In RNA-Seq libraries sequences from different transcripts will be present at wildly different levels in the starting population. In order to be able to observe lowly expressed transcripts it is therefore common to greatly over-sequence high expressed transcripts, and this will potentially create large set of duplicates." [FASTQC Documentation](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/3%20Analysis%20Modules/8%20Duplicate%20Sequences.html)_

### Overrepresented sequences
  *O ne found, but not a known contaminant. Lietrature search reveals that it is Nextera adapter.

### Adaptor content
  * Not analyed, reads too short

### Kmer Content
  * Multiple 7-mers with positionally bias reported

---
## Asssignement 2 - Salmon
QC check has been performed on RNA-Seq data from archived mouse brain samples. The raw data for the whole study (~110 GB zipped) can be downloaed [here](https://portals.broadinstitute.org/single_cell/study/dronc-seq-single-nucleus-rna-seq-on-mouse-archived-brain)

Here I closely approach presented in the lecture. I use RNA-Seq data that I eventually want to use for my project. As the raw files are rather big, and my NTB not so performant, I run the code on cluster. This is more or less just a mock example and I work only with 2 files. Eventually I would like to wrapt the code to a shell script such that I can process all files I have. I will later also use STAR for alignement.
