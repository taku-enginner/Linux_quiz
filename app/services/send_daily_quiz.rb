class SendDailyQuiz
  def self.run(user_id: ENV["LINE_USER_ID"])
    quiz = QuizLoader.quiz_at(Date.today.yday)
    Rails.cache.write("latest_quiz", quiz)

    labels = %w[A B C D]

    options_text = quiz[:choices].map.with_index do |choice, i|
      "#{labels[i]}: #{choice}"
    end.join("\n")

    question_text = "🧠 今日のLinuxクイズ！\n\n#{quiz[:question]}\n\n#{options_text}"

    message = {
      type: 'template',
      altText: question_text.truncate(400),
      template: {
        type: 'buttons',
        title: 'Linuxクイズ',
        text: quiz[:question],
        actions: quiz[:choices].map.with_index do |choice, i|
          {
            type: 'message',
            label: choice,     # ボタンに表示される文字 → cd, ls, mkdir
            text: choice    # 実際に送られるメッセージ → A, B, C
          }
        end
      }
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
