require "test_helper"

class UserTest < ActiveSupport::TestCase
  should have_many(:added_projects).class_name("Project").with_foreign_key("added_by_user_id")
  should have_many(:owned_projects).class_name("Project").with_foreign_key("owner_user_id")
end
