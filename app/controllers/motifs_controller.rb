class MotifsController < ApplicationController
  def index
    species = params[:species].upcase
    @species = species
    arity = params[:arity].downcase
    redirect_to root_path  unless ['HUMAN', 'MOUSE'].include?(species)
    redirect_to root_path  unless ['mono', 'di'].include?(arity)
    models = Motif.in_bundle(species: species, arity: arity).reject(&:retracted?)

    show_full = true
    if !params['full'] || params['full'] && params['full'].to_s.downcase == 'false'
      show_full = false
      models = models.select{|motif| ['A','B','C'].include?(motif.quality) }.reject(&:retracted?)
      models = models.select{|motif| ['A','B','C'].include?(motif.quality) }
                     .reject(&:retracted?)
                     .group_by(&:uniprot_id)
                     .map{|uniprot_id, tf_models|
                       tf_models.sort_by(&:rank).first
                     }
    end

    respond_to do |format|
      format.html do
        models = MotifDecorator.decorate_collection(models)
        render locals: {
          models: models,
          species: species,
          arity: arity,
          csv_filename: "#{species}_#{arity}_motifs.tsv",
          family_id: nil,
          disable_default_filters: false,
          is_full: show_full,
          core_full_url: motifs_path(species: species, arity: arity, full: !show_full),
          switch_to_core_full: show_full ? 'Switch to CORE collection' : 'Switch to FULL collection',
          show_full_core_caption: (arity.to_s == 'mono'),
        }
      end
      format.json {
        if params[:summary]
          render locals: {motifs: models.reject(&:retracted?) }, template: 'motifs/summaries.json'
        else
          render json: models.map(&:full_name)
        end
      }
    end
  end

  def show
    motif = Motif.by_name(params[:motif])
    @species = motif.species

    respond_to do |format|
      format.html do
        motif = MotifDecorator.decorate(motif)
        render locals: {
          motif: motif,
          species: motif.species,
          arity: motif.arity,
          csv_filename: "#{motif.species}_#{motif.arity}_motifs.tsv"
        }
      end
      format.json { render locals: {motif: motif, with_thresholds: params[:with_thresholds], with_matrices: params[:with_matrices]} }
    end
  end

  def pwm
    motif = Motif.by_name(params[:motif])
    respond_to do |format|
      format.json {
       render json: motif.pwm.model.matrix
      }
    end
  end

  def pcm
    motif = Motif.by_name(params[:motif])
    respond_to do |format|
      format.json {
       render json: motif.pcm.model.matrix
      }
    end
  end

  def thresholds
    motif = Motif.by_name(params[:motif])
    respond_to do |format|
      format.json {
       render json: motif.threshold_pvalue_list
      }
    end
  end

protected

  # def species; species; end
  # def arity; arity; end
  # def csv_filename; "#{species}_#{arity}_motifs.tsv"; end

  # helper_method :species, :arity, :csv_filename, :quality_help_text
end
