class WelcomeMailer < ApplicationMailer
  def welcome
    @user = params[:user]

    mail(
      to: @user.email,
      subject: I18n.t("mailer.welcome.title"),
      from: "no-reply@trapezi.ge"
    )
  end
end
