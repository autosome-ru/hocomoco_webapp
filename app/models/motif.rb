Motif = Struct.new(:full_name, :model_length, :consensus_string, :quality,
                          :auc, :max_auc,
                          :datasets, :origin_models,
                          :motif_families, :motif_subfamilies,
                          :hgnc_ids, :mgi_ids, :entrezgene_ids,
                          :gene_names, :uniprot_acs,
                          :comment) do

  def uniprot; full_name.split('.')[0]; end
  def bundle_name; full_name.split('.')[1]; end
  def quality; full_name.split('.')[2]; end
  def species; uniprot.split('_').last; end
  def to_s; full_name; end

  def arity
    case bundle_name[-2,2]
    when 'MO'
      'mono'
    when 'DI'
      'di'
    else
      raise "Unknown bundle #{bundle_name} for model #{full_name}"
    end
  end

  def direct_logo_path
    "/final_bundle/#{species}/#{arity}/logo_small/#{full_name}_direct.png"
  end

  def direct_big_logo_path
    "/final_bundle/#{species}/#{arity}/logo/#{full_name}_direct.png"
  end

  def revcomp_big_logo_path
    "/final_bundle/#{species}/#{arity}/logo/#{full_name}_recomp.png"
  end

  def self.from_string(str)
    full_name, model_length, consensus_string, \
      _uniprot, 
      uniprot_acs, gene_names,
      _arity_type, \
      quality, auc, max_auc, \
      datasets, origin_models, \
      motif_families, motif_subfamilies, \
      hgnc_ids, mgi_ids, entrezgene_ids, \
      comment = str.chomp.split("\t", 18)
    datasets = datasets.split(', ')
    origin_models = origin_models.split(', ')
    motif_families = motif_families.split(':separator:')
    motif_subfamilies = motif_subfamilies.split(':separator:')
    auc = auc.empty? ? nil : auc.to_f
    max_auc = max_auc.empty? ? nil : max_auc.to_f
    self.new(full_name, model_length.to_i, consensus_string, quality, auc, max_auc,
      datasets, origin_models, motif_families, motif_subfamilies,
      hgnc_ids.split('; '), mgi_ids.split('; '), entrezgene_ids.split('; '),
      gene_names.split('; '), uniprot_acs.split('; '),
      comment)
  end

  def num_datasets
    datasets.size
  end

  def self.each_in_file(filename, &block)
    File.readlines(filename).drop(1).map{|line| self.from_string(line) }.each(&block)
  end
end
