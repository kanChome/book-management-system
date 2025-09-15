# Tasks: 書籍管理システム

**入力**: 設計ドキュメント `/specs/001-spec-md/`
**前提条件**: plan.md（必須）、research.md、data-model.md、contracts/

## 実行フロー (main)
```
1. plan.mdを機能ディレクトリから読み込み
   → 見つからない場合: エラー「実装計画が見つかりません」
   → 抽出: 技術スタック、ライブラリ、構造
2. オプションの設計ドキュメントを読み込み:
   → data-model.md: エンティティを抽出 → モデルタスク
   → contracts/: 各ファイル → 契約テストタスク
   → research.md: 決定事項を抽出 → セットアップタスク
3. カテゴリ別にタスクを生成:
   → セットアップ: プロジェクト初期化、依存関係、リンティング
   → テスト: 契約テスト、統合テスト
   → コア: モデル、サービス、エンドポイント
   → 統合: DB、ミドルウェア、ロギング
   → 仕上げ: ユニットテスト、パフォーマンス、ドキュメント
4. タスクルールを適用:
   → 異なるファイル = 並列[P]マーク
   → 同じファイル = 順次（[P]なし）
   → 実装前にテスト（TDD）
5. タスクを順次番号付け（T001、T002...）
6. 依存関係グラフを生成
7. 並列実行例を作成
8. タスクの完全性を検証:
   → すべての契約にテストがあるか？
   → すべてのエンティティにモデルがあるか？
   → すべてのエンドポイントが実装されているか？
9. 戻り値: SUCCESS（タスクの実行準備完了）
```

## 形式: `[ID] [P?] 説明`
- **[P]**: 並列実行可能（異なるファイル、依存関係なし）
- 説明には正確なファイルパスを含める

## パス規則
**単一プロジェクト**: リポジトリルートに `src/`、`src/test/`
- 実装計画の構造に基づく調整済み

## フェーズ 3.1: セットアップ
- [ ] T001 実装計画に従ってプロジェクト構造を作成
- [ ] T002 Kotlin + SpringBoot 4.x + JOOQ依存関係でプロジェクトを初期化
- [ ] T003 [P] リンティングとフォーマットツールを設定（ktlint、detekt）
- [ ] T004 [P] Docker Compose設定でPostgreSQLを追加（docker-compose.yml）
- [ ] T005 [P] Gradle JOOQ設定を追加（build.gradle）
- [ ] T006 [P] Flyway設定を追加（build.gradle）

## フェーズ 3.2: テスト優先（TDD）⚠️ 3.3より前に完了必須
**重要: これらのテストは実装前に書かれ、失敗しなければならない**
- [ ] T007 [P] 契約テスト POST /api/v1/books を src/test/kotlin/com/example/bookmanagement/contract/BookContractTest.kt で作成
- [ ] T008 [P] 契約テスト PUT /api/v1/books/{id} を src/test/kotlin/com/example/bookmanagement/contract/BookContractTest.kt で作成
- [ ] T009 [P] 契約テスト POST /api/v1/authors を src/test/kotlin/com/example/bookmanagement/contract/AuthorContractTest.kt で作成
- [ ] T010 [P] 契約テスト PUT /api/v1/authors/{id} を src/test/kotlin/com/example/bookmanagement/contract/AuthorContractTest.kt で作成
- [ ] T011 [P] 契約テスト GET /api/v1/authors/{id}/books を src/test/kotlin/com/example/bookmanagement/contract/AuthorContractTest.kt で作成
- [ ] T012 [P] 統合テスト 著者登録フローを src/test/kotlin/com/example/bookmanagement/integration/AuthorRegistrationIntegrationTest.kt で作成
- [ ] T013 [P] 統合テスト 書籍登録フローを src/test/kotlin/com/example/bookmanagement/integration/BookRegistrationIntegrationTest.kt で作成
- [ ] T014 [P] 統合テスト 出版状況変更フローを src/test/kotlin/com/example/bookmanagement/integration/PublishStatusChangeIntegrationTest.kt で作成
- [ ] T015 [P] 統合テスト バリデーションエラーフローを src/test/kotlin/com/example/bookmanagement/integration/ValidationErrorIntegrationTest.kt で作成

## フェーズ 3.3: コア実装（テストが失敗した後のみ）
- [ ] T016 [P] Bookドメインモデルを src/main/kotlin/com/example/bookmanagement/domain/model/Book.kt で作成
- [ ] T017 [P] Authorドメインモデルを src/main/kotlin/com/example/bookmanagement/domain/model/Author.kt で作成
- [ ] T018 [P] BookAuthorドメインモデルを src/main/kotlin/com/example/bookmanagement/domain/model/BookAuthor.kt で作成
- [ ] T019 [P] PublishStatus値オブジェクトを src/main/kotlin/com/example/bookmanagement/domain/model/PublishStatus.kt で作成
- [ ] T020 [P] Price値オブジェクトを src/main/kotlin/com/example/bookmanagement/domain/model/Price.kt で作成
- [ ] T021 [P] BookTitle値オブジェクトを src/main/kotlin/com/example/bookmanagement/domain/model/BookTitle.kt で作成
- [ ] T022 [P] AuthorName値オブジェクトを src/main/kotlin/com/example/bookmanagement/domain/model/AuthorName.kt で作成
- [ ] T023 Flywayマイグレーションスクリプトを src/main/resources/db/migration/V1__create_tables.sql で作成
- [ ] T024 JOOQコード生成タスクを実行
- [ ] T025 [P] Bookポートインターフェースを src/main/kotlin/com/example/bookmanagement/domain/port/BookPort.kt で作成
- [ ] T026 [P] Authorポートインターフェースを src/main/kotlin/com/example/bookmanagement/domain/port/AuthorPort.kt で作成
- [ ] T027 [P] BookServiceユースケースを src/main/kotlin/com/example/bookmanagement/application/usecase/BookService.kt で作成
- [ ] T028 [P] AuthorServiceユースケースを src/main/kotlin/com/example/bookmanagement/application/usecase/AuthorService.kt で作成
- [ ] T029 BookRepositoryアダプター（JOOQ実装）を src/main/kotlin/com/example/bookmanagement/adapter/out/persistence/BookRepository.kt で作成
- [ ] T030 AuthorRepositoryアダプター（JOOQ実装）を src/main/kotlin/com/example/bookmanagement/adapter/out/persistence/AuthorRepository.kt で作成
- [ ] T031 BookControllerを src/main/kotlin/com/example/bookmanagement/adapter/in/web/BookController.kt で作成（POST、PUT）
- [ ] T032 AuthorControllerを src/main/kotlin/com/example/bookmanagement/adapter/in/web/AuthorController.kt で作成（POST、PUT、GET books）
- [ ] T033 バリデーション設定を追加
- [ ] T034 エラーハンドリング設定を追加（Problem Details RFC 7807）

## フェーズ 3.4: 統合
- [ ] T035 BookServiceとBookRepositoryを接続
- [ ] T036 AuthorServiceとAuthorRepositoryを接続
- [ ] T037 リクエスト/レスポンスロギングを設定
- [ ] T038 Spring Boot設定ファイル（application.yml）を作成
- [ ] T039 TestContainers設定クラスを src/test/kotlin/com/example/bookmanagement/TestConfiguration.kt で作成

## フェーズ 3.5: 仕上げ
- [ ] T040 [P] Bookドメインモデルのユニットテストを src/test/kotlin/com/example/bookmanagement/unit/domain/BookTest.kt で作成
- [ ] T041 [P] Authorドメインモデルのユニットテストを src/test/kotlin/com/example/bookmanagement/unit/domain/AuthorTest.kt で作成
- [ ] T042 [P] 値オブジェクトのユニットテストを src/test/kotlin/com/example/bookmanagement/unit/domain/ValueObjectTest.kt で作成
- [ ] T043 [P] BookServiceのユニットテストを src/test/kotlin/com/example/bookmanagement/unit/application/BookServiceTest.kt で作成
- [ ] T044 [P] AuthorServiceのユニットテストを src/test/kotlin/com/example/bookmanagement/unit/application/AuthorServiceTest.kt で作成
- [ ] T045 パフォーマンステスト（<200ms レスポンスタイム）
- [ ] T046 quickstart.mdのシナリオを実行してE2Eテスト
- [ ] T047 コードの重複を除去
- [ ] T048 [P] README.mdを更新
- [ ] T049 [P] CLAUDE.mdを最新の実装状況で更新

## 依存関係
- セットアップ（T001-T006）→ すべてのテストと実装
- テスト（T007-T015）→ 実装（T016-T034）
- T016-T022（ドメインモデル）→ T025-T026（ポート）→ T027-T028（サービス）
- T023-T024（マイグレーション・JOOQ）→ T029-T030（リポジトリ）
- T025-T030（ビジネスロジック）→ T031-T032（コントローラー）
- 実装（T016-T034）→ 統合（T035-T039）→ 仕上げ（T040-T049）

## 並列実行例
```bash
# フェーズ 3.1: セットアップタスクを並列実行
Task: "リンティングとフォーマットツールを設定（ktlint、detekt）"
Task: "Docker Compose設定でPostgreSQLを追加（docker-compose.yml）"
Task: "Gradle JOOQ設定を追加（build.gradle）"
Task: "Flyway設定を追加（build.gradle）"

# フェーズ 3.2: 契約テストを並列実行
Task: "契約テスト POST /api/v1/books を src/test/kotlin/com/example/bookmanagement/contract/BookContractTest.kt で作成"
Task: "契約テスト POST /api/v1/authors を src/test/kotlin/com/example/bookmanagement/contract/AuthorContractTest.kt で作成"
Task: "統合テスト 著者登録フローを src/test/kotlin/com/example/bookmanagement/integration/AuthorRegistrationIntegrationTest.kt で作成"

# フェーズ 3.3: ドメインモデルを並列実行
Task: "Bookドメインモデルを src/main/kotlin/com/example/bookmanagement/domain/model/Book.kt で作成"
Task: "Authorドメインモデルを src/main/kotlin/com/example/bookmanagement/domain/model/Author.kt で作成"
Task: "値オブジェクトを各ファイルで作成"
```

## 注意事項
- [P]タスク = 異なるファイル、依存関係なし
- 実装前にテストの失敗を確認
- 各タスク後にコミット
- 避けるべき: 曖昧なタスク、同じファイルの競合

## タスク生成ルール
*main()実行中に適用*

1. **契約から**:
   - 各契約ファイル → 契約テストタスク[P]
   - 各エンドポイント → 実装タスク

2. **データモデルから**:
   - 各エンティティ → モデル作成タスク[P]
   - リレーションシップ → サービス層タスク

3. **ユーザーストーリーから**:
   - 各ストーリー → 統合テスト[P]
   - quickstartシナリオ → 検証タスク

4. **順序**:
   - セットアップ → テスト → モデル → サービス → エンドポイント → 仕上げ
   - 依存関係が並列実行をブロック

## 検証チェックリスト
*戻り値前にmain()でチェック*

- [x] すべての契約に対応するテストがある
- [x] すべてのエンティティにモデルタスクがある
- [x] すべてのテストが実装前に来る
- [x] 並列タスクが本当に独立している
- [x] 各タスクが正確なファイルパスを指定している
- [x] 同じファイルを変更する[P]タスクがない