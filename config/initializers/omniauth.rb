# frozen_string_literal: true

# OIDC via Zitadel (ou tout OpenID Connect provider)
# Activé via ENV['OIDC_CLIENT_ID']
if ENV['OIDC_CLIENT_ID'].present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :openid_connect,
             name: :oidc,
             scope: %i[openid email profile],
             response_type: :code,
             issuer: ENV.fetch('OIDC_ISSUER'),
             discovery: true,
             client_options: {
               identifier: ENV.fetch('OIDC_CLIENT_ID'),
               secret: ENV.fetch('OIDC_CLIENT_SECRET'),
               redirect_uri: "#{ENV.fetch('APP_URL', 'http://localhost:3000')}/auth/oidc/callback"
             }
  end

  OmniAuth.config.allowed_request_methods = [:post]
  OmniAuth.config.silence_get_warning = true
end
