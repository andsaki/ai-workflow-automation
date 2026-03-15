---
description: GitHub issueをコメント付きでクローズ（使用例: /close-issue 123）
allowed-tools: Bash(gh:*)
---

# /close-issue

GitHub issueをコメント付きでクローズします。

**使用方法**: `/close-issue <issue番号> [理由]`

例:
- `/close-issue 123` - Issue #123をクローズ
- `/close-issue 45 completed` - Issue #45を完了としてクローズ
- `/close-issue 78 not_planned` - Issue #78を予定なしとしてクローズ

## 実行手順

### 1. Issue番号の取得

ユーザーのメッセージから Issue 番号を抽出します。

- `/close-issue 123` の形式で指定された場合は、`123` を Issue 番号として使用
- `/close-issue #123` の形式でも対応
- 引数がない場合は、ユーザーに「Issue 番号を指定してください」と確認

### 2. 理由の取得（オプション）

クローズ理由を抽出（デフォルト: `completed`）：

- `completed` - タスク完了（デフォルト）
- `not_planned` - 対応予定なし

### 3. Issue情報の確認

Issue の詳細を取得して内容を確認：

```bash
!gh issue view [ISSUE_NUMBER]
```

以下の情報を確認：
- タイトル
- 現在のステータス（open/closed）
- 担当者

### 4. 既にクローズされているか確認

既にクローズされている場合は、ユーザーに通知：

```
Issue #[ISSUE_NUMBER] は既にクローズされています。
```

### 5. クローズの実行

Issue をクローズ：

**completed（完了）の場合**:

```bash
!gh issue close [ISSUE_NUMBER] --comment "✅ Issue完了しました。

🤖 Closed with [Claude Code](https://claude.com/claude-code)" --reason completed
```

**not_planned（対応予定なし）の場合**:

```bash
!gh issue close [ISSUE_NUMBER] --comment "この Issue は対応予定がないためクローズします。

🤖 Closed with [Claude Code](https://claude.com/claude-code)" --reason not_planned
```

**カスタムメッセージの場合**:

ユーザーが追加のメッセージを指定した場合は、それを含める：

```bash
!gh issue close [ISSUE_NUMBER] --comment "[カスタムメッセージ]

🤖 Closed with [Claude Code](https://claude.com/claude-code)" --reason completed
```

### 6. 完了確認

クローズ後、Issue のステータスを確認：

```bash
!gh issue view [ISSUE_NUMBER]
```

完了メッセージをユーザーに表示：

```
✅ Issue #[ISSUE_NUMBER] をクローズしました。
```

---

## 使用例

### 例1: シンプルにクローズ

```
/close-issue 123
```

→ Issue #123 を「完了」としてクローズ

### 例2: 対応予定なしでクローズ

```
/close-issue 45 not_planned
```

→ Issue #45 を「対応予定なし」としてクローズ

### 例3: カスタムメッセージでクローズ

```
/close-issue 78

メッセージ: "他のIssueで対応済みのため、このIssueをクローズします。"
```

→ カスタムメッセージを添えてクローズ

---

## 注意事項

- クローズ前に必ずIssue内容を確認する
- 既にクローズされている場合は警告する
- GitHub CLIが認証されていることを確認（`gh auth status`）
- リポジトリの権限がない場合はエラーになります

---

## トラブルシューティング

### GitHub CLIが未認証の場合

```bash
!gh auth login
```

### Issue番号が見つからない場合

```
指定されたIssue番号が見つかりません。
リポジトリのIssue一覧を確認してください：
gh issue list
```

### 権限エラーの場合

```
このリポジトリのIssueをクローズする権限がありません。
リポジトリのオーナーまたはメンテナに連絡してください。
```
