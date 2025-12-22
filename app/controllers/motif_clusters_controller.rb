class MotifClustersController < ApplicationController
  def index
    models = MotifCluster.all
    respond_to do |format|
      format.html do
        models = MotifClusterDecorator.decorate_collection(models)
        render(locals: {
          models: models,
          csv_filename: "motif_clusters.tsv",
          disable_default_filters: false,
        })
      end
      format.json do
        if params[:detailed]
          render(locals: { motif_clusters: models }, template: 'motif_clusters/detailed.json')
        else
          render(json: models.map(&:name))
        end
      end
    end
  end

  def show
    motif_cluster = MotifCluster.by_name(params[:name])
    redirect_to motif_cluster_url(motif_cluster.name) and return  if motif_cluster.name != params[:name]

    respond_to do |format|
      format.html do
        render locals: {
          motif_cluster: MotifClusterDecorator.decorate(motif_cluster),
          csv_filename: "cluster_#{motif_cluster.name}.tsv"
        }
      end
      format.json do
        render(locals: { motif_cluster: motif_cluster })
      end
    end
  end
end