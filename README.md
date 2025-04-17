項目 | ポイント
ngrok URLが403になる | config.hosts に正規表現 or 明示的に許可
RailsがAPIモード | protect_from_forgery は使えない
WebhookのCSRF対策 | Rails APIではもともと無効なので 記述不要
ルーティングミス | routes.rb の to: "controller#action" をアクションと揃える
MySQL接続失敗 | host: db & rails db:prepare の再実行が効く