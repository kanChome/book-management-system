# アーキテクチャ概要（BuckPal）

本プロジェクトは、入出力の実装（adapter）とユースケース（application）とドメイン（domain）を厳密に分離します。

依存関係の方向:

```
adapter → application → domain
```

主要ディレクトリ:

- `src/domain`
  - `model/`: エンティティ、値オブジェクト、集約
  - `service/`: ドメインサービス（純粋なビジネスロジック）
  - `event/`: ドメインイベント
- `src/application`
  - `port/in/`: ユースケース入力ポート（インターフェース）
  - `port/out/`: 外部依存への出力ポート（インターフェース）
  - `service/`: ユースケース実装（トランザクション制御、オーケストレーション）
- `src/adapter`
  - `in/`: 入力アダプタ（例: `web`, `cli`, `messaging`）
  - `out/`: 出力アダプタ（例: `persistence`, `external`）

テスト方針（推奨）:
- `domain` はピュアユニットテスト中心。
- `application` はポートをモックしてユースケースを検証。
- `adapter` は契約テスト／統合テストで外部境界を検証。

