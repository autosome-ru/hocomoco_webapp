require 'tf_ontology'

module ApplicationHelper
  def table_info_row(obj, attrib, html_options: {}, header_cell: nil, &block)
    key_column = content_tag(:td, html_options[:key_column_html]) do
      header_cell || I18n.t("activerecord.attributes.#{ActiveSupport::Inflector.underscore(obj.class.model_name)}.#{attrib}")
    end
    value_column = content_tag(:td, html_options[:value_column_html]) do
      if block_given?
        block.call(obj).to_s
      else
        obj.send(attrib).to_s
      end
    end
    content_tag(:tr, html_options[:row_html]) do
      (key_column + value_column).html_safe
    end
  end

  def table_header(content, options = {}, &block)
    klasses = []
    klasses << 'sorter-false'  if options.delete(:dont_sort)
    klasses << 'columnSelector-disable'  if options.delete(:show_always)  
    klasses << 'columnSelector-false'  if options.delete(:hide_by_default)
    if options[:class]
      klasses += options[:class]  if options[:class].is_a? Array
      klasses += options[:class].split(/[\s,]/)  if options[:class].is_a? String
    end
    content_tag :th, options.merge(class: klasses.uniq) do
      block_given? ? block.call(content) : content
    end
  end

  def download_button
    content_tag :button, 'Get CSV', class: ['download', 'has-tooltip'],
                                    type: 'button',
                                    data: { toggle: 'tooltip',
                                            placement: 'right',
                                            title: 'CSV export works in Firefox / Google Chrome / IE 11 only.'
                                          }
  end

  def caption(arity, species, family_id: nil, full: false, show_full_core_caption: true)
    @tf_ontology ||= {}
    @tf_ontology[species] ||= TFClassification.from_file(Rails.root.join("db/TFOntologies/TFClass_#{species.downcase}.obo"))
    result = ""
    # result += image_tag("#{species.downcase}_sel.png", class: 'species-indicator')
    result += ((arity == 'di') ? 'Dinucleotide PWMs' : 'PWMs') + " for #{species} transcription factors"
    result += full ? ' (full)' : ' (core)'  if show_full_core_caption
    if family_id && !family_id.blank?
      term = @tf_ontology[species].term(family_id)
      tfclass_name = "#{term.level_name.capitalize} {#{family_id}}"
      tfclass_link = link_to("http://tfclass.bioinf.med.uni-goettingen.de/?tfclass=#{family_id}", class: 'has-tooltip', data: {toggle: 'tooltip', placement: 'bottom', title: term.name}) do
        help_icon = content_tag(:div, '', class: ['help-icon'])
        (tfclass_name + help_icon).html_safe
      end

      (result + " from #{tfclass_link}").html_safe
    else
      result.html_safe
    end
  end

  def quality_help_text(arity)
    case arity
    when 'mono', 'di'
      'A - excellent, B - good, C - normal, D - limited reliability'
    end
  end

  def help_icon(title:, href: nil)
    data_options = {toggle: 'tooltip', placement: 'bottom', title: title}
    data_options[:href] = href  if href
    content_tag(:div, '', class: ['help-icon', 'has-tooltip'], data: data_options)
  end

  # "abc, def" --> "{decorated abc}, {decorated def}"
  def decorate_list(str, splitter: ", ", joiner: ", ", &decorating_block)
    str.split(splitter).map(&decorating_block).join(joiner).html_safe
  end

  def hgnc_id_url(hgnc_id)
    "http://www.genenames.org/cgi-bin/gene_symbol_report?hgnc_id=#{hgnc_id}"
  end
  def hgnc_id_link(hgnc_id, name: nil)
    link_to((name || "HGNC:#{hgnc_id}"), hgnc_id_url(hgnc_id))
  end
  def hgnc_id_links(hgnc_ids)
    decorate_list(hgnc_ids){|hgnc_id| hgnc_id_link(hgnc_id) }
  end

  def mgi_url(mgi_id)
    # "http://www.informatics.jax.org/searchtool/Search.do?query=MGI:#{mgi_id}"
    "http://www.informatics.jax.org/marker/MGI:#{mgi_id}"
  end
  def mgi_id_link(mgi_id, name: nil)
    link_to((name || "MGI:#{mgi_id}"), mgi_url(mgi_id))
  end
  def mgi_id_links(mgi_ids)
    decorate_list(mgi_ids){|mgi_id| mgi_id_link(mgi_id) }
  end

  def fantom_sstar_gene_link(gene_id)
    link_to('SSTAR profile', "http://fantom.gsc.riken.jp/5/sstar/EntrezGene:#{gene_id}")
  end
  def gene_id_link(gene_id)
    [
      link_to("GeneID:#{gene_id}", "http://www.ncbi.nlm.nih.gov/gene/#{gene_id}"),
      '<br/>',
      "(#{ fantom_sstar_gene_link(gene_id) })"
    ].join.html_safe
  end
  def gene_id_links(gene_ids)
    decorate_list(gene_ids){|gene_id| gene_id_link(gene_id) }
  end
end
