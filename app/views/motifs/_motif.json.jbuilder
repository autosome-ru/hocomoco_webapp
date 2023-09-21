json.full_name   motif.full_name
json.direct_logo_url  motif.direct_large_logo_url
json.revcomp_logo_url  motif.revcomp_large_logo_url
json.gene_name_human  motif.gene_name_human
json.gene_name_mouse  motif.gene_name_mouse
json.gene_synonyms_human  motif.gene_synonyms_human
json.gene_synonyms_mouse  motif.gene_synonyms_mouse
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
json.uniprot_id_human  motif.uniprot_id_human
json.uniprot_id_mouse  motif.uniprot_id_mouse
json.uniprot_ac_human   motif.uniprot_ac_human
json.uniprot_ac_mouse   motif.uniprot_ac_mouse
json.comment   motif.retracted? ? [motif.comment, "Retracted!"].compact.reject(&:empty?).join("\n") : motif.comment

if with_matrices
  json.pwm motif.pwm.matrix
  json.pcm motif.pcm.matrix
end
if with_thresholds
  json.threshold_pvalue_list motif.threshold_pvalue_list
end

json.quality_metrics do
  json.best_auc_human   motif.best_auc_human
  json.best_auc_mouse   motif.best_auc_mouse
  json.num_datasets_human  motif.num_datasets_human
  json.num_datasets_mouse  motif.num_datasets_mouse
  json.num_words_in_alignment  motif.num_words_in_alignment
end

json.related_urls do
  json.internal do
    json.pcm_url motif_pcm_url(motif.full_name, format: 'json')
    json.pwm_url motif_pwm_url(motif.full_name, format: 'json')
    json.thresholds_url motif_thresholds_url(motif.full_name, format: 'json')
    json.sequence_logo do
      json.large do
        json.direct_url  motif.direct_large_logo_url
        json.revcomp_url  motif.revcomp_large_logo_url
      end
    end
  end

  json.external do
    json.jaspar_urls motif.jaspar_api_links do |title, url|
      json.title title
      json.url url
    end

    json.gtex_url motif.gtex_api_url

#    json.tfclass_families motif.motif_families.map do |family|
#      motif
#    end

    # json.remap_url motif.remap_api_url  if motif.species == 'HUMAN' # not yet working: remap doesn't have json-API
  end
end

json.retracted(motif.retracted?)
