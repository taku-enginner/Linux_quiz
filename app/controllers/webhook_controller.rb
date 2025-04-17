class WebhookController < ApplicationController
  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']

    return head :bad_request unless client.validate_signature(body, signature)

    events = client.parse_events_from(body)
    events.each do |event|
      next unless event.is_a?(Line::Bot::Event::Message)
      next unless event.type == Line::Bot::Event::MessageType::Text

      line_user_id = event['source']['userId']
      user = User.find_or_create_by(line_user_id: line_user_id)
      answer_text = event.message['text'].strip.downcase
      quiz = Rails.cache.read("latest_quiz")

      if quiz.nil?
        client.reply_message(event['replyToken'], {
          type: 'text',
          text: 'まだクイズは出題されていないよ！'
        })
        next
      end

      normalized_choices = quiz[:choices].map { |c| c.strip.downcase }

      unless normalized_choices.include?(answer_text)
        client.reply_message(event['replyToken'], {
          type: 'text',
          text: '選択肢の中から選んでね！'
        })
        next
      end

      is_correct = answer_text == quiz[:answer].strip.downcase
      already_answered = user.answers.exists?(question: quiz[:question])

      Answer.create!(
        user: user,
        question: quiz[:question],
        selected: answer_text,
        correct: is_correct
      )

      total = user.answers.count
      correct = user.answers.where(correct: true).count
      percentage = (correct.to_f / total * 100).round
      streak = current_streak(user)
      weekly = weekly_score(user)

      message = {
        type: 'flex',
        altText: 'クイズ結果です！',
        contents: {
          type: 'bubble',
          body: {
            type: 'box',
            layout: 'vertical',
            contents: [
              {
                type: 'text',
                text: is_correct ? "🎉 正解！すごい！" : "😢 不正解…",
                weight: 'bold',
                color: is_correct ? '#28a745' : '#dc3545',
                size: 'lg'
              },
              {
                type: 'text',
                text: "💡 解説: #{quiz[:explanation]}",
                wrap: true,
                margin: 'md'
              },
              { type: 'separator', margin: 'md' },
              {
                type: 'box',
                layout: 'vertical',
                margin: 'md',
                spacing: 'sm',
                contents: [
                  {
                    type: 'text',
                    text: "📊 正答率: #{total}問中#{correct}問（#{percentage}%）",
                    wrap: true
                  },
                  {
                    type: 'text',
                    text: "🔥 連続正解: #{streak}問",
                    wrap: true
                  },
                  {
                    type: 'text',
                    text: "📅 今週の正解: #{weekly[:correct]}/#{weekly[:total]}（#{weekly[:percentage]}%）",
                    wrap: true
                  },
                  {
                    type: 'text',
                    text: already_answered ? "🗂 この問題は復習だよ！" : "🆕 初めての出題だよ！",
                    color: '#888888',
                    wrap: true
                  }
                ]
              }
            ]
          }
        }
      }

      client.reply_message(event['replyToken'], message)
    end

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def current_streak(user)
    user.answers.order(created_at: :desc).take_while(&:correct).count
  end

  def weekly_score(user)
    from = 7.days.ago.beginning_of_day
    to = Time.zone.now.end_of_day
    answers = user.answers.where(created_at: from..to)
    total = answers.count
    correct = answers.where(correct: true).count
    percentage = total.positive? ? (correct.to_f / total * 100).round : 0

    {
      total: total,
      correct: correct,
      percentage: percentage
    }
  end
end
