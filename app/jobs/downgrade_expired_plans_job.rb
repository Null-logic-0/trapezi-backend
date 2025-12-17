class DowngradeExpiredPlansJob
  include Sidekiq::Job

  def perform
    downgrade_users
    downgrade_food_places_vip
  end

  private

  def downgrade_users
    User.where.not(plan: "free")
        .where("plan_expires_at <= ?", Time.current)
        .find_each(batch_size: 1000) do |user|
      user.downgrade_expired_plan
    end
  end

  def downgrade_food_places_vip
    FoodPlace.where(is_vip: true)
             .where.not(vip_expires_at: nil)
             .where("vip_expires_at <= ?", Time.current)
             .find_each(batch_size: 1000) do |food_place|
      food_place.downgrade_vip!
    end
  end
end
