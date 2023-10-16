class MotifDecorator < ApplicationDecorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end


  # def auc
  #   object.auc && object.auc.round(3)
  # end

  # def max_auc
  #   object.max_auc && object.max_auc.round(3)
  # end

  def datasets
    object.datasets.join('; <br/>').html_safe
  end

  def origin_models
    object.origin_models.join('; <br/>').html_safe
  end

  # def hgnc_ids; object.hgnc_ids.join('; '); end
  # def mgi_ids; object.mgi_ids.join('; '); end
  # def entrezgene_ids_human; object.entrezgene_ids_human.join('; '); end
  # def entrezgene_ids_mouse; object.entrezgene_ids_mouse.join('; '); end
  def num_datasets; object.num_datasets == 0 ? nil : object.num_datasets; end
  def logo(**kwargs)
    helpers.link_to_motif(
      object, 
      helpers.image_tag(
        object.direct_logo_url,
        height: 30,
        width: (object.length <= 20 ? 15 : 10) * motif.length,
        alt: "#{object.name} motif logo (#{object.gene_name_human} gene, #{object.uniprot_id_human} protein)",
      ),
      **kwargs,
    )
  end
  def big_logo
    helpers.link_to(
      helpers.image_tag(
        object.direct_big_logo_url,
        height: 60,
        width: 30 * motif.length,
        alt: "#{object.name} motif logo (#{object.gene_name_human} gene, #{object.uniprot_id_human} protein)",
      ),
      object.direct_large_logo_url,
    )
  end
  def big_logo_revcomp
    helpers.link_to(
      helpers.image_tag(
        object.revcomp_big_logo_url,
        height: 60,
        width: 30 * motif.length,
        alt: "#{object.name} reverse-complement motif logo (#{object.gene_name_human} gene, #{object.uniprot_id_human} protein)",
      ),
      object.revcomp_large_logo_url,
    )
  end
  def download_pcm; helpers.link_to("#{name}.pcm", object.pcm_url, rel: 'nofollow'); end
  def download_pwm; helpers.link_to("#{name}.pwm", object.pwm_url, rel: 'nofollow'); end
  def download_pfm; helpers.link_to("#{name}.pfm", object.pfm_url, rel: 'nofollow'); end
  def download_alignment; helpers.link_to("#{name}.words.tsv", object.alignment_url, rel: 'nofollow'); end
  def download_precalculated_thresholds; helpers.link_to("#{name}.thr", object.precalculated_thresholds_url, rel: 'nofollow'); end

  def download_jaspar_motif; helpers.link_to("#{name}_jaspar_format.txt", object.jaspar_url, rel: 'nofollow'); end
  def download_meme_motif; helpers.link_to("#{name}_meme_format.meme", object.meme_url, rel: 'nofollow'); end
  def download_transfac_motif; helpers.link_to("#{name}_transfac_format.txt", object.transfac_url, rel: 'nofollow'); end
  def download_homer_motif(pvalue:); helpers.link_to("#{name}_homer_format_#{pvalue}.txt", object.homer_url(pvalue: pvalue), rel: 'nofollow'); end

  def format_matrix_as_table(matrix, round: nil)
    nucleotides = ['A', 'C', 'G', 'T']
    letters = nucleotides
    header = helpers.content_tag(:thead){
      helpers.content_tag(:tr){
        [nil, *letters].map{|letter|
          helpers.content_tag(:th, letter)
        }.join.html_safe
      }
    }

    body = helpers.content_tag(:tbody){
      matrix.each_with_index.map{|pos, index|
        helpers.content_tag(:tr){
          pos_rounded = pos.map{|el| round ? el.round(round) : el}
          ['%02d' % (index + 1), *pos_rounded].map{|cell|
            helpers.content_tag(:td, cell)
          }.join.html_safe
        }
      }.join.html_safe
    }

    helpers.content_tag(:table, (header + body).html_safe, class: 'matrix')
  end

  def pcm
    format_matrix_as_table(object.pcm, round: 3)
  end

  def pwm
    format_matrix_as_table(object.pwm, round: 3)
  end

  def pfm
    format_matrix_as_table(object.pfm, round: 3)
  end

  def full_name(**kwargs)
    helpers.link_to_motif(object, object.retracted? ? (object.full_name + ' ' + 'RETRACTED!!!') : object.full_name, **kwargs)
  end

  def comment
    object.retracted? ? ('Retracted motif!' + h.tag('br') + object.comment).html_safe : object.comment
  end

  def best_auc_human; object.best_auc_human&.round(3); end
  def best_auc_mouse; object.best_auc_mouse&.round(3); end

  def data_sources_full
    object.data_sources.each_char.map{|k|
      {'P' => 'ChIP-Seq', 'S' => 'HT-SELEX', 'M' => 'Methyl-HT-SELEX'}.fetch(k){|k| $stderr.puts "Error: datatype `#{k}` unknown" }
    }.join(' + ')
  end

  def gc_content; "#{(object.gc_content * 100).round(2)}%" ; end
  def information_content_total; object.information_content_total.round(3); end
  def information_content_per_base; object.information_content_per_base.round(3); end

  def gene_name_human; object.gene_name_human && h.human_gene_name_link(object.gene_name_human); end
  def gene_name_mouse; object.gene_name_mouse && h.mouse_gene_name_link(object.gene_name_mouse); end

  def tfclass_at_level_text(level)
    tfclass_id = object.tfclass_id_at_level(level)
    "#{object.tfclass_at_level(level)} {#{tfclass_id}}"
  end
  def tfclass_at_level(level)
    tfclass_id = object.tfclass_id_at_level(level)
    inner_link = h.tfclass_family_inner_link(tfclass_id)
    outer_link = h.tfclass_family_link(tfclass_id, title: 'TFClass')
    "#{object.tfclass_at_level(level)} {#{inner_link}} (#{outer_link})".html_safe
  end
  def tfclass_superclass; tfclass_at_level(1); end
  def tfclass_class; tfclass_at_level(2); end
  def tfclass_family; tfclass_at_level(3); end
  def tfclass_subfamily; tfclass_at_level(4); end
  def tfclass_id
    "TFClass: #{h.tfclass_family_link(object.tfclass_id, title: object.tfclass_id)}".html_safe
  end
  def uniprot_ac_human; object.uniprot_ac_human && h.uniprot_ac_and_tfclass_link(object.uniprot_ac_human); end
  def uniprot_ac_mouse; object.uniprot_ac_mouse && h.uniprot_ac_and_tfclass_link(object.uniprot_ac_mouse); end
  def entrezgene_ids_human; h.gene_id_links(object.entrezgene_ids_human); end
  def entrezgene_ids_mouse; h.gene_id_links(object.entrezgene_ids_mouse); end
  def hgnc_ids; h.hgnc_id_links(object.hgnc_ids); end
  def mgi_ids; h.mgi_id_links(object.mgi_ids); end
  def uniprot_id_human; object.uniprot_id_human && h.uniprot_id_link(object.uniprot_id_human); end
  def uniprot_id_mouse; object.uniprot_id_mouse && h.uniprot_id_link(object.uniprot_id_mouse); end
end
