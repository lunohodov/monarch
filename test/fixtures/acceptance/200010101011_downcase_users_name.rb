User.find_each do |user|
  user.update_column(:name, user.name.downcase)
end
