rule veptest:
    input: 
        vcf="annotated/{sample}.vcf",
        genome=config["ref"]["genome-vep"],
        vepdir=config["ref"]["vepdir"]
    output: 
        "vep/{sample}.vep.vcf"
    conda: 
        "../envs/vep.yaml"
    threads: 4

    shell:
        "vep --verbose --offline --everything --fa {input.genome} --gencode_basic --cache --dir {input.vepdir} --fork 4 -i {input.vcf} --vcf -o {output}"
