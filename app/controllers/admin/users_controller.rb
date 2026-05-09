class Admin::UsersController < Admin::BaseController
  def index
    users = User.order(created_at: :asc)
    render inertia: "admin/users/Index", props: {
      users: users.map { |user| user_summary(user) }
    }
  end

  def show
    user = User.find(params[:id])
    render inertia: "admin/users/Show", props: {
      user: user_detail(user)
    }
  end

  private
    def user_summary(user)
      {
        id: user.id,
        email: user.email,
        admin: user.admin?,
        created_at: user.created_at.iso8601
      }
    end

    def user_detail(user)
      user_summary(user).merge(
        timezone: user.timezone,
        updated_at: user.updated_at.iso8601
      )
    end
end
