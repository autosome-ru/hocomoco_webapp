module MotifClustersHelper
  def motif_cluster_table_header(attr, options = {}, &block)
    basic_options = {data:
      {
        text: I18n.t("activerecord.attributes.motif_cluster.#{attr}"),
      }
    }
    table_header I18n.t("activerecord.attributes.motif_cluster.#{attr}"), basic_options.merge(options), &block
  end

  # def motif_url(motif)
  #   motif_path(motif.full_name)
  # end

  def link_to_motif_cluster(motif_cluster, content, **kwargs)
    link_to(content, motif_cluster_url(motif_cluster.name), **kwargs)
  end

  def tfclass_link(tfclass_name, tfclass_id)
    inner_link = tfclass_family_inner_link(tfclass_id)
    outer_link = tfclass_family_link(tfclass_id, title: 'TFClass')
    "#{tfclass_name} {#{inner_link}} (#{outer_link})".html_safe
  end
end
