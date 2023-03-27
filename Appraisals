# We test against only supported Rails versions.
# https://guides.rubyonrails.org/maintenance_policy.html

# Rails 6.0.Z is included in the list of supported series until June 1st 2023.
appraise "rails_6.0" do
  gem "rails", "~> 6.0"
  gem "net-smtp", require: false
  gem "net-imap", require: false
  gem "net-pop", require: false
end

appraise "rails_6.1" do
  gem "rails", "~> 6.1"
  gem "net-smtp", require: false
  gem "net-imap", require: false
  gem "net-pop", require: false
end

appraise "rails_7.0" do
  gem "rails", "~> 7.0"
end
