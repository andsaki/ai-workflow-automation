# Skills Management

このディレクトリは、Claude Code と Codex CLI のスキルファイル（`.md`）を一元管理するための場所です。

## ディレクトリ構造

```
skills/
├── README.md              # このファイル
├── sources/               # マスターとなるスキルファイル（.md）
│   ├── commit.md
│   ├── push.md
│   ├── commit-push.md
│   ├── create-pr.md
│   ├── merge-pr.md
│   ├── implement-issue.md
│   ├── auto-implement-issue.md
│   ├── close-issue.md
│   ├── close-pr.md
│   ├── branch-name-helper.md
│   └── resume-session.md
```

## 使い方

### 1. スキルファイルの編集

`skills/sources/` 内のマスターファイルを編集します：

```bash
# 例: commit.md を編集
vim skills/sources/commit.md
```

### 2. 各ディレクトリに同期

編集後、同期スクリプトを実行して `claude/commands/` と `codex/prompts/` に配布します：

```bash
./sync-skills.sh
```

これにより、以下のディレクトリに同じファイルがコピーされます：
- `claude/commands/` - Claude Code で使用
- `codex/prompts/` - Codex CLI で使用

### 3. 新しいスキルの追加

1. `skills/sources/` に新しい `.md` ファイルを作成
2. `./sync-skills.sh` を実行して同期

## なぜ一元管理するのか

### 問題点（以前）

- `claude/commands/` と `codex/prompts/` に同じファイルが重複
- 一方を編集すると、もう一方も手動でコピーする必要がある
- 修正漏れが発生しやすい

### 解決策（現在）

- **マスターファイル**: `skills/sources/` に1つだけ管理
- **自動配布**: `sync-skills.sh` で両方に同期
- **一貫性保証**: 常に同じ内容が配布される

## 運用フロー

```
スキル編集
  ↓
skills/sources/*.md を編集
  ↓
./sync-skills.sh を実行
  ↓
claude/commands/ と codex/prompts/ に自動配布
  ↓
完了
```

## 注意事項

- **編集は必ず `skills/sources/` で行う**
  - `claude/commands/` や `codex/prompts/` を直接編集しても、次回の同期で上書きされます
- **同期後にコミット**
  - 同期スクリプト実行後、Git コミットを忘れずに

## トラブルシューティング

### 同期がうまくいかない場合

```bash
# 同期スクリプトに実行権限を付与
chmod +x sync-skills.sh

# 再度同期
./sync-skills.sh
```

### ファイルが見つからない

`skills/sources/` にマスターファイルが存在するか確認：

```bash
ls -la skills/sources/
```

---

**作成日**: 2026-03-15
**バージョン**: 1.0.0
