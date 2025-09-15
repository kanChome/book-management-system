# プロジェクト構成（Clean Architecture / BuckPal）

本リポジトリは、BuckPal パターン（クリーンアーキテクチャ）に基づく3層構成を採用します。

- `domain`: ビジネスルール（エンティティ、ドメインサービス、ドメインイベント）
- `application`: ユースケース実行（アプリケーションサービス、`port/in` と `port/out`）
- `adapter`: I/O 実装（`in` = 入力境界の実装、`out` = 外部システム接続）

各層は依存方向を内向き（外→内）に限定し、`domain` は他層に依存しません。

## 目次
- src/domain
- src/application
- src/adapter
- tests
- docs/architecture.md

## 開発ガイド（概要）
- 新規ユースケース: `application/port/in` にインターフェース、`application/service` に実装。
- 外部依存: `application/port/out` にポート、`adapter/out` にアダプタ実装。
- 入力境界実装: `adapter/in`（例: `web`, `cli`, `messaging`）。
- ドメインモデル: `domain/model` と必要に応じて `domain/service` / `domain/event`。

詳しくは `docs/architecture.md` を参照してください。
