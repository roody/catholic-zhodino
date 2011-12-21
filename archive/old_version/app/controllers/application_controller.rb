# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

    helper :all # include all helpers, all the time
    helper_method :current_user_session, :current_user
    
    protect_from_forgery # See ActionController::RequestForgeryProtection for details

    layout "main"

    after_filter :discard_flash

    # Scrub sensitive parameters from your log
    filter_parameter_logging :password

    #Redirect to public exception page.
    #Comment this method if you want to a see local exception page.
    def rescue_action_locally(exception)
        rescue_action_in_public(exception)
    end

    #Show public exception page.
    def rescue_action_in_public(exception)
        logger.error exception

        case exception
            when ActiveRecord::RecordNotFound, ActionController::RoutingError, ActionController::UnknownAction
                error_404
            when SecurityError
                error_403
            else
                error_500
        end
    end

    #Show resource not foud page.
    def error_404
        if !request.xhr?
            render :template  => "errors/404", :status  => "404 Error"
        else
            respond_to do |format|
                format.json {render :json => {
                        :error => "404",
                        }, :status => "404"}
            end
        end
    end

    #Show accesss denied page.
    def error_403
        if !request.xhr?
            render :template  => "errors/403", :status  => "403 Error"
        else
            respond_to do |format|
                format.json {render :json => {
                        :error => "403",
                        }, :status => "403"}
            end
        end
    end

    #Show internal error page.
    def error_500
        if !request.xhr?
            render :template  => "errors/500", :status  => "500 Internal Server Error"
        else
            respond_to do |format|
                format.json {render :json => {
                        :error => "500",
                        }, :status => "500"}
            end
        end
    end

    #Call this method if user login required.
    def require_user
        unless current_user
            store_location
            flash[:warning] = t("common.login_required")
            redirect_to login_url
            return false
        end
    end

    #Call this method if user role required.
    def require_role
        action = request.params[:action]
        if (current_user && action.starts_with?(current_user.role_str))

        else
            store_location
            error_403
            return false
        end
    end

    # Sets the current menu item
    def select_menu(menu_item)
        session[:active_menu] = menu_item
    end

    private

    def current_user_session
        return @current_user_session if defined?(@current_user_session)
        @current_user_session = UserSession.find
      end

      def current_user
        return @current_user if defined?(@current_user)
        @current_user = current_user_session && current_user_session.user
      end

    # Clears the flash object
    #
    def discard_flash
        flash.discard
    end

    #Store request in session.
    def store_location
        session[:return_to] = request.request_uri if not current_user
    end

end
