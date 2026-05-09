class Admin::DesignSystemController < Admin::BaseController
  def show
    render inertia: "admin/design-system"
  end
end
