class MotifClusterDecorator < ApplicationDecorator
  delegate_all

  def representative_motif
    object.representative_motif.then{|m| h.link_to_motif(m, m.name) }
  end
  def representative_motif_uniprot; object.representative_motif_uniprot.join(', '); end

  def clustered_motifs
    object.clustered_motifs.map{|m| h.link_to_motif(m, m.name) }.join(',<br/>').html_safe
  end
  def clustered_motifs_uniprots; object.clustered_motifs_uniprots.join(', '); end
  def clustered_motifs_gene_symbols; object.clustered_motifs_gene_symbols.join(', '); end
  def clustered_motifs_gene_symbols_plus_families; object.clustered_motifs_gene_symbols_plus_families.join(', '); end

  def meta_keywords
    [
      *object.clustered_motifs_gene_symbols,
      *object.clustered_motifs_uniprots
    ].compact.map(&:strip).join(', ')
  end

  def direct_cluster_logo(**kwargs)
    helpers.link_to_motif_cluster(
      object, 
      helpers.image_tag(
        object.direct_cluster_logo_url,
        # height: 30,
        width: (object.cluster_length <= 20 ? 15 : 10) * object.cluster_length,
        alt: "#{object.name} motif cluster logo (#{self.clustered_motifs_gene_symbols} genes, #{self.clustered_motifs_uniprots} proteins)",
      ),
      **kwargs,
    )
  end

  def name(**kwargs)
    helpers.link_to_motif_cluster(object, "cluster:#{object.name}", **kwargs)
  end

  def primary_family
    h.tfclass_link_from_string_w_family(object.primary_family)
  end

  def primary_subfamily
    h.tfclass_link_from_string_w_family(object.primary_subfamily)
  end

  def clustered_motifs_gene_symbols_plus_families
    object.clustered_motifs_gene_symbols_plus_families.map{|motif_w_family|
      h.tfclass_link_from_string_w_family(motif_w_family)
    }.join(',<br/>').html_safe
  end
end
