json.full_name   motif.full_name
json.direct_logo_url  motif.direct_big_logo_url
json.revcomp_logo_url  motif.revcomp_big_logo_url
json.gene_names  motif.gene_names
json.model_length  motif.model_length
json.quality   motif.quality
json.consensus   motif.consensus
json.origin  motif.origin
json.auc   motif.auc
json.max_auc   motif.max_auc
json.num_datasets  motif.num_datasets
json.num_words_in_alignment  motif.num_words_in_alignment
json.motif_families  motif.motif_families
json.motif_subfamilies   motif.motif_subfamilies

if motif.species == 'HUMAN'
  json.hgnc_ids(motif.hgnc_ids)
else
  json.mgi_ids(motif.mgi_ids)
end

json.entrezgene_ids  motif.entrezgene_ids
json.uniprot_id  motif.uniprot_id
json.uniprot_acs   motif.uniprot_acs
json.comment   motif.comment

if with_matrices
  json.pwm motif.pwm.matrix
  json.pcm motif.pcm.matrix
end
if with_thresholds
  json.threshold_pvalue_list motif.threshold_pvalue_list
end
