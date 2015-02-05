namespace :weeks do

  desc "Generate next week"
  task create_week: :environment do
    friday = Date.today.end_of_week
    week_number = friday.strftime("%U").to_i
    Week.find_or_create_by(number: week_number, friday: friday)
  end
end
