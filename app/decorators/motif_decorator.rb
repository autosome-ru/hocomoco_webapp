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

  def motif_families
    object.motif_families.join('; <br/>').html_safe
  end

  def motif_subfamilies
    object.motif_subfamilies.join('; <br/>').html_safe
  end

  def hgnc_ids; object.hgnc_ids.join('; '); end
  def mgi_ids; object.mgi_ids.join('; '); end
  def entrezgene_ids; object.entrezgene_ids.join('; '); end
  def gene_names; object.gene_names.join('; '); end
  def human_prefixed_gene_name; "HUMAN:#{object.gene_name_human}"; end
  def mouse_prefixed_gene_name; "MOUSE:#{object.gene_name_mouse}"; end
  def mouse_prefixed_gene_synonyms; object.gene_synonyms_mouse.map{|gene_name| "MOUSE:#{gene_name}" }.join('; '); end
  def human_prefixed_gene_synonyms; object.gene_synonyms_human.map{|gene_name| "HUMAN:#{gene_name}" }.join('; '); end
  def uniprot_acs; object.uniprot_acs.join('; '); end
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
  def download_pcm; helpers.link_to('pcm', object.pcm_url); end
  def download_pwm; helpers.link_to('pwm', object.pwm_url); end
  def download_alignment; helpers.link_to('alignment', object.alignment_url); end
  def download_precalculated_thresholds; helpers.link_to('threshold to P-value grid', object.precalculated_thresholds_url); end

  def format_matrix_as_table(matrix, round: nil)
    nucleotides = ['A', 'C', 'G', 'T']
    letters = (arity == 'mono') ? nucleotides : nucleotides.product(nucleotides).map(&:join)
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
    format_matrix_as_table(object.pcm.matrix, round: 3)
  end

  def pwm
    format_matrix_as_table(object.pwm.matrix, round: 3)
  end

  def full_name(**kwargs)
    helpers.link_to_motif(object, object.retracted? ? (object.full_name + ' ' + 'RETRACTED!!!') : object.full_name, **kwargs)
  end

  def comment
    object.retracted? ? ('Retracted motif!' + h.tag('br') + object.comment).html_safe : object.comment
  end

  def best_auc_human; object.best_auc_human&.round(3); end
  def best_auc_mouse; object.best_auc_mouse&.round(3); end
end
