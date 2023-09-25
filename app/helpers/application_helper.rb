require 'csv'

def masterlist
  @cached_masterlist ||= CSV.readlines(Rails.root.join('public/masterlist.tsv'), headers: true, col_sep: "\t").map(&:to_h)
end

def tfclass_name_by_id
  @cached_tfclass_name_by_id ||= begin
    masterlist.flat_map{|d|
      [
        [d['tfclass:id'].split('.').first(1).join('.'), {level_name: 'Superclass', name: d['tfclass:superclass']}],
        [d['tfclass:id'].split('.').first(2).join('.'), {level_name: 'Class', name: d['tfclass:class']}],
        [d['tfclass:id'].split('.').first(3).join('.'), {level_name: 'Family', name: d['tfclass:family']}],
        [d['tfclass:id'].split('.').first(4).join('.'), {level_name: 'Subfamily', name: d['tfclass:subfamily']}],
      ]
    }.uniq.tap{|pairs|
      raise unless pairs.map(&:first).uniq.size == pairs.size
    }.to_h
  end
end

module ApplicationHelper
  def table_info_row(obj, attrib, html_options: {}, header_cell: nil, &block)
    key_column = content_tag(:td, html_options[:key_column_html]) do
      header_cell || I18n.t("activerecord.attributes.#{ActiveSupport::Inflector.underscore(obj.class.model_name)}.#{attrib}").html_safe
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
      (block_given? ? block.call(content) : content).html_safe
    end
  end

  def download_button
    content_tag :button, 'Get TSV', class: ['btn', 'btn-sm', 'btn-outline-secondary', 'download', 'has-tooltip'],
                                    type: 'button',
                                    data: { toggle: 'tooltip',
                                            placement: 'right',
                                            title: 'CSV export works in Firefox / Google Chrome / IE 11 only.'
                                          }
  end

  def caption(collection: nil, family_id: nil, full: false, show_full_core_caption: true)
    result = ""
    # result += image_tag("#{species.downcase}_sel.png", class: 'species-indicator')
    result += {
      'H12CORE' => 'v12 Core collection',
      'H12INVIVO' => 'In vivo collection',
      'H12INVITRO' => 'In vitro collection',
      'H12RSNP' => 'rSNP collection',
    }.fetch(collection, '')
    result += full ? ' (complete)' : ' (primary subtypes)'  if show_full_core_caption
    term = tfclass_name_by_id[family_id]
    if term
      tfclass_name = "#{term[:level_name]} {#{family_id}}"
      tfclass_link = link_to(tfclass_name, "http://tfclass.bioinf.med.uni-goettingen.de/?tfclass=#{family_id}")

      (result + ", #{tfclass_link}: #{term[:name]}").html_safe
    else
      result.html_safe
    end
  end

  def quality_help_text
    "A - reproducible in distinct datatypes, B - reproducible in a single datatype, C - comes from a single dataset, D - can't verify of ChIP-seq/SELEX data"
  end

  def help_icon(title:, href: nil, **options)
    data_options = options.merge({toggle: 'tooltip', placement: 'bottom', title: title})
    data_options[:href] = href  if href
    content_tag(:div, '', class: ['help-icon', 'has-tooltip'], data: data_options)
  end

  # "abc, def" --> "{decorated abc}, {decorated def}"
  def decorate_list(str, splitter: ", ", joiner: ", ", &decorating_block)
    return nil  if !str
    str.split(splitter).map(&decorating_block).join(joiner).html_safe
  end

  def hgnc_id_url(hgnc_id)
    "https://www.genenames.org/cgi-bin/gene_symbol_report?hgnc_id=#{hgnc_id}"
  end
  def hgnc_id_link(hgnc_id, name: nil)
    link_to((name || "HGNC:#{hgnc_id}"), hgnc_id_url(hgnc_id))
  end
  def hgnc_id_links(hgnc_ids)
    decorate_list(hgnc_ids){|hgnc_id| hgnc_id_link(hgnc_id) }
  end

  def mgi_url(mgi_id)
    "https://www.informatics.jax.org/marker/MGI:#{mgi_id}"
  end
  def mgi_id_link(mgi_id, name: nil)
    link_to((name || "MGI:#{mgi_id}"), mgi_url(mgi_id))
  end
  def mgi_id_links(mgi_ids)
    decorate_list(mgi_ids){|mgi_id| mgi_id_link(mgi_id) }
  end

  def fantom_sstar_gene_link(gene_id)
    link_to('SSTAR profile', "https://fantom.gsc.riken.jp/5/sstar/EntrezGene:#{gene_id}")
  end
  def gene_id_link(gene_id)
    [
      link_to("GeneID:#{gene_id}", "https://www.ncbi.nlm.nih.gov/gene/#{gene_id}"),
      '<br/>',
      "(#{ fantom_sstar_gene_link(gene_id) })"
    ].join.html_safe
  end
  def gene_id_links(gene_ids)
    decorate_list(gene_ids){|gene_id| gene_id_link(gene_id) }
  end

  def human_gene_name_link(gene_name)
    [
      link_to(gene_name, "https://www.genenames.org/cgi-bin/gene_symbol_report?match=#{gene_name}"),
      '<br/>',
      '(',
      link_to('GeneCards', "https://www.genecards.org/cgi-bin/carddisp.pl?gene=#{gene_name}"),
      ')'
    ].join.html_safe
  end

  def human_gene_name_links(gene_names)
    gene_names.map{|gene_name| human_gene_name_link(gene_name) }.join('<br/>').html_safe
  end

  def mouse_gene_name_link(gene_name)
    link_to(gene_name, "https://www.informatics.jax.org/marker/summary?nomen=#{gene_name}")
  end

  def mouse_gene_name_links(gene_names)
    gene_names.map{|gene_name| mouse_gene_name_link(gene_name) }.join('<br/>').html_safe
  end

  def tfclass_uniprot_link(uniprot_ac, title: 'TFClass')
    link_to(title, "http://tfclass.bioinf.med.uni-goettingen.de/?uniprot=#{uniprot_ac}")
  end

  def tfclass_family_link(family_id, title: 'TFClass')
    link_to(title, "http://tfclass.bioinf.med.uni-goettingen.de/?tfclass=#{family_id}")
  end

  def tfclass_family_inner_link(family_id, collection: 'H12CORE')
    link_to("#{family_id}", "/search?collection=#{collection}&family_id=#{family_id}")
  end

  def tfclass_motif_family_link(family)
    tfclass = family[/\{(.+?)\}/, 1]
    if tfclass
      from = '{' + tfclass + '}'
      to = ' {' + tfclass_family_link(tfclass, title: tfclass) + '}'
      family.sub(from, to);
    else
      family
    end
  end

  def tfclass_motif_family_links(families)
    decorate_list(families, splitter: '; <br/>', joiner: '<br/>'){|family| tfclass_motif_family_link(family) }
  end

  def uniprot_id_link(uniprot_id)
    link_to uniprot_id, "https://www.uniprot.org/uniprot/#{uniprot_id}"
  end

  def uniprot_ac_link(uniprot_ac)
    link_to(uniprot_ac, "https://www.uniprot.org/uniprot/#{uniprot_ac}")
  end

  def uniprot_ac_and_tfclass_link(uniprot_ac)
    [
      uniprot_ac_link(uniprot_ac),
      '<br/>',
      '(' + tfclass_uniprot_link(uniprot_ac) + ')'
    ].join.html_safe
  end
end
