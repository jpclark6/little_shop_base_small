class CouponController < ApplicationController
  before_action :restrict_access

  def create

  end

  def restrict_access
    render file: 'errors/not_found', status: 404 unless current_user && (current_merchant? || current_admin?)
  end
end
