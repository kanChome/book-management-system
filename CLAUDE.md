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

## コミットメッセージ規約
[Conventional Commits](https://www.conventionalcommits.org/)に従います。

### 形式
```
<type>(<scope>): <description>

<optional body>

<optional footer>
```

### タイプ
- **feat**: 新機能追加
- **fix**: バグ修正
- **docs**: ドキュメントのみの変更
- **style**: コードスタイルの変更（機能に影響なし）
- **refactor**: バグ修正や機能追加を伴わないコード変更
- **perf**: パフォーマンス改善
- **test**: テストの追加・修正
- **build**: ビルドシステムや依存関係の変更
- **ci**: CI/CD設定の変更
- **chore**: その他の変更

### 例
```
feat(auth): add JWT authentication

Implements JWT-based authentication for API endpoints
using Spring Security.

Closes #123
```

### 破壊的変更
- タイプ/スコープの後に`!`を付ける: `feat(api)!: remove deprecated endpoints`
- フッターに`BREAKING CHANGE:`を記載

## 最近の変更
1. **2025-01-14**: 初期実装計画とデータモデル定義
2. **2025-01-14**: OpenAPI仕様とクイックスタートガイド作成
3. **2025-01-14**: フェーズ0,1の設計ドキュメント完成
4. **2025-01-15**: Conventional Commitsガイドライン追加

## 次のステップ
- /tasksコマンドでタスクリスト生成
- 契約テストの実装
- ドメインモデルの実装