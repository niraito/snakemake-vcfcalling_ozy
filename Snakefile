include: "rules/common.smk"

##### Target rules #####

rule all:
    input:
        expand("parse-vcf/{sample}.ann.csq.tsv", sample=samples.index)


##### Modules #####

include: "rules/mapping.smk"
include: "rules/calling.smk"
include: "rules/filtering.smk"
include: "rules/stats.smk"
include: "rules/qc.smk"
include: "rules/annotation.smk"
include: "rules/vep.smk"
include: "rules/igv.smk"
include: "rules/vepparse.smk"
