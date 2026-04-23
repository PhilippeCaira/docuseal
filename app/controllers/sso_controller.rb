# frozen_string_literal: true

# Fork OIDC : endpoint GET qui render un form POST self-submitting vers
# /auth/oidc avec le CSRF token valide. Contourne la protection
# omniauth-rails_csrf_protection qui refuse GET sur /auth/oidc.
class SsoController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:start]

  def start
    render inline: <<~HTML, layout: false
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Redirecting to SSO…</title>
      </head>
      <body onload="document.forms[0].submit()">
        <form method="POST" action="/auth/oidc">
          <input type="hidden" name="authenticity_token" value="#{form_authenticity_token}">
          <noscript><button type="submit">Continue to SSO</button></noscript>
        </form>
      </body>
      </html>
    HTML
  end
end
