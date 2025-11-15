class PasswordMailer < ApplicationMailer
  def reset_email
    @user = params[:user]
    @token = params[:token]

    frontend_url = ENV["FRONTEND_URL"]
    @url = "#{frontend_url}/reset-password?token=#{@token}"

    mail(
      to: @user.email,
      subject: I18n.t("mailer.reset_password.subject"),
      from: "no-reply@trapezi.ge"
    )
  end
end
