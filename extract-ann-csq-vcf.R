library(tidyverse)

### import txt
filename <- snakemake@input[[1]]
contents <- read_tsv(filename, comment="#")
sample_name <- snakemake@params$sample_name
main_cols <- c("CHROM","POS","ID","REF","ALT","QUAL","FILTER")
ann_cols <- snakemake@params$ann
csq_cols <- snakemake@params$csq

cols_to_pick <- c(main_cols,ann_cols,csq_cols)

### functions to be used

# column headers for ANN are found in vcf file: `##INFO=<ID=ANN,Number=.,Type=String,Description="Functional annotations:...`
ann_col_headers <- c("allele","annotation","annotation_impact","gene_name","gene_id","feature_type","feature_id","transcript_biotype", "rank","HGVS.c","HGVS.p","cDNA.pos_length","CDS.pos_length","AA.pos_length","distance","errors_warnings_info")

# column headers for CSQ
csq_col_headers <- c("allele","consequence","impact","symbol","gene","feature_type","feature","biotype","exon","intron","hgvsc","hgvsp","cdna_position","cds_position","protein_position","amino_acids","codons","existing_variation","distance","strand","flags","variant_class","symbol_source","hgnc_id","canonical","tsl","appris","ccds","ensp","swissprot","trembl","uniparc","gene_pheno","sift","polyphen","domains","mirna","hgvs_offset","af","afr_af","amr_af","eas_af","eur_af","sas_af","aa_af","ea_af","gnomad_af","gnomad_afr_af","gnomad_amr_af","gnomad_asj_af","gnomad_eas_af","gnomad_fin_af","gnomad_nfe_af","gnomad_oth_af","gnomad_sas_af","max_af","max_af_pops","clin_sig","somatic","pheno","pubmed","motif_name","motif_pos","high_inf_pos","motif_score_change")

# this function deals with FORMAT and A columns
# "GT:AD:DP:GQ:PL  1/1:0,2:2:6:49,6,0" becomes
# GT  AD  DP  GQ  PL
# 1/1 0,2 2   6   49,6,0
# simple separate() was not used because some rows contain additional items: GT:AD:DP:GQ:PGT:PID:PL

zip_last_columns <-. %>% 
mutate(temp=map2(strsplit(FORMAT,":"), strsplit((!!sym(sample_name)),":"), ~paste0(.x,":",.y))) %>% 
  unnest(temp) %>% 
  separate(temp, into=c("key","value"), sep=":") %>% 
  spread(key,value) %>% 
  select(-FORMAT, -(!!sym(sample_name))) %>%
  mutate(GT_text=case_when(
    GT == "0/1" ~ "Het",
    GT == "1/1" ~ "Homo",
    TRUE ~ "Other"
  ))

# this function picks ANN and CSQ and makes them separate columns
# then keeps CSQ data separately in intermediate data frame in expanded form
# then makes full join with expanded ANN and CSQ data (the data for both was not in same order, thus using join)

pick_expand_ann_csq <- . %>%
  separate_rows(INFO,sep=";") %>%
  separate(INFO, c("key","value"),sep="=") %>%
  filter(key=="ANN" | key=="CSQ") %>% 
  spread(key,value) %T>%
  { select(., id_snp,CSQ) %>% 
      separate_rows(CSQ,sep=",") %>% 
      separate(CSQ,sep="\\|", into=csq_col_headers) ->> csq_raw } %>% 
  select(-CSQ) %>% 
  separate_rows(ANN,sep=",") %>% 
  separate(ANN,sep="\\|", into=ann_col_headers) %>% 
  full_join(csq_raw, by=c("id_snp", "allele", "feature_id"="feature"))


### actual parsing, using functions above


parsed_pool <- contents %>%
  mutate(id_snp=row_number()) %>%
  zip_last_columns() %>% 
  pick_expand_ann_csq() %>%
  group_by(id_snp) %>%
  mutate(id_eff=row_number()) %>% 
  ungroup() %>% 
  # group_by(id_snp,id_eff) %>%   # this generates single element groups?
  mutate(ann_id=paste("ANN",id_snp,id_eff,sep=".")) %>%
  select(one_of(cols_to_pick))

write_tsv(parsed_pool,snakemake@output[[1]])
