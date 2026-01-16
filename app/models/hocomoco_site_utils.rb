module HocomocoSiteUtils
  def self.url_in_final_bundle(url_part)
    url_base = HocomocoSite::Application.config.relative_url_root || ''
    "#{url_base}/final_bundle/#{HOCOMOCO_VERSION}/#{url_part}"
  end

  def self.path_in_final_bundle(path_part, hocomoco_version: HOCOMOCO_VERSION, retracted: false)
    Rails.root.join("public/final_bundle/#{hocomoco_version}/#{path_part}")
  end

  def self.data_path(path_part, retracted: false)
    Rails.root.join("public/final_bundle/#{path_part}")
  end

  def self.indexed_by_motif_from_jsonl(filename)
    File.readlines(filename).map{|l|
      JSON.parse(l)
    }.map{|data|
      [data['name'], data]
    }.to_h
  end

  def self.bundle_v12_original_motif_names
    @cache_v12_bundle ||= indexed_by_motif_from_jsonl(HocomocoSiteUtils.data_path('hocomoco12_bundle.jsonl')) \
                            .transform_values{|d| d.dig('original_motif', 'name') }
  end

  def self.bundle_v11_original_motif_names
    @cache_v11_bundle ||= indexed_by_motif_from_jsonl(HocomocoSiteUtils.data_path('hocomoco11_bundle.jsonl')) \
                            .transform_values{|d| d['original_motif'] }
  end

  def self.bundle_v10_original_motif_names
    @cache_v10_bundle ||= indexed_by_motif_from_jsonl(HocomocoSiteUtils.data_path('hocomoco10_bundle.jsonl')) \
                            .transform_values{|d| d['original_motifs'] }
  end
end
