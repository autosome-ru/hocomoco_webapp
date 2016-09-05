require 'bioinform'
require 'dipm'
require 'model_kind'

Motif = Struct.new(:full_name, :model_length, :consensus, :quality,
                          :auc, :max_auc,
                          :datasets, :origin_models,
                          :motif_families, :motif_subfamilies,
                          :hgnc_ids, :mgi_ids, :entrezgene_ids,
                          :gene_names, :uniprot_acs,
                          :num_words_in_alignment,
                          :comment) do

  def self.model_name; 'Motif'; end

  def uniprot_id; full_name.split('.')[0]; end
  def bundle_name; full_name.split('.')[1]; end
  def quality; full_name.split('.')[2]; end
  def species; uniprot_id.split('_').last; end
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

  def subfamily_ids
    motif_subfamilies.map{|subfamily| subfamily.match(/\{(.+)\}/)[1] }
  end

  def is_a_subfamily_member?(subfamily_id_query)
    subfamily_ids.any?{|subfamily_id|
      subfamily_id == subfamily_id_query || subfamily_id.start_with?(subfamily_id_query)
    }
  end

  def pcm_url
    ext = model_kind.pcm_extension
    (HocomocoSite::Application.config.relative_url_root || '') + "/final_bundle/#{species}/#{arity}/pcm/#{full_name}.#{ext}"
  end

  def pwm_url
    ext = model_kind.pwm_extension
    (HocomocoSite::Application.config.relative_url_root || '') + "/final_bundle/#{species}/#{arity}/pwm/#{full_name}.#{ext}"
  end

  def alignment_url
    ext = model_kind.pwm_extension
    (HocomocoSite::Application.config.relative_url_root || '') + "/final_bundle/#{species}/#{arity}/words/#{full_name}.words"
  end

  def pcm_path
    Rails.root.join("public/final_bundle/#{species}/#{arity}/pcm/#{full_name}.#{model_kind.pcm_extension}")
  end

  def pwm_path
    Rails.root.join("public/final_bundle/#{species}/#{arity}/pwm/#{full_name}.#{model_kind.pwm_extension}")
  end

  def threshold_pvalue_list_path
    Rails.root.join("public/final_bundle/#{species}/#{arity}/thresholds/#{full_name}.thr")
  end

  # def standard_thresholds_url
  #   (HocomocoSite::Application.config.relative_url_root || '') + "/final_bundle/#{species}/#{arity}/words/#{full_name}.words"
  # end

  def standard_thresholds
    standard_thresholds_path = Rails.root.join("public/final_bundle/#{species}/#{arity}/standard_thresholds_#{species}_#{arity}.txt")
    @cached_thresholds ||= {}
    @cached_thresholds[standard_thresholds_path] ||= begin
      lines = File.readlines(standard_thresholds_path).map(&:chomp).map{|line| line.split("\t") }
      pvalues = lines.first.drop(1).map(&:to_f)
      lines.drop(1).map{|line|
        motif, *thresholds = *line
        [motif, pvalues.zip(thresholds).to_h]
      }.to_h
    end
    @cached_thresholds[standard_thresholds_path][full_name]
  end

  def precalculated_thresholds_url
    (HocomocoSite::Application.config.relative_url_root || '') + "/final_bundle/#{species}/#{arity}/thresholds/#{full_name}.thr"
  end

  def model_kind; ModelKind.get(arity); end
  def pcm; model_kind.read_pcm(pcm_path); end
  def pwm; model_kind.read_pwm(pwm_path); end
  def threshold_pvalue_list
    File.readlines(threshold_pvalue_list_path).map{|line|
      line.chomp.split("\t").map(&:to_f)
    }
  end

  def direct_logo_url
    (HocomocoSite::Application.config.relative_url_root || '') + "/final_bundle/#{species}/#{arity}/logo_small/#{full_name}_direct.png"
  end

  # big logo is normal size, large logo is bigger than big and acceptable to insert logo in papers etc
  def direct_big_logo_url
    (HocomocoSite::Application.config.relative_url_root || '') + "/final_bundle/#{species}/#{arity}/logo/#{full_name}_direct.png"
  end

  def revcomp_big_logo_url
    (HocomocoSite::Application.config.relative_url_root || '') + "/final_bundle/#{species}/#{arity}/logo/#{full_name}_revcomp.png"
  end

  def direct_large_logo_url
    (HocomocoSite::Application.config.relative_url_root || '') + "/final_bundle/#{species}/#{arity}/logo_large/#{full_name}_direct.png"
  end

  def revcomp_large_logo_url
    (HocomocoSite::Application.config.relative_url_root || '') + "/final_bundle/#{species}/#{arity}/logo_large/#{full_name}_revcomp.png"
  end

  def self.from_string(str)
    full_name, model_length, consensus, \
      _uniprot,
      uniprot_acs, gene_names,
      _arity_type, \
      quality, num_words_in_alignment, auc, max_auc, \
      datasets, origin_models, \
      motif_families, motif_subfamilies, \
      hgnc_ids, mgi_ids, entrezgene_ids, \
      comment = str.chomp.split("\t", 19)
    datasets = datasets.split(', ')
    origin_models = origin_models.split(', ')
    motif_families = motif_families.split(':separator:')
    motif_subfamilies = motif_subfamilies.split(':separator:')
    auc = auc.empty? ? nil : auc.to_f
    max_auc = max_auc.empty? ? nil : max_auc.to_f
    self.new(full_name, model_length.to_i, consensus, quality, auc, max_auc,
      datasets, origin_models, motif_families, motif_subfamilies,
      hgnc_ids.split('; '), mgi_ids.split('; '), entrezgene_ids.split('; '),
      gene_names.split('; '), uniprot_acs.split('; '), num_words_in_alignment.to_i,
      comment)
  end

  def num_datasets
    datasets.size
  end

  def origin
    collection_names = origin_models.map{|motif| motif.split('~')[1] }
    raise  unless collection_names.all?{|collection| collection == collection_names.first }
    collection_name = collection_names.first
    {
      'CD' => 'ChIP-Seq', # Actually these models aren't in collection
      'CM' => 'ChIP-Seq',
      'PAPAM' => 'ChIP-Seq',
      'PAPAD' => 'ChIP-Seq',

      'SMF' => 'HT-SELEX',
      'SMI' => 'HT-SELEX',
      'SDF' => 'HT-SELEX', # Actually these models aren't in collection
      'SDI' => 'HT-SELEX', # Actually these models aren't in collection

      'HL' => 'HOCOMOCO v9',
    }[collection_name]
  end

  def match_query?(query)
    pattern = /#{query}/i
    [:full_name, :motif_families, :gene_names].any?{|param| self.send(param).to_s.match(pattern) }
  end

  def self.each_in_file(filename, &block)
    @cached_motifs ||= {}
    @cached_motifs[filename] ||= File.readlines(filename).drop(1).map{|line| self.from_string(line) }.each(&block)
  end

  def self.in_bundle(species:, arity:)
    self.each_in_file(Rails.root.join("public/final_bundle/#{species.upcase}/#{arity}/final_collection.tsv"))
  end
end
