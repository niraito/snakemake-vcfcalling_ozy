rule samtools_index:
    input:
        "dedup/{sample}-1.bam"
    output:
        "dedup/{sample}-1.bam.bai"
    wrapper:
        "0.37.1/bio/samtools/index"

rule freebayes:
    input:
        ref=config["ref"]["genome"],
        # you can have a list of samples here
        samples="dedup/{sample}-1.bam"
    output:
        "filtered/{sample}.vcf.gz"   
    log:
        "logs/freebayes/{sample}.log"
    params:
        extra="-C 5 --min-coverage 20 ",         # optional parameters
        chunksize=100000  # reference genome chunk size for parallelization (default: 100000)
    threads: 4
    wrapper:
        "0.36.0/bio/freebayes"
