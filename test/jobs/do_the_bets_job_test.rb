require 'test_helper'

class DoTheBetsJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "asks the admins to place the bets" do
    travel_to Date.new(2026, 11, 13) do
      assert_emails 1 do
        DoTheBetsJob.perform_now
      end
      mail = ActionMailer::Base.deliveries.last
      assert_equal User.where(is_admin: true).pluck(:email), mail.to
      assert_equal "Re: [Euromilhões] 13/11/2026", mail.subject
    end
  end

  test "does nothing once the proof of the bet is uploaded" do
    travel_to Date.new(2026, 11, 13) do
      Week.current.update!(weeks_bet: Rack::Test::UploadedFile.new(file_fixture("proof.png"), "image/png"))
      assert_no_emails do
        DoTheBetsJob.perform_now
      end
    end
  end
end
