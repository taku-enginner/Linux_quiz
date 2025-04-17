## ✅ 今回の学びまとめ

| 項目                      | ポイント                                                                 |
|---------------------------|--------------------------------------------------------------------------|
| ngrok URL が 403 になる   | `config.hosts` に正規表現 (`/.*\.ngrok-free\.app/`) またはドメイン名を追加 |
| Rails が API モード       | `protect_from_forgery` は使えない。CSRF 無効化の記述は不要              |
| Webhook の CSRF 対策     | Rails API では CSRF 保護がもともと無効なので設定不要                     |
| ルーティングミス          | `routes.rb` の `to: "controller#action"` がコントローラと一致しているか確認 |
| MySQL 接続失敗           | `host: db` にして、`rails db:prepare` を後から実行                       |
