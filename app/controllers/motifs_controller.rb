class MotifsController < ApplicationController
  def show
    @species = params[:species].upcase
    @arity = params[:arity].downcase
    redirect_to root_path  unless ['HUMAN', 'MOUSE'].include?(@species)
    redirect_to root_path  unless ['mono', 'di'].include?(@arity)
    @models = Motif.each_in_file(Rails.root.join("public/final_bundle/#{@species}/#{@arity}/final_collection.tsv"))
    @models = MotifDecorator.decorate_collection(@models)
  end
end
