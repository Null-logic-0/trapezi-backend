module User::TokenGenerator
  extend ActiveSupport::Concern

  def generate_password_reset_token!
    raw_token = SecureRandom.urlsafe_base64(32)

    update!(
      password_reset_token: raw_token,
      password_reset_sent_at: Time.current,
    )

    signed_token_for(raw_token)
  end

  def clear_password_reset_token!
    update!(password_reset_token: nil, password_reset_sent_at: nil)
  end

  def password_reset_token_valid?(expiry = 10.minutes)
    return false if password_reset_sent_at.nil?
    password_reset_sent_at > Time.current - expiry
  end

  def generate_confirmation_token!
    raw_token = SecureRandom.urlsafe_base64(32)

    update!(
      confirmation_token: raw_token,
      confirmation_sent_at: Time.current

    )
    raw_token
  end

  def confirmation_token_valid?(expiry = 15.minutes)
    return false if confirmation_sent_at.nil?
    confirmation_sent_at > Time.current - expiry
  end

  private

  def signed_token_for(raw_token)
    verifier.generate(raw_token)
  end

  def verifier
    ActiveSupport::MessageVerifier.new(
      Rails.application.secret_key_base,
      digest: "SHA256"
    )
  end
end
