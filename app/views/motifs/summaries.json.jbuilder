json.array! motifs do |motif|
  json.full_name   motif.full_name
  json.gene_names  motif.gene_names
  json.motif_families  motif.motif_families
  json.motif_subfamilies   motif.motif_subfamilies

  json.uniprot_id  motif.uniprot_id
  # json.uniprot_acs   motif.uniprot_acs
end
