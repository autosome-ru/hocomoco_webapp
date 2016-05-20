class MotifsController < ApplicationController
  def index
    species = params[:species].upcase
    arity = params[:arity].downcase
    redirect_to root_path  unless ['HUMAN', 'MOUSE'].include?(species)
    redirect_to root_path  unless ['mono', 'di'].include?(arity)
    models = Motif.in_bundle(species: species, arity: arity)
    respond_to do |format|
      format.html do
        models = MotifDecorator.decorate_collection(models)
        render locals: {
          models: models,
          species: species,
          arity: arity,
          csv_filename: "#{species}_#{arity}_motifs.tsv",
          family_id: nil,
          disable_default_filters: false
        }
      end
      format.json { render json: models.map(&:full_name) }
    end
  end

  def show
    species = params[:motif].split('.')[0].split('_').last.upcase
    bundle_name = params[:motif].split('.')[1].upcase
    arity = {'H10MO' => 'mono', 'H10DI' => 'di'}[bundle_name]
    motif = Motif.in_bundle(species: species, arity: arity).detect{|motif|
      motif.full_name == params[:motif]
    }
    respond_to do |format|
      format.html do
        motif = MotifDecorator.decorate(motif)
        render locals: {
          motif: motif,
          species: species,
          arity: arity,
          csv_filename: "#{species}_#{arity}_motifs.tsv"
        }
      end
      format.json { render locals: {motif: motif, with_thresholds: params[:with_thresholds], with_matrices: params[:with_matrices]} }
    end
  end

protected
  # def species; species; end
  # def arity; arity; end
  # def csv_filename; "#{species}_#{arity}_motifs.tsv"; end

  # helper_method :species, :arity, :csv_filename, :quality_help_text
end
