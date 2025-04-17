# app/services/quiz_loader.rb
require 'yaml'

class QuizLoader
  # 全てのクイズを読み込む（YAML形式 → Rubyのハッシュ）
  def self.load_all
    path = Rails.root.join("config/question.yml")
    raw_data = YAML.load_file(path)
    raw_data.map(&:symbolize_keys)
  end

  # ランダムで1問取得
  def self.random_quiz
    load_all.sample
  end

  # N番目の問題を取得（定時送信用など）
  def self.quiz_at(index)
    load_all[index % load_all.size] # indexが大きすぎても循環
  end
end

