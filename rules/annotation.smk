rule snpeff:
    input:
        "filtered/{sample}.vcf.gz",
    output:
        vcf=report("annotated/{sample}.vcf.gz", caption="../report/vcf.rst", category="Calls"),
        csvstats="snpeff/{sample}.csv"
    log:
        "logs/snpeff{sample}.log"
    params:
        reference=config["ref"]["name"],
        extra="-Xmx6g"
    threads: 4
    wrapper:
        "0.27.1/bio/snpeff"
