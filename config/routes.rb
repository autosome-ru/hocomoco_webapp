Rails.application.routes.draw do
  root 'hocomoco#home'
  get '/:collection' => 'motifs#index', constraints: {collection: /H12(CORE|INVIVO|INVITRO|RSNP)/i}, to: redirect{|path_params, req|
    if path_params[:format]
      "#{ENV['HOCOMOCO12_URL']}#{path_params[:collection]}.#{path_params[:format]}"
    else
      "#{ENV['HOCOMOCO12_URL']}#{path_params[:collection]}"
    end
  }
  get '/:collection' => 'motifs#index', constraints: {collection: /H13(CORE|INVIVO|INVITRO|RSNP)/i}, defaults: {collection: 'H13CORE'}, as: 'motifs'
  post '/search_post' => 'hocomoco#searchPost', as: 'search_post'
  get '/search' => 'hocomoco#search', as: 'search'
  get '/motif/:motif', constraints: {motif: /\w+_(HUMAN|MOUSE)\.H10(MO|DI)\.[ABCDS]/i}, to: redirect{|path_params, req|
    if path_params[:format]
      "#{ENV['HOCOMOCO10_URL']}motif/#{path_params[:motif]}.#{path_params[:format]}"
    else
      "#{ENV['HOCOMOCO10_URL']}motif/#{path_params[:motif]}"
    end
  }

  get '/motif/:motif', constraints: {motif: /\w+_(HUMAN|MOUSE)\.H11(MO|DI)\.\d.[ABCD]/i}, to: redirect{|path_params, req|
    if path_params[:format]
      "#{ENV['HOCOMOCO11_URL']}motif/#{path_params[:motif]}.#{path_params[:format]}"
    else
      "#{ENV['HOCOMOCO11_URL']}motif/#{path_params[:motif]}"
    end
  }

  get '/motif/:motif' => 'motifs#show', constraints: {motif: /\w+\.H12(CORE|INVIVO|INVITRO|RSNP)\.\d.P?S?M?.[ABCD]/i}, to: redirect{|path_params, req|
    if path_params[:format]
      "#{ENV['HOCOMOCO12_URL']}motif/#{path_params[:motif]}.#{path_params[:format]}"
    else
      "#{ENV['HOCOMOCO12_URL']}motif/#{path_params[:motif]}"
    end
  }

  get '/motif/:motif/pcm' => 'motifs#pcm', constraints: {motif: /\w+\.H12(CORE|INVIVO|INVITRO|RSNP)\.\d.P?S?M?.[ABCD]/i}, to: redirect{|path_params, req|
    if path_params[:format]
      "#{ENV['HOCOMOCO12_URL']}motif/#{path_params[:motif]}/pcm.#{path_params[:format]}"
    else
      "#{ENV['HOCOMOCO12_URL']}motif/#{path_params[:motif]}/pcm"
    end
  }

  get '/motif/:motif/pwm' => 'motifs#pwm', constraints: {motif: /\w+\.H12(CORE|INVIVO|INVITRO|RSNP)\.\d.P?S?M?.[ABCD]/i}, to: redirect{|path_params, req|
    if path_params[:format]
      "#{ENV['HOCOMOCO12_URL']}motif/#{path_params[:motif]}/pwm.#{path_params[:format]}"
    else
      "#{ENV['HOCOMOCO12_URL']}motif/#{path_params[:motif]}/pwm"
    end
  }

  get '/motif/:motif/thresholds' => 'motifs#thresholds', constraints: {motif: /\w+\.H12(CORE|INVIVO|INVITRO|RSNP)\.\d.P?S?M?.[ABCD]/i}, to: redirect{|path_params, req|
    if path_params[:format]
      "#{ENV['HOCOMOCO12_URL']}motif/#{path_params[:motif]}/thresholds.#{path_params[:format]}"
    else
      "#{ENV['HOCOMOCO12_URL']}motif/#{path_params[:motif]}/thresholds"
    end
  }

  get '/motif/:motif' => 'motifs#show', constraints: {motif: /\w+\.H13(CORE|INVIVO|INVITRO|RSNP)\.\d.P?S?M?G?I?B?.[ABCD]/i}, as: 'motif'
  get '/motif/:motif/pcm' => 'motifs#pcm', constraints: {motif: /\w+\.H13(CORE|INVIVO|INVITRO|RSNP)\.\d.P?S?M?G?I?B?.[ABCD]/i}, as: 'motif_pcm'
  get '/motif/:motif/pwm' => 'motifs#pwm', constraints: {motif: /\w+\.H13(CORE|INVIVO|INVITRO|RSNP)\.\d.P?S?M?G?I?B?.[ABCD]/i}, as: 'motif_pwm'
  get '/motif/:motif/thresholds' => 'motifs#thresholds', constraints: {motif: /\w+\.H13(CORE|INVIVO|INVITRO|RSNP)\.\d.P?S?M?G?I?B?.[ABCD]/i}, as: 'motif_thresholds'

  get '/downloads_v10' => 'hocomoco#downloads_v10', as: 'downloads_v10'
  get '/downloads_v11' => 'hocomoco#downloads_v11', as: 'downloads_v11'
  get '/downloads_v12' => 'hocomoco#downloads_v12', as: 'downloads_v12'
  get '/downloads_v13' => 'hocomoco#downloads_v13', as: 'downloads_v13'
  get '/downloads', to: redirect('/downloads_v13'), as: 'downloads'
  get '/download', to: redirect('/downloads_v13')

  get '/help' => 'hocomoco#help', as: 'help'
  get '/faq' => 'hocomoco#faq', as: 'faq'
  get '/api_description' => 'hocomoco#api_description', as: 'api_description'

  get '/tree' => 'hocomoco#tree'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
