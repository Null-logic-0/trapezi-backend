require "resend"

class ResendWelcomeMailer
  Resend.api_key = Rails.application.credentials.dig(:resend, :api_key)

  def self.welcome(user:)
    html_content = ApplicationController.renderer.render(
      template: "welcome_mailer/welcome",
      assigns: { user: user }
    )

    Resend::Emails.send(
      {
        from: "no-reply@trapezi.ge",
        to: [ user.email ],
        subject: I18n.t("mailer.welcome.title"),
        html: html_content
      }
    )
  end
end
