Rails.application.routes.draw do

  mount Elastic::Engine => "/"
end
