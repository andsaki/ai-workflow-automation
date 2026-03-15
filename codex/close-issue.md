# close-issue

GitHub issueをコメント付きでクローズします。

**使用方法**: `close-issue <issue番号> [理由]`

例:
- `close-issue 123` - Issue #123をクローズ
- `close-issue 45 not_planned` - Issue #45を予定なしとしてクローズ

## 実行手順

### 1. Issue番号の取得

引数から Issue 番号を取得します。

### 2. 理由の取得（オプション）

クローズ理由を取得（デフォルト: `completed`）：

- `completed` - タスク完了（デフォルト）
- `not_planned` - 対応予定なし

### 3. Issue情報の確認

Issue の詳細を取得して内容を確認：

```bash
gh issue view [ISSUE_NUMBER]
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
gh issue close [ISSUE_NUMBER] --comment "✅ Issue完了しました。

🤖 Closed with [Codex CLI](https://openai.com/codex)" --reason completed
```

**not_planned（対応予定なし）の場合**:

```bash
gh issue close [ISSUE_NUMBER] --comment "この Issue は対応予定がないためクローズします。

🤖 Closed with [Codex CLI](https://openai.com/codex)" --reason not_planned
```

### 6. 完了確認

クローズ後、Issue のステータスを確認：

```bash
gh issue view [ISSUE_NUMBER]
```

完了メッセージをユーザーに表示：

```
✅ Issue #[ISSUE_NUMBER] をクローズしました。
```

---

## 注意事項

- クローズ前に必ずIssue内容を確認する
- 既にクローズされている場合は警告する
- GitHub CLIが認証されていることを確認（`gh auth status`）
- リポジトリの権限がない場合はエラーになります
