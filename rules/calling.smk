if "restrict-regions" in config["processing"]:
    rule compose_regions:
        input:
            config["processing"]["restrict-regions"]
        output:
            "called/{contig}.regions.bed"
        conda:
            "../envs/bedops.yaml"
        shell:
            "bedextract {wildcards.contig} {input} > {output}"


rule call_variants:
    input:
        bam=get_sample_bams,
        ref=config["ref"]["genome"],
        known=config["ref"]["known-variants"],
        regions="called/{contig}.regions.bed" if config["processing"].get("restrict-regions") else []
    output:
        gvcf=protected("called/{sample}.{contig}.g.vcf.gz")
    log:
        "logs/gatk/haplotypecaller/{sample}.{contig}.log"
    params:
        extra=get_call_variants_params
    wrapper:
        "0.27.1/bio/gatk/haplotypecaller"


#rule combine_calls:
 #   input:
  #      ref=config["ref"]["genome"],
   #     gvcfs="called/{sample}.{contig}.g.vcf.gz"
   # output:
    #    gvcf="called/{sample}.{contig}.g.vcf.gz"
   # log:
    #    "logs/gatk/combinegvcfs.{contig}.log"
  #  wrapper:
   #     "0.27.1/bio/gatk/combinegvcfs"


rule genotype_variants:
    input:
        ref=config["ref"]["genome"],
        gvcf="called/{sample}.{contig}.g.vcf.gz"
    output:
        vcf=temp("genotyped/{sample}.{contig}.vcf.gz")
    params:
        extra=config["params"]["gatk"]["GenotypeGVCFs"]
    log:
        "logs/gatk/genotypegvcfs{sample}.{contig}.log"
    wrapper:
        "0.27.1/bio/gatk/genotypegvcfs"


rule merge_variants:
    input:
        vcf=expand("genotyped/{{sample}}.{contig}.vcf.gz", contig=contigs)
    output:
        vcf="genotyped/{sample}.vcf.gz"
    log:
        "logs/picard/merge-genotyped{sample}.log"
    wrapper:
        "0.27.1/bio/picard/mergevcfs"
