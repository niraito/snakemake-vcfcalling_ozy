rule freebayes:
    input:
        ref=config["ref"]["genome"],
        # you can have a list of samples here
        samples=get_recal_input()
    output:
        "filtered/{sample}.vcf.gz"   
    log:
        "logs/freebayes/{sample}.log"
    params:
        extra="",         # optional parameters
        chunksize=100000  # reference genome chunk size for parallelization (default: 100000)
    threads: 4
    wrapper:
        "0.36.0/bio/freebayes"
