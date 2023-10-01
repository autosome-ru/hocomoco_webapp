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

  def hgnc_ids; object.hgnc_ids.join('; '); end
  def mgi_ids; object.mgi_ids.join('; '); end
  def entrezgene_ids_human; object.entrezgene_ids_human.join('; '); end
  def entrezgene_ids_mouse; object.entrezgene_ids_mouse.join('; '); end
  def num_datasets; object.num_datasets == 0 ? nil : object.num_datasets; end
  def logo(**kwargs); helpers.link_to_motif(object, helpers.image_tag(object.direct_logo_url), **kwargs); end
  def big_logo
    helpers.link_to(
      helpers.image_tag(object.direct_big_logo_url),
      object.direct_large_logo_url
    )
  end
  def big_logo_revcomp
    helpers.link_to(
      helpers.image_tag(object.revcomp_big_logo_url),
      object.revcomp_large_logo_url
    )
  end
  def download_pcm; helpers.link_to("#{name}.pcm", object.pcm_url); end
  def download_pwm; helpers.link_to("#{name}.pwm", object.pwm_url); end
  def download_pfm; helpers.link_to("#{name}.pfm", object.pfm_url); end
  def download_alignment; helpers.link_to("#{name}.words.tsv", object.alignment_url); end
  def download_precalculated_thresholds; helpers.link_to("#{name}.thr", object.precalculated_thresholds_url); end

  def download_jaspar_motif; helpers.link_to("#{name}_jaspar_format.txt", object.jaspar_url); end
  def download_meme_motif; helpers.link_to("#{name}_meme_format.meme", object.meme_url); end
  def download_transfac_motif; helpers.link_to("#{name}_transfac_format.txt", object.transfac_url); end
  def download_homer_motif(pvalue:); helpers.link_to("#{name}_homer_format_#{pvalue}.txt", object.homer_url(pvalue: pvalue)); end

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
end
