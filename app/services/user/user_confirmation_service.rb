class User::UserConfirmationService
  def self.call(token)
    new(token).call
  end

  def initialize(token)
    @token = token
  end

  def call
    user = User.find_by(confirmation_token: @token)
    return { success: false, error: I18n.t("activerecord.errors.errors.invalid_token") } unless user
    return { success: false, error: I18n.t("activerecord.errors.errors.invalid_or_expired_token") } unless user.confirmation_token_valid?(15.minutes)

    user.update!(confirmed: true, confirmation_token: nil, confirmation_sent_at: nil)
    jwt = encode_token({ user_id: user.id })

    send_welcome_email(user)

    { success: true, user: user, token: jwt, message: I18n.t("mailer.welcome.title") }
  end

  private

  def encode_token(payload)
    JWT.encode(payload, Rails.application.secret_key_base, "HS256")
  end

  def send_welcome_email(user)
    if Rails.env.production?
      ResendWelcomeMailer.welcome(user: user)
    else
      WelcomeMailer.with(user: user).welcome.deliver_now
    end
  end
end
