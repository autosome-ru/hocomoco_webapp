module MotifsHelper
  def motif_table_header(attr, options = {}, &block)
    table_header I18n.t("activerecord.attributes.motif.#{attr}"), options, &block
  end

  def motif_url(motif)
    motif_path(motif.full_name)
  end

  def link_to_motif(motif, content, **kwargs)
    link_to(content, motif_url(motif), **kwargs)
  end
end
