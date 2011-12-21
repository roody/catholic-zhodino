class HomeController < ApplicationController
    #  Shows the home page
    def index
        render :template => 'home'
    end
end
