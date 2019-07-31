rule igv_report:
    input:
        fasta=config["ref"]["genome"],
        vcf="vep/{sample}.vep.vcf",
        # any number of additional optional tracks, see igv-reports manual
        tracks=["recal/{sample}-1.bam"]
    output:
        "igv/{sample}.igv-report.html"
    params:
        extra=""  # optional params, see igv-reports manual
    log:
        "logs/{sample}.igv-report.log"
    wrapper:
        "0.35.1/bio/igv-reports"
