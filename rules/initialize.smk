configfile: "config.yaml"

rule initialize_index:
    input:
        config["ref"]["genome"]
    wrapper:
        "0.27.1/bio/bwa/index"

rule initialize_fa_index:
    input:
        config["ref"]["genome"]
    conda:
        "envs/samtools.yaml"
    shell:
        "samtools faidx {input}"

rule generate_dictionary:
     input:
        config["ref"]["genome"]
     conda:
        "../envs/gatk.yaml"
     shell:
        "gatk CreateSequenceDictionary -R {input}"
