AssmntsWs::Application.routes.draw do
  resources :exports

  resources :applicants do
    member do
      get "profile"
      get "rescore"
    end
  end
  resources :company, :only => [:index] do
    member do
      get "search"
      post "select"
      get "qa_summary"
    end
  end

  resources :stages do
    resources :assessors, :only => [:new, :create] 
    member do
      get "import"
      get "applicants"
      get "assessors"
      get "details"
      get "rescore"
    end
  end
  
  resources :welcome, :only => [:index] do
    collection do
      get :admin
      get :project
      get :company
      get :citizen
      get :opps
    end
  end
  resources :scores
  devise_for :users
  
  resources :assessors,:only => [:show, :edit, :update, :destroy]
  
  resources :jobs, :only => [:index] do
    member do
      get "view"
      get "apply"
    end
  end
  
  resources :citizens, :except => [:index, :destroy] 
  
  match 'citizen/find' => 'citizens#find'
  match 'citizen/lookup' => 'citizens#lookup'
  match 'citizen/:id' => 'citizens#get'
  
  resources :ws do
    member do
      get "get_xml_assmnt"
      get "get_stages"
      get "update_4d"
      get "conv_score"
      get "test"
      
    end
    collection do
      get "ruok"
      get "getwork"
      get "getprofile"
    end
  end

    # Sample resource route within a namespace:
     namespace :admin do
       # Directs /admin/products/* to Admin::ProductsController
       resources :dba, :only => [:index] do
         collection do
           get "assessors"
           get "users"
         end
       end
       
       resources :assessments do
         member do
           post :post
           get :clone
           get :display
         end
         collection do
           get :group
         end
         resources :questions, :only => [:index, :new, :create] 
       end

       resources :questions, :only => [:show, :edit, :update, :destroy] do
         resources :answers, :only => [:index, :new, :create] 
       end
       resources :answers, :only => [:show, :edit, :update, :destroy]
       
     end
    #match 'job/apply' => 'actions#take'
    match 'apply/:action' => 'apply#:action'
    #match ':controller/:action/:id/:assessed/:assessed_id'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end


  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  root :to => "welcome#index"
  match '*a', :to => 'errors#routing'
end
