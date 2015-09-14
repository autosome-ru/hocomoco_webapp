class HocomocoController < ApplicationController
  def search
    species = params[:species]
    arity = params[:arity]
    redirect_to root_path  unless species && arity
    models = Motif.in_bundle(species: species, arity: arity)

    if params[:family_id]
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
      caption: caption(arity, species),
      quality_help_text: quality_help_text(arity)
    }
  end

  def home; end
  def downloads; end
  def tree
    render layout: 'bare'
  end
end
