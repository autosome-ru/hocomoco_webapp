json.array! motifs do |motif|
  json.full_name   motif.full_name
  json.gene_name_human  motif.gene_name_human
  json.gene_name_mouse  motif.gene_name_mouse
  json.gene_synonyms_human  motif.gene_synonyms_human
  json.gene_synonyms_mouse  motif.gene_synonyms_mouse

  json.motif_families  motif.motif_families
  json.motif_subfamilies   motif.motif_subfamilies

  json.uniprot_id_human  motif.uniprot_id_human
  json.uniprot_id_mouse  motif.uniprot_id_mouse
  json.uniprot_ac_human   motif.uniprot_ac_human
  json.uniprot_ac_mouse   motif.uniprot_ac_mouse

  json.entrezgene_ids_human   motif.entrezgene_ids_human
  json.entrezgene_ids_mouse   motif.entrezgene_ids_mouse
end
