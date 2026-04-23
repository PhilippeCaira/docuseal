# frozen_string_literal: true

# Fork OIDC : entrée SSO déclenchée par Traefik redirectregex sur `/`.
# Redirect direct vers la request phase OmniAuth (GET autorisé depuis
# que omniauth-rails_csrf_protection est retiré).
class SsoController < ApplicationController
  skip_authorization_check
  skip_before_action :authenticate_user!, raise: false

  def start
    redirect_to '/auth/oidc', allow_other_host: false
  end
end
