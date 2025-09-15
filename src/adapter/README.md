# adapter 層

入力境界（in）および出力境界（out）の実装を配置します。

推奨サブディレクトリ:
- `in/web/` REST/HTTP などのエンドポイント
- `in/cli/` CLI ハンドラ
- `in/messaging/` メッセージング受信
- `out/persistence/` DB・永続化実装
- `out/external/` 外部 API 連携

