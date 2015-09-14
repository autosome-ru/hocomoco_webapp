class HocomocoController < ApplicationController
  def search
    species = params[:species]
    arity = params[:arity]
    redirect_to root_path  unless species && arity
    models = Motif.in_bundle(species: species, arity: arity)

    if params[:family_id] && !params[:family_id].blank?
      models = models.select{|motif|
        motif.is_a_subfamily_member?(params[:family_id])
      }
    end

    models = MotifDecorator.decorate_collection(models)

    render 'motifs/index', locals: {
      models: models,
      species: species,
      arity: arity,
      csv_filename: "#{species}_#{arity}_motifs.tsv",
      family_id: params[:family_id],
      disable_default_filters: true
    }
  end

  def home; end
  def downloads; end
  def tree
    render layout: 'bare'
  end
end
