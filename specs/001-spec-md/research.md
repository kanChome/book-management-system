# リサーチドキュメント: 書籍管理システム

**日付**: 2025-09-14
**機能**: 書籍管理システムバックエンドAPI

## 技術スタックの決定事項

### 1. SpringBoot 4.xとJOOQの統合

**決定**: SpringBoot Starter JOOQを使用した統合
**根拠**:
- SpringBootの自動設定により、JOOQのDSLContext等が自動的にBeanとして登録される
- トランザクション管理がSpringのアノテーションベースで簡潔に実装可能
- DataSourceの管理をSpringBootに委譲できる

**検討した代替案**:
- 手動でJOOQを設定: より細かい制御が可能だが、ボイラープレートコードが増える
- MyBatis/JPA: より一般的だが、タイプセーフなクエリビルダーが弱い

**実装方法**:
```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-jooq:3.2.0'
    implementation 'org.jooq:jooq:3.19.0'
    jooqGenerator 'org.postgresql:postgresql:42.7.0'
}
```

### 2. クリーンアーキテクチャ（buckpalパターン）

**決定**: ヘキサゴナルアーキテクチャベースのbuckpalパターンを採用
**根拠**:
- ビジネスロジックとインフラストラクチャの明確な分離
- テスタビリティの向上
- 依存関係の逆転により、フレームワークへの依存を最小化

**検討した代替案**:
- レイヤードアーキテクチャ: より単純だが、ドメインがインフラに依存しやすい
- MVCパターン: SpringBootのデフォルトだが、ビジネスロジックが散在しやすい

**パッケージ構造**:
```
domain/
  ├── model/         # エンティティ、値オブジェクト
  └── port/          # 入力・出力ポート（インターフェース）
application/
  ├── usecase/       # ビジネスユースケース
  └── service/       # アプリケーションサービス
adapter/
  ├── in/
  │   └── web/       # REST コントローラー
  └── out/
      └── persistence/ # JOOQリポジトリ実装
```

### 3. TestContainersを使用したTDD

**決定**: TestContainersでPostgreSQLコンテナを使用した統合テスト
**根拠**:
- 実際のデータベースを使用することで、SQL構文やトランザクションの振る舞いを正確にテスト
- 環境依存性を排除し、どこでも同じテスト結果を保証
- t-wadaさんのTDD手法の「実際の依存関係を使う」原則に合致

**検討した代替案**:
- H2インメモリDB: 高速だが、PostgreSQL固有の機能をテストできない
- モック: 単体テストには有用だが、統合テストには不適切

**実装方法**:
```kotlin
@SpringBootTest
@Testcontainers
class IntegrationTest {
    @Container
    val postgres = PostgreSQLContainer("postgres:16")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test")
}
```

### 4. FlywayとJOOQコード生成

**決定**: Flyway実行後にJOOQコード生成を行うGradleタスク連携
**根拠**:
- データベーススキーマの変更を追跡可能
- JOOQの型安全なコードが常に最新のスキーマと同期
- CIパイプラインでの自動化が容易

**検討した代替案**:
- 手動でのスキーマ管理: エラーが発生しやすく、チーム開発で同期が困難
- Liquibase: 機能的には同等だが、Flywayの方がシンプル

**実装フロー**:
1. Flyway migrationスクリプト作成（`V1__create_tables.sql`）
2. Gradleタスクでmigration実行
3. JOOQコード生成タスク実行
4. 生成されたコードをビルドに含める

### 5. バリデーション戦略

**決定**: Jakarta Bean Validation（JSR-303）+ カスタムバリデーター
**根拠**:
- SpringBootとの統合が優れている
- アノテーションベースで宣言的にバリデーションルールを記述
- ドメイン固有のルールはカスタムバリデーターで実装

**検討した代替案**:
- 手動バリデーション: 柔軟だが、コードが冗長になる
- Valiktor（Kotlin専用）: Kotlin DSLが魅力的だが、Springとの統合が弱い

### 6. エラーハンドリング

**決定**: Problem Details (RFC 7807)形式でのエラーレスポンス
**根拠**:
- 標準化されたエラー形式により、クライアントでの処理が統一化
- SpringBoot 3.0以降でネイティブサポート
- 詳細なエラー情報を構造化して返却可能

**検討した代替案**:
- カスタムエラー形式: 柔軟だが、標準から外れる
- 単純なメッセージ: 情報が不足しがち

## 開発プロセスの決定事項

### TDD実践手順

1. **契約テストファースト**
   - OpenAPI仕様から契約テストを生成
   - RestAssuredを使用したAPIレベルのテスト

2. **統合テスト**
   - TestContainersでPostgreSQLを起動
   - 実際のデータベースに対してユースケースをテスト

3. **単体テスト**
   - ドメインロジックのテスト
   - MockKを使用した依存関係のモック

### CI/CDパイプライン

**決定**: GitHub Actions + Dockerイメージビルド
**根拠**:
- GitHubとの統合が優れている
- Dockerイメージとしてデプロイ可能
- 並列テスト実行が容易

## 未解決事項

すべての技術的な不確実性は解決されました。

## 次のステップ

1. data-model.mdの作成
2. OpenAPI契約仕様の作成
3. 契約テストの生成
4. quickstart.mdの作成
5. CLAUDE.mdの更新