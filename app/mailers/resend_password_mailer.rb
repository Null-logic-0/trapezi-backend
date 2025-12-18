require "resend"

class ResendPasswordMailer
  Resend.api_key = Rails.application.credentials.dig(:resend, :api_key)

  def self.reset_email(user:, token:)
    frontend_url = ENV["FRONTEND_URL"]
    url = "#{frontend_url}/reset-password?token=#{token}"

    html_content = ApplicationController.renderer.render(
      template: "password_mailer/reset_email",
      assigns: { user: user, url: url }
    )

    Resend::Emails.send(
      {
        from: "no-reply@trapezi.ge",
        to: [ user.email ],
        subject: I18n.t("mailer.reset_password.subject"),
        html: html_content
      }
    )
  end
end
