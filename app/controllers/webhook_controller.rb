class WebhookController < ApplicationController

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']

    unless client.validate_signature(body, signature)
      return head :bad_request
    end

    events = client.parse_events_from(body)
    events.each do |event|
      Rails.logger.info "👤 LINE USER ID: #{event['source']['userId']}"
      case event
      when Line::Bot::Event::Message
        if event.type == Line::Bot::Event::MessageType::Text
          answer_text = event.message['text'].strip.upcase # "a" → "A"

          quiz = Rails.cache.read("latest_quiz")

          reply_text =
            if quiz.nil?
              "まだクイズは出題されていないよ！"
            else
              index = %w[A B C].index(answer_text)

              if index.nil?
                "回答は「A」「B」「C」で送ってね！"
              else
                selected = quiz[:choices][index]
                if selected == quiz[:answer]
                  "🎉 正解！すごい！"
                else
                  "😢 不正解… 正解は「#{quiz[:answer]}」だったよ"
                end
              end
            end

          message = { type: 'text', text: reply_text }
          client.reply_message(event['replyToken'], message)
        end
      end
    end

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end
end
