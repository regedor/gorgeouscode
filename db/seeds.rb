# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#

User.create(email: 'it.miguelfernandes@gmail.com', encrypted_password: '$2a$10$V9u9H4IQeBbc0DZ5BxJGV.IMhPjeHFIBV7Al38HBeh5...', reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 2, current_sign_in_at: '2015-12-21 11:50:11', last_sign_in_at: '2015-12-18 17:11:59', current_sign_in_ip: '127.0.0.1', last_sign_in_ip: '127.0.0.1', confirmation_token: nil, confirmed_at: '2015-12-18 17:11:59', confirmation_sent_at: nil, unconfirmed_email: nil, created_at: '2015-12-18 17:11:59', updated_at: '2015-12-21 11:50:11', provider: 'github', uid: '11519250', first_name: 'Miguel', last_name: 'Fernandes', gender: nil, facebook_photo_url: nil, google_photo_url: nil, github_photo_url: 'https://avatars.githubusercontent.com/u/11519250?v...', github_nickname: 'itmiguelfernandes', github_token: 'f595f78b6731645460555d9eb6e6524386ed43de')

Project.create(github_url: 'https://github.com/itmiguelfernandes/apiflat_book', github_owner: 'itmiguelfernandes', github_name: 'apiflat_book', github_forks: 0, github_watchers: 0, github_size: 30, github_private: false, github_homepage: nil, github_description: , github_fork: false, github_has_wiki: true, github_has_issues: true, github_open_issues: 0, github_pushed_at: '2015-12-18', github_created_at: '2015-07-28', github_collaborators: nil, analysed: false, analyse_updated_at: nil, github_info_updated_at: nil, created_at: '2015-12-21 11:50:27', updated_at: '2015-12-21 11:50:35', user_id: 1)
