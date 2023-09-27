require 'bioinform'
require 'dipm'
require 'model_kind'


TF_CLASSIFICATION_HUMAN = WingenderTFClass::OBO::TFClassification.from_file(WingenderTFClass::FilePaths::TFOntologyHuman)
TF_CLASSIFICATION_MOUSE = WingenderTFClass::OBO::TFClassification.from_file(WingenderTFClass::FilePaths::TFOntologyMouse)

def tfclass_term_names(id)
  [TF_CLASSIFICATION_HUMAN, TF_CLASSIFICATION_MOUSE].map{|tf_clsf| tf_clsf.term(id) }.uniq
end

module HocomocoSite
  def self.url_in_final_bundle(url_part)
    url_base = HocomocoSite::Application.config.relative_url_root || ''
    "#{url_base}/final_bundle/#{HOCOMOCO_VERSION}/#{url_part}"
  end

  def self.path_in_final_bundle(path_part, retracted: false)
    Rails.root.join("public/final_bundle/#{HOCOMOCO_VERSION}/#{path_part}")
  end
end

Motif = Struct.new(:full_name, :model_length, :consensus, :quality, :rank,
                          :best_auc_human, :best_auc_mouse,
                          :num_datasets_human, :num_datasets_mouse,
                          :release, :motif_source,
                          :motif_families, :motif_subfamilies,
                          :hgnc_ids, :mgi_ids, :entrezgene_ids,
                          :gene_names, :uniprot_acs,
                          :num_words_in_alignment,
                          :comment, :retracted) do

  def self.model_name; 'Motif'; end

  def uniprot_id; full_name.split('.')[0]; end
  def bundle_name; full_name.split('.')[1]; end
  def rank; full_name.split('.')[2].to_i; end
  def quality; full_name.split('.')[3]; end
  def species; uniprot_id.split('_').last; end
  def to_s; full_name; end
  def retracted?; !! retracted; end
  def gene_name; gene_names.first; end

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

  def url_in_final_bundle(url_part)
    if retracted?
      HocomocoSite::url_in_final_bundle("retracted/#{url_part}")
    else
      HocomocoSite::url_in_final_bundle("full/#{url_part}")
    end
  end

  def path_in_final_bundle(path_part);
    if retracted?
      HocomocoSite::path_in_final_bundle("retracted/#{path_part}")
    else
      HocomocoSite::path_in_final_bundle("full/#{path_part}")
    end
  end

  def pcm_url
    ext = model_kind.pcm_extension
    url_in_final_bundle("#{species}/#{arity}/pcm/#{full_name}.#{ext}")
  end

  def pwm_url
    ext = model_kind.pwm_extension
    url_in_final_bundle("#{species}/#{arity}/pwm/#{full_name}.#{ext}")
  end

  def alignment_url
    ext = model_kind.pwm_extension
    url_in_final_bundle("#{species}/#{arity}/words/#{full_name}.words")
  end

  def pcm_path
    path_in_final_bundle("#{species}/#{arity}/pcm/#{full_name}.#{model_kind.pcm_extension}")
  end

  def pwm_path
    path_in_final_bundle("#{species}/#{arity}/pwm/#{full_name}.#{model_kind.pwm_extension}")
  end

  def threshold_pvalue_list_path
    path_in_final_bundle("#{species}/#{arity}/thresholds/#{full_name}.thr")
  end

  def remap_url
    "https://tagc.univ-mrs.fr/remap/factor.php?TF=#{gene_name}&page=overview"
  end

  def remap_api_url
  end

  def gtex_url
    "https://gtexportal.org/home/gene/#{gene_name}"
  end

  def gtex_api_url
    # "https://gtexportal.org/rest/v1/reference/geneId?geneId=#{gene_name}"
    "https://gtexportal.org/rest/v1/dataset/expression?gene_id=#{gene_name}&boxplot=true&isoforms=true"
  end


  def self.jaspar_matrices
    @jaspar_matrices ||= begin
      File.readlines(Rails.root.join('public/hocomoco_jaspar_mapping.txt')).map{|line|
        hocomoco_motif, *jaspar_infos = line.chomp.split("\t")
        [hocomoco_motif, jaspar_infos.map{|json_obj| JSON.parse(json_obj) }]
      }.to_h
    end
  end

  def jaspar_links
    self.class.jaspar_matrices.fetch(full_name, []).map{|info|
      species = info['species'].map{|sp| sp['name'] }.join('/') rescue nil
      if species
        ["#{info['matrix_id']} (#{info['name']}; #{species})", "https://jaspar.genereg.net/matrix/#{info['matrix_id']}/"]
      else
        ["#{info['matrix_id']} (#{info['name']})", "https://jaspar.genereg.net/matrix/#{info['matrix_id']}/"]
      end
    }
  end

  def jaspar_api_links
    self.class.jaspar_matrices.fetch(full_name,[]).map{|info|
      species = info['species'].map{|sp| sp['name'] }.join('/') rescue nil
      if species
        ["#{info['matrix_id']} (#{info['name']}; #{species})", "https://jaspar.genereg.net/api/v1/matrix/#{info['matrix_id']}/"]
      else
        ["#{info['matrix_id']} (#{info['name']})", "https://jaspar.genereg.net/api/v1/matrix/#{info['matrix_id']}/"]
      end
    }
  end

  def jaspar_api_url
    # "https://jaspar.genereg.net/api/v1/matrix/?collection=CORE&tax_group=Vertebrates&version=latest&name=#{gene_name}&format=json" # not yet working API
    "https://jaspar.genereg.net/api/v1/matrix/?collection=CORE&tax_group=Vertebrates&version=latest&search=#{gene_name}&format=json"
  end

  def self.read_standard_thresholds(filename)
    lines = File.readlines(filename).map(&:chomp).map{|line| line.split("\t") }
    pvalues = lines.first.drop(1).map(&:to_f)
    lines.drop(1).map{|line|
      motif, *thresholds = *line
      [motif, pvalues.zip(thresholds).to_h]
    }.to_h
  end

  def self.standard_thresholds_by_motif
    @standard_thresholds_by_motif ||= Hash.new{|species_hash, species|
      species_hash[species] = Hash.new{|arity_hash, arity|
        standard_thresholds_path = HocomocoSite::path_in_final_bundle("full/#{species}/#{arity}/HOCOMOCOv#{HOCOMOCO_VERSION_NUMBER}_full_standard_thresholds_#{species}_#{arity}.txt")
        retracted_standard_thresholds_path = HocomocoSite::path_in_final_bundle("retracted/#{species}/#{arity}/HOCOMOCOv#{HOCOMOCO_VERSION_NUMBER}_retracted_standard_thresholds_#{species}_#{arity}.txt")
        standard_thresholds = read_standard_thresholds(standard_thresholds_path)
        if File.exist?(retracted_standard_thresholds_path)
          retracted_standard_thresholds = read_standard_thresholds(retracted_standard_thresholds_path)
          arity_hash[arity] = standard_thresholds.merge(retracted_standard_thresholds)
        else
          arity_hash[arity] = standard_thresholds
        end
      }
    }
  end

  def standard_thresholds
    self.class.standard_thresholds_by_motif[species][arity][full_name]
  end

  def precalculated_thresholds_url
    url_in_final_bundle("#{species}/#{arity}/thresholds/#{full_name}.thr")
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
    url_in_final_bundle("#{species}/#{arity}/logo_small/#{full_name}_direct.png")
  end

  # big logo is normal size, large logo is bigger than big and acceptable to insert logo in papers etc
  def direct_big_logo_url
    url_in_final_bundle("#{species}/#{arity}/logo/#{full_name}_direct.png")
  end

  def revcomp_big_logo_url
    url_in_final_bundle("#{species}/#{arity}/logo/#{full_name}_revcomp.png")
  end

  def direct_large_logo_url
    url_in_final_bundle("#{species}/#{arity}/logo_large/#{full_name}_direct.png")
  end

  def revcomp_large_logo_url
    url_in_final_bundle("#{species}/#{arity}/logo_large/#{full_name}_revcomp.png")
  end

  def motif_subfamily_ids
    motif_families.map{|fam|
      match = fam.match(/^(?<name>.+)\{(?<family_id>[\d.]+)\}$/)
      match[:family_id]
    }
  end

  def motif_families_links
    motif_families.map{|fam|
      match = fam.match(/^(?<name>.+)\{(?<family_id>[\d.]+)\}$/)
      [fam, "http://tfclass.bioinf.med.uni-goettingen.de/?tfclass=#{match[:family_id]}"]
    }
  end

  def motif_classes
    motif_subfamily_ids.map{|id|
      id.split('.').first(2).join('.')
    }.uniq.flat_map{|class_id|
      tfclass_term_names(class_id)
    }
  end

  def motif_superclasses
    motif_subfamily_ids.map{|id|
      id.split('.').first(2).join('.')
    }.uniq.flat_map{|class_id|
      tfclass_term_names(class_id)
    }
  end

  def self.from_string(str, retracted: false)
    full_name, model_length, consensus, \
      _uniprot, \
      uniprot_acs, gene_names, \
      _arity_type, \
      quality, rank, num_words_in_alignment, \
      best_auc_human, best_auc_mouse, \
      num_datasets_human, num_datasets_mouse, \
      release, motif_source, \
      motif_families, motif_subfamilies, \
      hgnc_ids, mgi_ids, entrezgene_ids, \
      comment \
        = str.chomp.split("\t", 22)
    motif_families = motif_families.split(':separator:')
    motif_subfamilies = motif_subfamilies.split(':separator:')
    best_auc_human = best_auc_human.empty? ? nil : best_auc_human.to_f
    best_auc_mouse = best_auc_mouse.empty? ? nil : best_auc_mouse.to_f
    num_datasets_human = num_datasets_human.empty? ? nil : num_datasets_human.to_i
    num_datasets_mouse = num_datasets_mouse.empty? ? nil : num_datasets_mouse.to_i

    self.new(full_name, model_length.to_i, consensus, quality, rank.to_i,
      best_auc_human, best_auc_mouse,
      num_datasets_human, num_datasets_mouse,
      release, motif_source,
      motif_families, motif_subfamilies,
      hgnc_ids.split('; '), mgi_ids.split('; '), entrezgene_ids.split('; '),
      gene_names.split('; '), uniprot_acs.split('; '), num_words_in_alignment.to_i,
      comment, retracted)
  end

  def match_query?(query)
    match = nil # postfix-if work incorrectly with undefined local-variable (https://bugs.ruby-lang.org/issues/16631)
    return hgnc_ids.include?(match[1])  if match = query.match(/\bHGNC:?\s*(\d+)\b/i)
    return mgi_ids.include?(match[1])  if match = query.match(/\bMGI:?\s*(\d+)\b/i)
    return entrezgene_ids.include?(match[2])  if match = query.match(/\bEntrez(\s*gene)?:?\s*(\d+)\b/i)
    return entrezgene_ids.include?(match[2])  if match = query.match(/\bGene(\s*Id)?:?\s*(\d+)\b/i)

    pattern = /#{query}/i
    [:full_name, :motif_subfamilies, :motif_families, :motif_classes, :motif_superclasses, :gene_names].any?{|param|
      val = self.send(param)
      case val
      when Array
        val.any?{|v| v.to_s.match(pattern) }
      else
        val.to_s.match(pattern)
      end
    }
  rescue
    nil
  end

  def self.each_in_file(filename, retracted: false, &block)
    @cached_motifs ||= {}
    @cached_motifs[filename] ||= File.readlines(filename).drop(1).map{|line| self.from_string(line, retracted: retracted) }.each(&block)
  end

  def self.in_bundle(species:, arity:)
    result = self.each_in_file(HocomocoSite::path_in_final_bundle("full/#{species.upcase}/#{arity}/HOCOMOCOv#{HOCOMOCO_VERSION_NUMBER}_full_final_collection_#{species.upcase}_#{arity}.tsv")).to_a
    if File.exist?(HocomocoSite::path_in_final_bundle("retracted/#{species.upcase}/#{arity}/HOCOMOCOv#{HOCOMOCO_VERSION_NUMBER}_retracted_final_collection_#{species.upcase}_#{arity}.tsv"))
      result += self.each_in_file(HocomocoSite::path_in_final_bundle("retracted/#{species.upcase}/#{arity}/HOCOMOCOv#{HOCOMOCO_VERSION_NUMBER}_retracted_final_collection_#{species.upcase}_#{arity}.tsv"), retracted: true).to_a
    end
    result
  end

  def self.all
    [:human, :mouse].flat_map{|species|
      [:mono, :di].flat_map{|arity|
        self.in_bundle(species: species, arity: arity)
      }
    }
  end

  def self.by_name(motif_name)
    species = motif_name.split('.')[0].split('_').last.upcase
    bundle_name = motif_name.split('.')[1].upcase
    arity = {'H11MO' => 'mono', 'H11DI' => 'di'}[bundle_name]
    Motif.in_bundle(species: species, arity: arity).detect{|motif|
      motif.full_name == motif_name
    }
  end
end
