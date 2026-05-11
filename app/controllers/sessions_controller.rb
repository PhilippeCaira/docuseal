# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  # Fork OIDC : auto-redirect /sign_in vers le flow OIDC. Escape hatch ?local=1.
  # Skipper aussi pour `already_authenticated` (Devise redirige ici après
  # already signed in, on ne veut pas le renvoyer en boucle).
  before_action :auto_sso_redirect, only: [:new] # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :configure_permitted_parameters

  around_action :with_browser_locale

  def create
    email = sign_in_params[:email].to_s.downcase

    if Docuseal.multitenant? && !User.exists?(email:)
      Rollbar.warning('Sign in new user') if defined?(Rollbar)

      return redirect_to new_registration_path(sign_up: true, user: sign_in_params.slice(:email)),
                         notice: I18n.t('create_a_new_account')
    end

    if User.exists?(email:, otp_required_for_login: true) && sign_in_params[:otp_attempt].blank?
      return render :otp, locals: { resource: User.new(sign_in_params) }, status: :unprocessable_content
    end

    super
  end

  private

  def after_sign_in_path_for(...)
    if params[:redir].present?
      return console_redirect_index_path(redir: params[:redir]) if params[:redir].starts_with?(Docuseal::CONSOLE_URL)

      return params[:redir]
    end

    super
  end

  def auto_sso_redirect
    return if params[:local] == '1'
    return if user_signed_in?
    return if ENV['OIDC_CLIENT_ID'].blank?

    redirect_to '/auth/oidc', allow_other_host: false
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
  end

  def set_flash_message(key, kind, options = {})
    return if key == :alert && kind == 'already_authenticated'

    super
  end
end
