class MotifsController < ApplicationController
  def index
    collection = params.fetch(:collection, 'H12CORE').upcase
    models = Motif.in_bundle(collection: collection).reject(&:retracted?)
    show_full = true
    if params.fetch('full', 'true').to_s.downcase == 'false'
      show_full = false
      models = models.reject(&:retracted?).select{|model| model.motif_subtype == 0 }
    end

    respond_to do |format|
      format.html do
        models = MotifDecorator.decorate_collection(models)
        render locals: {
          models: models,
          collection: collection,
          csv_filename: "#{collection}_motifs.tsv",
          family_id: nil,
          disable_default_filters: false,
          is_full: show_full,
          core_full_url: motifs_path(full: !show_full),
          switch_to_core_full: show_full ? '🔃 Switch to primary subtypes' : '🔃 Switch to complete collection',
          show_full_core_caption: true,
        }
      end
      format.json do
        models = models.reject(&:retracted?)
        if params[:detailed]
          infos = {
            motifs: models,
            with_thresholds: params[:with_thresholds],
            with_matrices: params[:with_matrices],
          }
          render locals: infos, template: 'motifs/detailed_collection.json'
        elsif params[:summary]
          infos = {
            motifs: models,
          }
          render locals: infos, template: 'motifs/summaries.json'
        else
          render json: models.map(&:full_name)
        end
      end
    end
  end

  def show
    motif = Motif.by_name(params[:motif])

    respond_to do |format|
      format.html do
        motif = MotifDecorator.decorate(motif)
        render locals: {
          motif: motif,
          csv_filename: "#{motif.collection}_motifs.tsv"
        }
      end
      format.json do
        infos = {
          motif: motif,
          with_thresholds: params[:with_thresholds],
          with_matrices: params[:with_matrices],
        }
        render locals: infos
      end
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

  # def csv_filename; "#{collection}_motifs.tsv"; end

  # helper_method :csv_filename, :quality_help_text
end
