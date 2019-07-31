rule strip_vcf_comments:
  input: "vep/{sample}.vep.vcf"

  output: temp("parse-vcf/{sample}.anno.vcf.nocomment")

  shell: 
    "sed -e 's/^#//' {input} > {output}"

rule extract_ann_csq:
  input: "parse-vcf/{sample}.anno.vcf.nocomment"

  output: "parse-vcf/{sample}.ann.csq.tsv"

  log: "logs/vcf-parse-{sample}.log"

  params:
   ann= config["vcf-columns"]["ann"],
   csq= config["vcf-columns"]["csq"],
   sample_name = lambda w: w.sample
   #sample={{sample}}

  conda: "../envs/tidyverse.yml"

  script: 
    "../extract-ann-csq-vcf.R"
