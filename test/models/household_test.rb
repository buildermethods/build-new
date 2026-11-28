require "test_helper"

class HouseholdTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.tasks.destroy_all
    @sam = @user.household_members.create!(name: "Sam")
    @alex = @user.household_members.create!(name: "Alex")
    @jo = @user.household_members.create!(name: "Jo")
  end

  def chore(**attrs)
    @user.tasks.create!({ title: "Bins", recurrence_kind: "completion", recurrence_interval_days: 1, assignee: @sam, rotate: true }.merge(attrs))
  end

  test "people keep their order and names are unique per household" do
    assert_equal %w[Sam Alex Jo], @user.household_members.map(&:name)
    assert_not @user.household_members.build(name: "sam").valid?
    assert users(:two).household_members.build(name: "Sam").valid?
  end

  test "a household holds at most eight people" do
    5.times { |i| @user.household_members.create!(name: "P#{i}") }
    assert_not @user.household_members.build(name: "Ninth").valid?
  end

  test "a take-turns chore passes to the next person each time, wrapping round" do
    task = chore
    order = 4.times.map do
      task.complete!(today: @user.today)
      task.update!(next_due_on: nil)
      task.reload.assignee.name
    end
    assert_equal %w[Alex Jo Sam Alex], order
  end

  test "undoing a completion gives the turn back" do
    task = chore
    task.complete!(today: @user.today)
    assert_equal @alex, task.reload.assignee
    task.uncomplete!
    assert_equal @sam, task.reload.assignee
  end

  test "an assigned chore without take-turns keeps its person" do
    task = chore(rotate: false)
    task.complete!(today: @user.today)
    assert_equal @sam, task.reload.assignee
  end

  test "you cannot assign a chore to someone else's household member" do
    theirs = users(:two).household_members.create!(name: "Stranger")
    assert_not @user.tasks.build(title: "x", assignee: theirs).valid?
  end

  test "removing a person leaves their chores unassigned" do
    task = chore
    @sam.destroy
    assert_nil task.reload.assignee
  end
end
