# app/services/send_daily_quiz.rb
class SendDailyQuiz
  def self.run(user_id: ENV["LINE_USER_ID"])
    quiz = QuizLoader.quiz_at(Date.today.yday) # 日替わりで出題

    # ✅ クイズをキャッシュに保存（正誤判定で使う）
    Rails.cache.write("latest_quiz", quiz)

    text = <<~MSG
      🧠 今日のLinuxクイズ！

      【問題. #{quiz[:question]}】
      
      選択肢
        A: #{quiz[:choices][0]}
        B: #{quiz[:choices][1]}
        C: #{quiz[:choices][2]}

      ※ 回答は「A」「B」「C」で送ってね！
    MSG

    message = {
      type: 'text',
      text: text
    }

    client.push_message(user_id, message)
  end

  def self.client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token  = ENV['LINE_CHANNEL_TOKEN']
    end
  end
end
