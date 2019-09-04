include: "rules/common.smk"

##### Target rules #####

rule all:
    input:
        expand("parse-vcf/{sample}.ann.csq.tsv", sample=samples.index)


##### Modules #####

include: "rules/mapping.smk"
if config["params"]["caller"] == "freebayes":
    include: "rules/freebayes.smk"
elif config["params"]["caller"] == "gatk":
    include: "rules/calling.smk"
    include: "rules/filtering.smk"
else:
    sys.exit("Error: Wrong caller! Available callers are GATK or Freebayes.")
include: "rules/stats.smk"
include: "rules/qc.smk"
include: "rules/annotation.smk"
include: "rules/vep.smk"
include: "rules/igv.smk"
include: "rules/vepparse.smk"
