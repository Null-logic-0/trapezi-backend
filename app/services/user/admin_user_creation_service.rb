class User::AdminUserCreationService
  include ErrorFormatter

  def self.call(user_params)
    new(user_params).call
  end

  def initialize(user_params)
    @user_params = user_params
  end

  def call
    user = User.new(@user_params)

    if user.save
      { success: true, user: user }
    else
      { success: false, errors: self.class.format_errors(user) }
    end
  end
end
