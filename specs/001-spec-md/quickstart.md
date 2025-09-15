# クイックスタートガイド: 書籍管理システム

## 前提条件

- Docker Desktop がインストールされていること
- JDK 21 がインストールされていること
- Gradle 8.x がインストールされていること

## セットアップ手順

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd book-management-system
```

### 2. データベースの起動

```bash
docker-compose up -d postgres
```

PostgreSQLが起動するまで待機:
```bash
docker-compose ps
# postgres コンテナが "Up" になることを確認
```

### 3. データベースマイグレーションの実行

```bash
./gradlew flywayMigrate
```

### 4. JOOQコード生成

```bash
./gradlew generateJooq
```

### 5. アプリケーションのビルド

```bash
./gradlew clean build
```

### 6. アプリケーションの起動

```bash
./gradlew bootRun
```

アプリケーションが起動したら、以下のURLでアクセス可能:
- API: http://localhost:8080/api/v1
- Health Check: http://localhost:8080/actuator/health

## 動作確認シナリオ

### シナリオ1: 著者の登録

```bash
# 著者を登録
curl -X POST http://localhost:8080/api/v1/authors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "エリック・エヴァンス",
    "birthDate": "1970-01-01"
  }'

# レスポンス例
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "エリック・エヴァンス",
  "birthDate": "1970-01-01",
  "createdAt": "2025-01-14T10:00:00Z",
  "updatedAt": "2025-01-14T10:00:00Z"
}
```

著者IDを環境変数に保存:
```bash
export AUTHOR_ID="123e4567-e89b-12d3-a456-426614174000"
```

### シナリオ2: 書籍の登録（未出版）

```bash
# 書籍を登録（未出版状態）
curl -X POST http://localhost:8080/api/v1/books \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"ドメイン駆動設計\",
    \"price\": 3500,
    \"publishStatus\": \"UNPUBLISHED\",
    \"authorIds\": [\"$AUTHOR_ID\"]
  }"

# レスポンス例
{
  "id": "456e7890-e89b-12d3-a456-426614174111",
  "title": "ドメイン駆動設計",
  "price": 3500,
  "publishStatus": "UNPUBLISHED",
  "authors": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "エリック・エヴァンス"
    }
  ],
  "createdAt": "2025-01-14T10:01:00Z",
  "updatedAt": "2025-01-14T10:01:00Z"
}
```

書籍IDを環境変数に保存:
```bash
export BOOK_ID="456e7890-e89b-12d3-a456-426614174111"
```

### シナリオ3: 書籍を出版済みに更新

```bash
# 書籍のステータスを出版済みに変更
curl -X PUT http://localhost:8080/api/v1/books/$BOOK_ID \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"ドメイン駆動設計\",
    \"price\": 3500,
    \"publishStatus\": \"PUBLISHED\",
    \"authorIds\": [\"$AUTHOR_ID\"]
  }"

# 正常に更新されることを確認
```

### シナリオ4: 出版済みから未出版への変更を試みる（エラー確認）

```bash
# 出版済みから未出版への変更（エラーが返ることを確認）
curl -X PUT http://localhost:8080/api/v1/books/$BOOK_ID \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"ドメイン駆動設計\",
    \"price\": 3500,
    \"publishStatus\": \"UNPUBLISHED\",
    \"authorIds\": [\"$AUTHOR_ID\"]
  }"

# エラーレスポンス例
{
  "type": "/errors/business-rule-violation",
  "title": "Business Rule Violation",
  "status": 400,
  "detail": "出版済みの書籍を未出版に変更することはできません",
  "instance": "/api/v1/books/456e7890-e89b-12d3-a456-426614174111"
}
```

### シナリオ5: 著者に紐づく書籍を取得

```bash
# 著者が執筆した書籍一覧を取得
curl -X GET http://localhost:8080/api/v1/authors/$AUTHOR_ID/books

# レスポンス例
[
  {
    "id": "456e7890-e89b-12d3-a456-426614174111",
    "title": "ドメイン駆動設計",
    "price": 3500,
    "publishStatus": "PUBLISHED",
    "authors": [
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "name": "エリック・エヴァンス"
      }
    ],
    "createdAt": "2025-01-14T10:01:00Z",
    "updatedAt": "2025-01-14T10:02:00Z"
  }
]
```

### シナリオ6: バリデーションエラーの確認

```bash
# 価格が負の値でエラー
curl -X POST http://localhost:8080/api/v1/books \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"テスト書籍\",
    \"price\": -100,
    \"publishStatus\": \"UNPUBLISHED\",
    \"authorIds\": [\"$AUTHOR_ID\"]
  }"

# エラーレスポンスが返ることを確認
```

```bash
# 生年月日が未来でエラー
curl -X POST http://localhost:8080/api/v1/authors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "未来の著者",
    "birthDate": "2030-01-01"
  }'

# エラーレスポンスが返ることを確認
```

## テストの実行

### ユニットテスト
```bash
./gradlew test
```

### 統合テスト
```bash
./gradlew integrationTest
```

### 契約テスト
```bash
./gradlew contractTest
```

### すべてのテスト
```bash
./gradlew check
```

## トラブルシューティング

### データベース接続エラー
```bash
# PostgreSQLコンテナの状態を確認
docker-compose ps

# ログを確認
docker-compose logs postgres

# 再起動
docker-compose restart postgres
```

### ポート競合
```bash
# 8080ポートが使用中の場合
lsof -i :8080
# 使用中のプロセスを終了するか、application.ymlでポートを変更
```

### JOOQコード生成エラー
```bash
# データベースマイグレーションが完了しているか確認
./gradlew flywayInfo

# 未適用のマイグレーションがある場合
./gradlew flywayMigrate
```

## クリーンアップ

```bash
# アプリケーションの停止
Ctrl + C

# データベースの停止
docker-compose down

# データベースのデータも削除する場合
docker-compose down -v
```