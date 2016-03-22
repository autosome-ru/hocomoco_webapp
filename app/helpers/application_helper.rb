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

  def caption(arity, species, family_id: nil)
    @tf_ontology ||= {}
    @tf_ontology[species] ||= TFClassification.from_file(Rails.root.join("db/TFOntologies/TFClass_#{species.downcase}.obo"))
    result = ((arity == 'di') ? 'Dinucleotide PWMs' : 'PWMs') + " for #{species} transcription factors"
    if family_id && !family_id.blank?
      term = @tf_ontology[species].term(family_id)
      tfclass_name = "#{term.level_name.capitalize} {#{family_id}}"
      tfclass_link = link_to("http://tfclass.bioinf.med.uni-goettingen.de/tfclass?uniprot=#{family_id}", class: 'has-tooltip', data: {toggle: 'tooltip', placement: 'bottom', title: term.name}) do
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
    when 'mono'
      'Only primary high-quality models are shown by default. Use `A to D or S` to view all models.'
    when 'di'
      'Only high-quality models are shown by default. Use `A to D` to view all models.'
    end
  end

  def help_icon(href:, title:)
    content_tag :div, '', class: ['help-icon', 'has-tooltip'], data: {toggle: 'tooltip', placement: 'bottom', title: title, html: 'true', href: href}
  end
end
