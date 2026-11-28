# frozen_string_literal: true

# The people chores can be assigned to. Managed from Settings.
class HouseholdMembersController < ApplicationController
  def create
    member = Current.user.household_members.build(params.permit(:name))
    if member.save
      redirect_to settings_path, notice: "#{member.name} added to your household."
    else
      redirect_to settings_path, inertia: { errors: { household: member.errors.full_messages.to_sentence } }
    end
  end

  def destroy
    member = Current.user.household_members.find(params[:id])
    member.destroy
    redirect_to settings_path, notice: "#{member.name} removed. Their chores are unassigned."
  end
end
