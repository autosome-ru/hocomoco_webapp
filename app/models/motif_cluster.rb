# 1 Representative_Motif  GABPA.H14CORE.0.PSM.A
# 2 Average_Similarity  0.444
# 3 Min_Similarity  0.207
# 4 Cluster_Size  37
# 5 Clustered_Motifs  E4F1.H14CORE.0.P.B; EHF.H14CORE.0.P.B; ELF1.H14CORE.0.PSM.A; ELF2.H14CORE.0.PS.A; ELF2.H14CORE.1.M.B; ELF3.H14CORE.0.S.B; ELF3.H14CORE.1.PM.A; ELF4.H14CORE.0.PS.A; ELF4.H14CORE.1.M.B; ELF5.H14CORE.0.PSM.A; ELF5.H14CORE.1.S.B; ELK1.H14CORE.0.PSM.A; ELK3.H14CORE.0.PSM.A; ELK4.H14CORE.0.PSM.A; ERF.H14CORE.0.PS.A; ERG.H14CORE.0.P.B; ERG.H14CORE.1.SM.B; ETS1.H14CORE.0.S.B; ETS1.H14CORE.1.P.B; ETS2.H14CORE.0.S.C; ETS2.H14CORE.1.P.B; ETV1.H14CORE.0.PSM.A; ETV1.H14CORE.1.PM.A; ETV2.H14CORE.0.S.B; ETV2.H14CORE.1.PM.A; ETV3.H14CORE.0.SM.B; ETV4.H14CORE.0.P.B; ETV4.H14CORE.1.SM.B; ETV5.H14CORE.0.PS.A; ETV5.H14CORE.1.PM.A; ETV6.H14CORE.0.PS.A; ETV6.H14CORE.1.P.B; ETV7.H14CORE.0.SM.B; FEV.H14CORE.0.S.B; FLI1.H14CORE.0.PSM.A; FLI1.H14CORE.1.P.B; GABPA.H14CORE.0.PSM.A
# 6 Primary_Family  Ets-related {3.5.2}
# 7 Primary_Subfamily ETS-like {3.5.2.1}
# 8 Representative_Motif_Gene_Symbol  GABPA
# 9 Clustered_Motifs_Gene_Symbols E4F1; ETS1; ETS1; ERF; ETS2; ETS2; ETV2; ETV2; GABPA; FLI1; FLI1; ERG; ERG; FEV; ETV3; ELK1; ELK3; ELK4; ETV1; ETV1; ETV4; ETV4; ETV5; ETV5; ELF1; ELF2; ELF2; ELF4; ELF4; EHF; ELF3; ELF3; ELF5; ELF5; ETV6; ETV6; ETV7
# 10  Clustered_Motifs_Gene_Symbols_Plus_Families E4F1 {2.3.4.0.74}; ETS1 {3.5.2.1.1}; ETS1 {3.5.2.1.1}; ERF {3.5.2.1.11}; ETS2 {3.5.2.1.2}; ETS2 {3.5.2.1.2}; ETV2 {3.5.2.1.4}; ETV2 {3.5.2.1.4}; GABPA {3.5.2.1.5}; FLI1 {3.5.2.1.6}; FLI1 {3.5.2.1.6}; ERG {3.5.2.1.7}; ERG {3.5.2.1.7}; FEV {3.5.2.1.8}; ETV3 {3.5.2.1.9}; ELK1 {3.5.2.2.1}; ELK3 {3.5.2.2.2}; ELK4 {3.5.2.2.3}; ETV1 {3.5.2.2.4}; ETV1 {3.5.2.2.4}; ETV4 {3.5.2.2.5}; ETV4 {3.5.2.2.5}; ETV5 {3.5.2.2.6}; ETV5 {3.5.2.2.6}; ELF1 {3.5.2.3.1}; ELF2 {3.5.2.3.2}; ELF2 {3.5.2.3.2}; ELF4 {3.5.2.3.3}; ELF4 {3.5.2.3.3}; EHF {3.5.2.4.1}; ELF3 {3.5.2.4.2}; ELF3 {3.5.2.4.2}; ELF5 {3.5.2.4.3}; ELF5 {3.5.2.4.3}; ETV6 {3.5.2.6.1}; ETV6 {3.5.2.6.1}; ETV7 {3.5.2.6.2}

MotifCluster = Struct.new(
  :representative_motif, :average_similarity, :min_similarity, :cluster_size,
  :clustered_motifs, :primary_family, :primary_subfamily, :representative_motif_gene_symbol,
  :clustered_motifs_gene_symbols, :clustered_motifs_gene_symbols_plus_families,
) do
  def self.model_name; 'MotifCluster'; end
  def self.from_string(str)
    representative_motif, average_similarity, min_similarity, cluster_size,  \
      clustered_motifs, primary_family, primary_subfamily, representative_motif_gene_symbol,  \
      clustered_motifs_gene_symbols, clustered_motifs_gene_symbols_plus_families = str.chomp.split("\t")
    self.new(representative_motif, Float(average_similarity), Float(min_similarity), Integer(cluster_size),  \
      clustered_motifs.split(';').map(&:strip),
      primary_family, primary_subfamily, representative_motif_gene_symbol,  \
      clustered_motifs_gene_symbols.split(';').map(&:strip).uniq,
      clustered_motifs_gene_symbols_plus_families.split(';').map(&:strip).uniq)
  end

  def self.all
    filename = 'public/final_bundle/hocomoco14/H14CORE-CLUSTERED/cluster_list.tsv'
    @clusters_cache ||= File.readlines(filename).drop(1).map{|l| self.from_string(l) }
  end

  def self.by_name(motif)
    @cluster_by_motif_cache ||= self.all.each_with_object(Hash.new){|cluster, hsh|
      cluster.clustered_motifs.each{|motif|
        hsh[motif.full_name] = cluster
      }
    }
    @cluster_by_motif_cache[motif]
  end

  def name; self['representative_motif']; end
  def representative_motif; Motif.by_name(self['representative_motif']); end
  def clustered_motifs; self['clustered_motifs'].map{|motif| Motif.by_name(motif) }; end

  def representative_motif_uniprot; self['representative_motif'].split('.').first + '_HUMAN'; end
  def clustered_motifs_uniprots; self['clustered_motifs'].map{|motif| motif.split('.').first + '_HUMAN' }.uniq; end
  def direct_representative_logo_url; self.representative_motif.direct_logo_url; end # ToDo: use joint cluster logo

  def direct_cluster_logo_url
    url_in_final_bundle("H14CORE-CLUSTERED/cluster_logos/cluster@#{name}.png")
  end
  def representative_length; self.representative_motif.length; end
  def cluster_length; self.clustered_motifs.map(&:length).max; end

  def url_in_final_bundle(url_part)
    HocomocoSiteUtils.url_in_final_bundle("#{url_part}")
  end
  end
