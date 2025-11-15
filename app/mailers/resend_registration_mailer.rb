require "resend"

class ResendRegistrationMailer
  Resend.api_key = Rails.application.credentials.dig(:resend, :api_key)

  def self.register(user:, token:)
    frontend_url = ENV["FRONTEND_URL"]
    url = "#{frontend_url}/signup/confirm?token=#{token}"

    html_content = ApplicationController.renderer.render(
      template: "registration_mailer/register",
      assigns: { user: user, url: url }
    )

    Resend::Emails.send(
      {
        from: "no-reply@trapezi.ge",
        to: [ user.email ],
        subject: I18n.t("mailer.confirm_email.subject"),
        html: html_content
      }
    )
  end
end
