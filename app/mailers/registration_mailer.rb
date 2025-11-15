class RegistrationMailer < ApplicationMailer
  def register
    @user = params[:user]
    @token = params[:token]

    frontend_url = ENV["FRONTEND_URL"]
    @url = "#{frontend_url}/confirm_registration?token=#{@token}"

    mail(
      to: @user.email,
      subject: I18n.t("mailer.confirm_email.subject"),
      from: "no-reply@trapezi.ge"
    )
  end
end
