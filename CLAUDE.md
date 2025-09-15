# CLAUDE.md - 書籍管理システム

## プロジェクト概要
書籍と著者の管理を行うバックエンドAPIシステム。SpringBoot、JOOQ、クリーンアーキテクチャを使用。

## 技術スタック
- **言語**: Kotlin (Java 21)
- **フレームワーク**: SpringBoot 3.5.5
- **DB**: PostgreSQL 16 + JOOQ
- **マイグレーション**: Flyway
- **テスト**: JUnit 5, MockK, TestContainers
- **ビルド**: Gradle (Groovy)
- **コンテナ**: Docker, Docker Compose

## アーキテクチャ
クリーンアーキテクチャ（buckpalパターン）
```
domain/     # ビジネスロジック
application/ # ユースケース
adapter/    # 外部インターフェース
  in/web/   # REST API
  out/persistence/ # DB永続化
```

## 開発手法
**TDD (Test-Driven Development)**
1. RED: テストを書く（失敗する）
2. GREEN: 実装してテストを通す
3. REFACTOR: リファクタリング

テスト順序: Contract → Integration → E2E → Unit

## 主要コマンド
```bash
# DB起動
docker-compose up -d postgres

# マイグレーション
./gradlew flywayMigrate

# JOOQコード生成
./gradlew generateJooq

# ビルド＆テスト
./gradlew clean build

# アプリケーション起動
./gradlew bootRun
```

## API仕様
- POST /api/v1/books - 書籍登録
- PUT /api/v1/books/{id} - 書籍更新
- POST /api/v1/authors - 著者登録
- PUT /api/v1/authors/{id} - 著者更新
- GET /api/v1/authors/{id}/books - 著者の書籍取得

## ビジネスルール
- 書籍は最低1人の著者が必要
- 価格は0以上
- 出版済み→未出版への変更は不可
- 生年月日は過去の日付のみ
- 同姓同名の著者は許可

## 最近の変更
1. **2025-01-14**: 初期実装計画とデータモデル定義
2. **2025-01-14**: OpenAPI仕様とクイックスタートガイド作成
3. **2025-01-14**: フェーズ0,1の設計ドキュメント完成

## 次のステップ
- /tasksコマンドでタスクリスト生成
- 契約テストの実装
- ドメインモデルの実装