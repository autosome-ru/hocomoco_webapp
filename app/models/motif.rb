module HocomocoSite
  def self.url_in_final_bundle(url_part)
    url_base = HocomocoSite::Application.config.relative_url_root || ''
    "#{url_base}/final_bundle/#{HOCOMOCO_VERSION}/#{url_part}"
  end

  def self.path_in_final_bundle(path_part, retracted: false)
    Rails.root.join("public/final_bundle/#{HOCOMOCO_VERSION}/#{path_part}")
  end
end

Motif = Struct.new(:data, :full_name, :model_length, :consensus, :quality, :motif_subtype,
                          :best_auc_human, :best_auc_mouse,
                          :num_datasets_human, :num_datasets_mouse,
                          :data_sources,
                          :motif_families, :motif_subfamilies,
                          :hgnc_ids, :mgi_ids,
                          :num_words_in_alignment,
                          :comment, :retracted) do

  def self.model_name; 'Motif'; end

  def name; full_name; end
  def tf; full_name.split('.')[0]; end
  def gc_content; data['gc_content']; end
  def information_content_total; data['information_content_total']; end
  def information_content_per_base; data['information_content_per_base']; end

  def uniprot_id_human; data.dig('masterlist_info', 'species', 'HUMAN', 'uniprot_id'); end
  def uniprot_id_mouse; data.dig('masterlist_info', 'species', 'MOUSE', 'uniprot_id'); end

  def uniprot_ac_human; data.dig('masterlist_info', 'species', 'HUMAN', 'uniprot_ac'); end
  def uniprot_ac_mouse; data.dig('masterlist_info', 'species', 'MOUSE', 'uniprot_ac'); end

  def collection; full_name.split('.')[1]; end
  def bundle_name; collection; end
  # def datatypes; full_name.split('.')[3]; end
  # def quality; full_name.split('.')[4]; end
  def species; 'HUMAN'; end
  def to_s; full_name; end
  def retracted?; !! retracted; end
  def gene_name_human; data.dig('masterlist_info', 'species', 'HUMAN', 'gene_symbol') ; end
  def gene_synonyms_human; data.dig('masterlist_info', 'species', 'HUMAN', 'gene_synonyms') || []; end
  def gene_name_mouse; data.dig('masterlist_info', 'species', 'MOUSE', 'gene_symbol') ; end
  def gene_synonyms_mouse; data.dig('masterlist_info', 'species', 'MOUSE', 'gene_synonyms') || []; end
  def entrezgene_ids_human; data.dig('masterlist_info', 'species', 'HUMAN', 'entrez') || []; end
  def entrezgene_ids_mouse; data.dig('masterlist_info', 'species', 'MOUSE', 'entrez') || []; end
  def greco_db_tf; data.dig('masterlist_info', 'greco_db_tf'); end
  def gene_name; gene_name_human || gene_name_mouse; end

  def metrics_summary; data['metrics_summary']; end

  # def subfamily_ids
  #   motif_subfamilies.map{|subfamily| subfamily.match(/\{(.+)\}/)[1] }
  # end

  def is_a_subfamily_member?(subfamily_id_query)
    "#{tfclass_id}.".start_with?("#{subfamily_id_query}.")
    # subfamily_ids.any?{|subfamily_id|
      # subfamily_id == subfamily_id_query || subfamily_id.start_with?(subfamily_id_query)
    # }
  end

  def url_in_final_bundle(url_part)
    if retracted?
      HocomocoSite::url_in_final_bundle("retracted/#{url_part}")
    else
      HocomocoSite::url_in_final_bundle("#{url_part}")
    end
  end

  def path_in_final_bundle(path_part);
    if retracted?
      HocomocoSite::path_in_final_bundle("retracted/#{path_part}")
    else
      HocomocoSite::path_in_final_bundle("#{path_part}")
    end
  end

  def pcm_url
    url_in_final_bundle("#{collection}/pcm/#{full_name}.pcm")
  end

  def pwm_url
    url_in_final_bundle("#{collection}/pwm/#{full_name}.pwm")
  end

  def pfm_url
    url_in_final_bundle("#{collection}/pfm/#{full_name}.pfm")
  end

  def alignment_url
    url_in_final_bundle("#{collection}/words/#{full_name}.words.tsv")
  end

  def jaspar_url
    url_in_final_bundle("#{collection}/formatted_motifs/jaspar/#{full_name}_jaspar_format.txt")
  end

  def transfac_url
    url_in_final_bundle("#{collection}/formatted_motifs/transfac/#{full_name}_transfac_format.txt")
  end

  def meme_url
    url_in_final_bundle("#{collection}/formatted_motifs/meme/#{full_name}_meme_format.meme")
  end

  def homer_url(pvalue:)
    url_in_final_bundle("#{collection}/formatted_motifs/homer/pvalue_#{pvalue}/#{full_name}_homer_format_#{pvalue}.motif")
  end

  def pcm_path
    path_in_final_bundle("#{collection}/pcm/#{full_name}.pcm")
  end

  def pwm_path
    path_in_final_bundle("#{collection}/pwm/#{full_name}.pwm")
  end

  def pfm_path
    path_in_final_bundle("#{collection}/pfm/#{full_name}.pfm")
  end

  def threshold_pvalue_list_path
    path_in_final_bundle("#{collection}/thresholds/#{full_name}.thr")
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

  def standard_thresholds; data['standard_thresholds']; end

  def precalculated_thresholds_url
    url_in_final_bundle("#{collection}/thresholds/#{full_name}.thr")
  end

  def read_matrix(fn)
    File.readlines(fn).reject{|l| l.start_with?('>') }.map{|l| l.chomp.split("\t").map{|v| Float(v) } }
  end
  def pcm; read_matrix(pcm_path); end
  def pwm; read_matrix(pwm_path); end
  def pfm; read_matrix(pfm_path); end
  def threshold_pvalue_list
    File.readlines(threshold_pvalue_list_path).map{|line|
      line.chomp.split("\t").map(&:to_f)
    }
  end

  def direct_logo_url
    url_in_final_bundle("#{collection}/logo_small/#{full_name}_direct.png")
  end

  # big logo is normal size, large logo is bigger than big and acceptable to insert logo in papers etc
  def direct_big_logo_url
    url_in_final_bundle("#{collection}/logo/#{full_name}_direct.png")
  end

  def revcomp_big_logo_url
    url_in_final_bundle("#{collection}/logo/#{full_name}_revcomp.png")
  end

  def direct_large_logo_url
    url_in_final_bundle("#{collection}/logo_large/#{full_name}_direct.png")
  end

  def revcomp_large_logo_url
    url_in_final_bundle("#{collection}/logo_large/#{full_name}_revcomp.png")
  end

  # def motif_subfamily_ids
  #   motif_families.map{|fam|
  #     match = fam.match(/^(?<name>.+)\{(?<family_id>[\d.]+)\}$/)
  #     match[:family_id]
  #   }
  # end

  def motif_families_links
    motif_families.map{|fam|
      match = fam.match(/^(?<name>.+)\{(?<family_id>[\d.]+)\}$/)
      [fam, "http://tfclass.bioinf.med.uni-goettingen.de/?tfclass=#{match[:family_id]}"]
    }
  end

  def tfclass_at_level(level);
    levels = [nil, 'tfclass_superclass', 'tfclass_class', 'tfclass_family', 'tfclass_subfamily']
    data.dig('masterlist_info', levels[level])
  end
  def tfclass_superclass; data.dig('masterlist_info', 'tfclass_superclass'); end
  def tfclass_class; data.dig('masterlist_info', 'tfclass_class'); end
  def tfclass_family; data.dig('masterlist_info', 'tfclass_family'); end
  def tfclass_subfamily; data.dig('masterlist_info', 'tfclass_subfamily'); end
  def tfclass_id; data.dig('masterlist_info', 'tfclass_id'); end
  def tfclass_id_at_level(level); (tfclass_id || '').split('.').first(level).join('.'); end

  def self.from_json(data, retracted: false)
    full_name = data['name']
    num_datasets_human = data.dig('original_motif', 'species_counts', 'HUMAN') || 0
    num_datasets_mouse = data.dig('original_motif', 'species_counts', 'MOUSE') || 0
    motif_families = [data.dig('masterlist_info', 'tfclass_family')]
    motif_subfamilies = [data.dig('masterlist_info', 'tfclass_subfamily')]
    data_sources = data['datatype']
    hgnc_ids = data.dig('masterlist_info', 'species', 'HUMAN', 'hgnc') || []
    mgi_ids = data.dig('masterlist_info', 'species', 'MOUSE', 'mgi') || []

    num_words_in_alignment = data['num_words']
    comment = data.fetch('comment', '')

# TODO:
    best_auc_human = nil #best_auc_human.empty? ? nil : best_auc_human.to_f
    best_auc_mouse = nil #best_auc_mouse.empty? ? nil : best_auc_mouse.to_f

    self.new(data, full_name, data['length'], data['consensus'], data['quality'], data['subtype_order'].to_i,
      best_auc_human, best_auc_mouse,
      num_datasets_human, num_datasets_mouse,
      data_sources,
      motif_families, motif_subfamilies,
      hgnc_ids, mgi_ids,
      num_words_in_alignment,
      comment, retracted)
  end

  def match_query?(query)
    match = nil # postfix-if work incorrectly with undefined local-variable (https://bugs.ruby-lang.org/issues/16631)
    return hgnc_ids.include?(match[1])  if match = query.match(/\bHGNC:?\s*(\d+)\b/i)
    return mgi_ids.include?(match[1])  if match = query.match(/\bMGI:?\s*(\d+)\b/i)
    return entrezgene_ids_human.include?(match[2])  if match = query.match(/\bEntrez(\s*gene)?:?\s*(\d+)\b/i)
    return entrezgene_ids_mouse.include?(match[2])  if match = query.match(/\bEntrez(\s*gene)?:?\s*(\d+)\b/i)
    return entrezgene_ids_human.include?(match[2])  if match = query.match(/\bGene(\s*Id)?:?\s*(\d+)\b/i)
    return entrezgene_ids_mouse.include?(match[2])  if match = query.match(/\bGene(\s*Id)?:?\s*(\d+)\b/i)

    pattern = /#{query}/i
    [
      :full_name,
      :tfclass_superclass, :tfclass_class, :tfclass_family, :tfclass_subfamily, #:tfclass_id,
      :gene_name_human, :gene_name_mouse, :gene_synonyms_human, :gene_synonyms_mouse
    ].any?{|param|
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
    @cached_motifs[filename] ||= File.readlines(filename).map{|line| self.from_json(JSON.parse(line)) }.each(&block)
  end

  def self.in_bundle(collection: 'H12CORE')
    result = self.each_in_file(HocomocoSite::path_in_final_bundle("#{collection}/#{collection}_annotation.jsonl")).to_a.sort_by(&:name)
    # if File.exist?(HocomocoSite::path_in_final_bundle("retracted/#{species.upcase}/#{arity}/HOCOMOCOv#{HOCOMOCO_VERSION_NUMBER}_retracted_final_collection_#{species.upcase}_#{arity}.tsv"))
    #   result += self.each_in_file(HocomocoSite::path_in_final_bundle("retracted/#{species.upcase}/#{arity}/HOCOMOCOv#{HOCOMOCO_VERSION_NUMBER}_retracted_final_collection_#{species.upcase}_#{arity}.tsv"), retracted: true).to_a
    # end
    result
  end

  def self.all
    ['H12CORE', 'H12INVIVO', 'H12INVITRO', 'H12RSNP'].flat_map{|collection|
      self.in_bundle(collection: collection)
    }
  end

  def self.by_name(motif_name)
    collection = motif_name.split('.')[1]
    Motif.in_bundle(collection: collection).detect{|motif|
      motif.full_name == motif_name
    }
  end
end
