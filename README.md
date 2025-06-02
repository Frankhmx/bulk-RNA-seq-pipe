# Bulk RNA-seq Preprocessing Pipeline

A Snakemake pipeline for preprocessing bulk RNA-seq data from raw FASTQ files to gene expression counts.

## Overview

This pipeline processes paired-end RNA-seq data through quality control, alignment, and quantification steps. It's specifically designed for *Drosophila melanogaster* (dm6) data but can be adapted for other organisms.

## Pipeline Steps

1. **Quality Control & Trimming** - Remove low-quality reads and adapters using fastp
2. **Alignment** - Map reads to reference genome using HISAT2
3. **BAM Processing** - Convert SAM to sorted BAM files with indexing
4. **Quantification** - Count reads per gene using featureCounts

## Requirements

### Software Dependencies
- [Snakemake](https://snakemake.readthedocs.io/) (≥6.0)
- [fastp](https://github.com/OpenGene/fastp)
- [HISAT2](http://daehwankimlab.github.io/hisat2/)
- [SAMtools](http://www.htslib.org/)
- [featureCounts](http://subread.sourceforge.net/) (from Subread package)

### Reference Data
- HISAT2 index for dm6 genome
- GTF annotation file (dm6.ncbiRefSeq.gtf)

## Directory Structure

```
fly_KD/
├── bulk_RNAseq_preprocess.smk    # Main Snakemake file
├── seq_data/
│   ├── raw/                      # Input FASTQ files
│   ├── clean/                    # Quality-trimmed reads
│   ├── bam/                      # Aligned BAM files
│   └── counts/                   # Gene expression counts
└── ref/
    └── dm6_ucsc/
        ├── dm6/                  # HISAT2 index files
        └── dm6.ncbiRefSeq.gtf    # Annotation file
```

## Usage

1. **Prepare input data**: Place paired-end FASTQ files in `seq_data/raw/` following the naming pattern:
   ```
   {sample}_1.fq.gz
   {sample}_2.fq.gz
   ```

2. **Update sample names**: Modify the `samples` list in the Snakemake file:
   ```python
   samples = ['luc-1-1','luc-2-1','luc-3-1','pus1-1-1','pus1-2-1','pus1-3-1']
   ```

3. **Run the pipeline**:
   ```bash
   snakemake -s bulk_RNAseq_preprocess.smk --cores 20
   ```

## Parameters

### fastp
- Quality score threshold: 20
- Minimum read length: 30
- Maximum N bases: 10
- Compression level: 4

### HISAT2
- Uses paired-end mode
- Parallel threads: 20

### featureCounts
- Minimum mapping quality: 10
- Primary alignments only
- Unstranded library
- Paired-end mode
- Gene-level counting

## Output

- **Clean reads**: `seq_data/clean/{sample}_clean_[1|2].fq.gz`
- **Aligned reads**: `seq_data/bam/{sample}.bam` (sorted and indexed)
- **Gene counts**: `seq_data/counts/featureCounts.txt`

## Sample Data

This pipeline was designed for a knockdown experiment comparing:
- Control samples: luc-1-1, luc-2-1, luc-3-1
- Treatment samples: pus1-1-1, pus1-2-1, pus1-3-1

## Citation

If you use this pipeline, please cite the relevant tools:
- Chen, S., et al. (2018). fastp: an ultra-fast all-in-one FASTQ preprocessor. Bioinformatics.
- Kim, D., et al. (2019). Graph-based genome alignment and genotyping with HISAT2 and HISAT-genotype. Nature Biotechnology.
- Li, H., et al. (2009). The Sequence Alignment/Map format and SAMtools. Bioinformatics.
- Liao, Y., et al. (2014). featureCounts: an efficient general purpose program for assigning sequence reads to genomic features. Bioinformatics.

## License

MIT License
