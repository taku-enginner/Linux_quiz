# LinuxクイズBot（LINE連携）

毎日1問、LINEにLinuxコマンドのクイズが届く、学習サポート用のLINE Botです。  
技術学習の継続を楽しく、自然に習慣化できることを目指しています。

---

## ✨ 主な機能

### 📮 クイズ配信（毎日1問）

- YAMLで管理されたLinuxクイズを1日1問、LINEに自動送信
- 「ファイル操作」「検索コマンド」など初学者向けの実用問題を中心に収録
- Flex Message形式で出題、選択肢をタップするだけで回答可能

### ✅ 回答判定 & 解説返信

- 回答直後に正誤判定＋正解解説を表示
- 直感的でわかりやすいUI（Flex Messageカード）

### 🧠 学習状態の可視化

- 正答率（全体 / 週間）
- 連続正解数（streak）
- 出題済み or 初出題の判定表示

### 💾 回答履歴の保存

- ユーザーごとの回答履歴をデータベースに記録（User / Answer モデル）
- 回答内容・正誤・日時が記録され、スコア表示に反映されます

### 🔁 毎日自動配信（cron）

- `whenever` + `cron` により、開発環境で定時出題を自動化済み
- 任意の時間に合わせて出題タイミングを調整可能

---

## 🛠️ 技術構成

| 項目                   | 使用技術                         |
|------------------------|----------------------------------|
| フレームワーク         | Ruby on Rails（APIモード）       |
| データベース           | MySQL                            |
| LINE連携               | [line-bot-sdk-ruby](https://github.com/line/line-bot-sdk-ruby) |
| フロント（Bot UI）     | LINE Flex Message（JSON形式）   |
| タスクスケジューリング | whenever + cron（開発環境）     |
| コンテナ               | Docker / Docker Compose          |

---

## 📷 スクリーンショット（例）

> 🎯 正解！すごい！  
> 💡 解説: ls は list の略で、ディレクトリ内のファイル一覧を表示します  
> 📊 正答率: 5問中4問正解（80%）  
> 🔥 連続正解: 3問  
> 📅 今週の正解: 6/7（85%）  
> 🆕 初めての出題です！

※ 上記のようなレイアウトは、LINEのFlex Messageを使ってカード形式で表示されます。

---

## 🚀 今後の拡張予定（アイデア）

- 成績ページ（WebUI）の追加
- 出題カテゴリごとの切り替え（例：パーミッション / 検索 / ネットワーク）
- 未出題 or 間違えた問題のみを出す「復習モード」
- 他ユーザーにも配布可能なQRコード連携

---

## 📚 開発背景

「Linuxのコマンドを覚えたいけど、まとまった時間が取れない」  
「繰り返し練習したいけど、何をやればいいか分からない」

そんな課題感から、「毎日1問LINEに届く」という仕組みを通じて、  
**楽しく、継続的にLinux学習できる体験を作りたい**という思いで開発しました。

---

## 👤 作者

- 開発・設計・構築：[@taku-enginner](https://github.com/taku-enginner)
- 利用技術・開発背景などの詳細はポートフォリオまたはQiita記事を参照予定

---

## 📬 お問い合わせ
- このBotは個人開発の技術検証として運用されています。  
- 気になる点やフィードバックがあれば、お気軽にGitHub上でIssueを立ててください!
---

## 起動手順（開発用メモ）

数日後に忘れていそうな自分のための備忘録です。  
Docker + ngrok を使って開発環境でBotを動かすための手順です。

### 1. Docker起動

```bash
docker compose -f compose-dev.yaml up
```

### 2. 別ターミナルでwebコンテナに入る

```bash
docker compose -f compose-dev.yaml exec web sh
```

### 3. ngrok起動

```bash
ngrok http 3000
```

表示された `https://xxxxx.ngrok-free.app` を控えておく。

### 4. ngrokのドメインをRailsに許可

```ruby
# config/environments/development.rb
config.hosts << /[a-z0-9\-]+\.ngrok\.io/
```

変更したら `docker compose ... up` を再起動。

### 5. LINE DevelopersでWebhook URLを更新

Webhook URLに以下を入力：

```
https://xxxxx.ngrok-free.app/webhook
```

「利用する」をONにして保存。

### 6. クイズを手動で送信

```bash
docker compose -f compose-dev.yaml exec web rails runner "SendDailyQuiz.run"
```

`.env` に `LINE_USER_ID` を設定しておくこと。
```
