class User::UserRegistrationService
  include ErrorFormatter

  def self.call(user_params)
    new(user_params).call
  end

  def initialize(user_params)
    @user_params = user_params
  end

  def call
    return { success: false, error: I18n.t("errors.registration_disabled") } unless AppSetting.registration_enabled?

    user = User.new(@user_params)
    user.confirmed = false

    unless user.save
      return { success: false, errors: self.class.format_errors(user) }
    end

    token = user.generate_confirmation_token!

    # Send confirmation email
    if Rails.env.production?
      ResendRegistrationMailer.register(user: user, token: token)
    else
      RegistrationMailer.with(user: user, token: token).register.deliver_now
    end

    # Schedule deletion of unconfirmed user
    DeleteUnconfirmedUserJob.set(wait: 15.minutes).perform_later(user.id)

    { success: true, message: I18n.t("mailer.confirm_email.sent"), user: user }
  end
end
