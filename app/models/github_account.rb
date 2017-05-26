class GithubAccount < ActiveRecord::Base
  has_many :projects
  validates :name, presence: true, uniqueness: true
end
