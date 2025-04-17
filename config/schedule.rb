# config/schedule.rb

set :output, "log/cron.log"
env :PATH, ENV['PATH'] # 環境変数読み込み用（rbenvなど対応）

every 1.day, at: '6:00 pm' do
  command "cd /app && bin/rails runner 'SendDailyQuiz.run'"
end
