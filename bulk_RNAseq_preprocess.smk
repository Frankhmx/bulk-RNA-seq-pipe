import os


samples = ['luc-1-1','luc-2-1','luc-3-1','pus1-1-1','pus1-2-1','pus1-3-1']
rule all:
    input:
        expand("seq_data/clean/{sample}_clean_1.fq.gz", sample=samples),
        expand("seq_data/bam/{sample}.bam", sample=samples),
        "seq_data/counts/featureCounts.txt"

rule fastp:
    input:
        R1="seq_data/raw/{sample}_1.fq.gz",
        R2="seq_data/raw/{sample}_2.fq.gz"
    output:
        R1="seq_data/clean/{sample}_clean_1.fq.gz",
        R2="seq_data/clean/{sample}_clean_2.fq.gz"
    threads: 20
    shell:
        """
        fastp -i {input.R1} -I {input.R2} -o {output.R1} -O {output.R2} -w {threads} -z 4 -q 20 -u 30 -n 10
        """

rule hisat2:
    input:
        R1="seq_data/clean/{sample}_clean_1.fq.gz",
        R2="seq_data/clean/{sample}_clean_2.fq.gz"
    output:
        temp("seq_data/bam/{sample}.sam")
    params:
        ref='ref/dm6_ucsc/dm6/dm6'
    threads: 20
    shell:
        """
        hisat2 -x {params.ref} -1 {input.R1} -2 {input.R2} -S {output} -p {threads}
        """


rule sam_to_bam:
    input:
        "seq_data/bam/{sample}.sam"
    output:
        "seq_data/bam/{sample}.bam"
    threads: 20
    shell:
        """
        samtools view --threads {threads} -bS {input} | samtools sort --threads {threads} -o {output}
        samtools index {output}
        """

rule featurecounts:
    input:
        expand("seq_data/bam/{sample}.bam", sample=samples)
    output:
        "seq_data/counts/featureCounts.txt"
    params:
        gtf='ref/dm6_ucsc/dm6.ncbiRefSeq.gtf'
    threads: 20
    shell:
        """
        featureCounts -a {params.gtf} -T {threads} -g gene_name -Q 10 --primary -s 0 -p -o {output} {input} 
        """