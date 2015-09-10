class MotifsController < ApplicationController
  def show
    @models = Motif.each_in_file(Rails.root.join('public/final_bundle/HUMAN/mono/final_collection.tsv'))
    @models = MotifDecorator.decorate_collection(@models)
  end
end
