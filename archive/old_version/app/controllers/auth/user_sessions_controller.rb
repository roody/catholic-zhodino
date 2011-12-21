# Contains authentication routines
class Auth::UserSessionsController < ApplicationController
    # GET
    # Opens the home page with the login section
    #
    def new
        render :template => "home"
    end

    # POST
    # Logs in the user
    #
    def create
        @user_session = Auth::UserSession.new({:login => params[:login], :password => params[:password]})
        @user_session.save

        render :template => "home"
    end

    # GET
    # Renders the signup page
    #
    def signup
        @user = Auth::User.new
        render :template => "auth/signup"
    end

    # POST
    # Registers a new user
    #
    def register
        @user = Auth::User.create params[:auth_user]
        if verify_recaptcha(:model => @user) && @user.save
            redirect_to :action => :create
        else
            render :template => "auth/signup"
        end
    end

    # POST
    # Logs out the user and destroys his session
    #
    def destroy
        @user_session = Auth::UserSession.find
        @user_session.destroy
        flash[:notice] = "Successfully logged out."
        render :template => "home"
    end

    # GET
    # renders the forgot password page
    #
    def forgot_password
        render :template => "auth/forgot_password"
    end

    # POST
    # generates a new password for the user and sends it to him
    #
    def send_password
        if params[:user].blank? || params[:user][:login].blank?
            flash[:error] = t("validation.login_blank")
        elsif !verify_recaptcha
            flash[:error] = t("validation.incorrect_code")
        else
            @user = Auth::User.find(:first, :conditions => {:login => params[:user][:login]})

            if @user.nil?
                flash[:error] = t("validation.no_such_user")
            else
                reset_password(@user)
            end
        end

        respond_to do |format|
            format.js { render :template => "auth/forgot_password" }
        end
    end

    private

    # Resets the <tt>user</tt> password
    #
    def reset_password(user)
        password = Auth::User.random_password(8)
        user.password = password
        user.password_confirmation = password
        user.transaction do
            begin
                if user.save
                    Emailer.deliver_password_notification(user.email, user.login, password)
                    flash[:notice] = t("common.password_updated")
                end
            rescue Exception => e
                flash[:error] = t("common.message_not_sent")
            end
        end

        user_session = Auth::UserSession.find
        user_session.destroy unless user_session.nil?
    end

end
