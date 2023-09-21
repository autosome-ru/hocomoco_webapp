json.array! motifs do |motif|
  json.full_name   motif.full_name
  json.gene_name_human  motif.gene_name_human
  json.gene_name_mouse  motif.gene_name_mouse
  json.gene_synonyms_human  motif.gene_synonyms_human
  json.gene_synonyms_mouse  motif.gene_synonyms_mouse
  json.motif_families  motif.motif_families
  json.motif_subfamilies   motif.motif_subfamilies

  json.uniprot_id  motif.uniprot_id
  # json.uniprot_acs   motif.uniprot_acs
end
