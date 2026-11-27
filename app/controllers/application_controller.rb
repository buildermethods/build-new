class ApplicationController < ActionController::Base
  include Authentication

  allow_browser versions: :modern

  inertia_share do
    {
      current_user: Current.user && {
        id: Current.user.id,
        email: Current.user.email,
        timezone: Current.user.timezone,
        admin: Current.user.admin?
      },
      flash: {
        notice: flash.notice,
        alert: flash.alert,
        victory: flash[:victory]
      },
      player: Current.user && Current.user.progress.as_player_json
    }
  end
end
