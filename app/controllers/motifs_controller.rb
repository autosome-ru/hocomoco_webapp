class MotifsController < ApplicationController
  def index
    @species = params[:species].upcase
    @arity = params[:arity].downcase
    redirect_to root_path  unless ['HUMAN', 'MOUSE'].include?(species)
    redirect_to root_path  unless ['mono', 'di'].include?(arity)
    @models = Motif.in_bundle(species: species, arity: arity)
    @models = MotifDecorator.decorate_collection(@models)
  end

  def show
    @species = params[:motif].split('.')[0].split('_').last.upcase
    bundle_name = params[:motif].split('.')[1].upcase
    @arity = {'H10MO' => 'mono', 'H10DI' => 'di'}[bundle_name]
    @motif = Motif.in_bundle(species: species, arity: arity).detect{|motif|
      motif.full_name == params[:motif]
    }
    @motif = MotifDecorator.decorate(@motif)
  end

protected
  def species; @species; end
  def arity; @arity; end
  def csv_filename; "#{species}_#{arity}_motifs.tsv"; end
  def caption
    ((arity == 'di') ? 'Dinucleotide PWMs' : 'PWMs') + " for #{species} transcription factors"
  end
  helper_method :species, :arity, :csv_filename
end
