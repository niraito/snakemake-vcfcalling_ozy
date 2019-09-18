def get_vartype_arg(wildcards):
    return "--select-type-to-include {}".format(
        "SNP" if wildcards.vartype == "snvs" else "INDEL")


rule select_calls:
    input:
        ref=config["ref"]["genome"],
        vcf="genotyped/{sample}.vcf.gz"
    output:
        vcf=temp("filtered/{sample}.{vartype}.vcf.gz")
    params:
        extra=get_vartype_arg
    log:
        "logs/gatk/selectvariants/{sample}.{vartype}.log"
    wrapper:
        "0.27.1/bio/gatk/selectvariants"


def get_filter(wildcards):
    return {
        "snv-hard-filter":
        config["filtering"]["hard"][wildcards.vartype]}


rule hard_filter_calls:
    input:
        ref=config["ref"]["genome"],
        vcf="filtered/{sample}.{vartype}.vcf.gz"
    output:
        vcf=temp("filtered/{sample}.{vartype}.hardfiltered.vcf.gz")
    params:
        filters=get_filter
    log:
        "logs/gatk/variantfiltration/{sample}.{vartype}.log"
    wrapper:
        "0.27.1/bio/gatk/variantfiltration"


rule recalibrate_calls:
    input:
        vcf="filtered/{sample}.{vartype}.vcf.gz"
    output:
        vcf=temp("filtered/{sample}.{vartype}.recalibrated.vcf.gz")
    params:
        extra=config["params"]["gatk"]["VariantRecalibrator"]
    log:
        "logs/gatk/variantrecalibrator/{sample}.{vartype}.log"
    wrapper:
        "0.27.1/bio/gatk/variantrecalibrator"


rule merge_calls:
    input:
        vcf=expand("filtered/{{sample}}.{vartype}.{filtertype}.vcf.gz",
                   vartype=["snvs", "indels"],
                   filtertype="recalibrated"
                              if config["filtering"]["vqsr"]
                              else "hardfiltered")
    output:
        vcf="filtered/{sample}.vcf"
    log:
        "logs/picard/{sample}.merge-filtered.log"
    wrapper:
        "0.27.1/bio/picard/mergevcfs"
