class MotifDecorator < Draper::Decorator
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
  def uniprot_acs; object.uniprot_acs.join('; '); end
  def num_datasets; object.num_datasets == 0 ? nil : object.num_datasets; end
  def logo; helpers.link_to_motif(object, helpers.image_tag(object.direct_logo_path)); end
  def big_logo; helpers.image_tag(object.direct_big_logo_path) end
  def big_logo_revcomp; helpers.image_tag(object.revcomp_big_logo_path) end
  def model_arity_type; arity == 'mono' ? 'Mononucleotide' : 'Dinucleotide'; end
end
