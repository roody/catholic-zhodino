class Auth::User < ActiveRecord::Base
    acts_as_authentic 
end
