# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: [:oidc]

    def oidc
      auth = request.env['omniauth.auth']
      email = auth.info.email
      return redirect_to new_user_session_path, alert: 'OIDC: email missing in provider response' if email.blank?

      user = User.find_by(email: email.downcase)

      if user.nil?
        account = Account.first || Account.create!(name: 'Default')
        user = User.new(
          email: email.downcase,
          first_name: auth.info.name.to_s.split(' ').first.presence || 'SSO',
          last_name: auth.info.name.to_s.split(' ').last.presence || 'User',
          password: SecureRandom.hex(24),
          account: account,
          role: User::ADMIN_ROLE,
          confirmed_at: Time.current
        )
        user.save!
      end

      sign_in_and_redirect user, event: :authentication
    end

    def failure
      redirect_to new_user_session_path, alert: "OIDC authentication failed: #{failure_message}"
    end
  end
end
