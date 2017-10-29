json.full_name   motif.full_name
json.direct_logo_url  motif.direct_large_logo_url
json.revcomp_logo_url  motif.revcomp_large_logo_url
json.gene_names  motif.gene_names
json.model_length  motif.model_length
json.rank   motif.rank
json.quality   motif.quality
json.consensus   motif.consensus
json.motif_source  motif.motif_source
json.release  motif.release
json.best_auc_human   motif.best_auc_human
json.best_auc_mouse   motif.best_auc_mouse
json.num_datasets_human  motif.num_datasets_human
json.num_datasets_mouse  motif.num_datasets_mouse
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
json.comment   motif.retracted? ? [motif.comment, "Retracted!"].compact.reject(&:empty?).join("\n") : motif.comment

if with_matrices
  json.pwm motif.pwm.matrix
  json.pcm motif.pcm.matrix
end
if with_thresholds
  json.threshold_pvalue_list motif.threshold_pvalue_list
end

# json.remap_url motif.remap_api_url # not yet working: remap doesn't have json-API

json.gtex_url motif.gtex_api_url
json.jaspar_urls motif.jaspar_api_links do |title, url|
  json.title title
  json.url url
end

json.retracted(motif.retracted?)
