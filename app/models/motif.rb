Motif = Struct.new(:full_name, :consensus_string, :quality,
                          :auc, :max_auc,
                          :datasets, :origin_models,
                          :motif_families, :motif_subfamilies,
                          :comment) do
  def self.from_string(str)
    full_name, consensus_string, \
      _uniprot, _arity_type, \
      quality, auc, max_auc, \
      datasets, origin_models, \
      motif_families, motif_subfamilies, comment = str.chomp.split("\t", 12)
    datasets = datasets.split(', ')
    origin_models = origin_models.split(', ')
    motif_families = motif_families.split('; ')
    motif_subfamilies = motif_subfamilies.split('; ')
    auc = auc.empty? ? nil : auc.to_f
    max_auc = max_auc.empty? ? nil : max_auc.to_f
    self.new(full_name, consensus_string, quality, auc, max_auc, datasets, origin_models, motif_families, motif_subfamilies, comment)
  end

  def self.each_in_file(filename, &block)
    File.readlines(filename).drop(1).map{|line| self.from_string(line) }.each(&block)
  end
end
