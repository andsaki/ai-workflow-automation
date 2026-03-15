---
description: "プルリクエストをコメント付きでクローズ"
argument-hint: <PR番号> [理由]
allowed-tools: Read, Bash(gh:*), Bash(git:*)
---

# close-pr

プルリクエストをコメント付きでクローズします。

**使用方法**: `close-pr <PR番号> [理由]`

例:
- `close-pr 456` - PR #456をクローズ
- `close-pr 123 別のPRに統合` - 理由付きでクローズ

## 実行手順

### 1. PR番号の取得

引数から PR 番号を取得します。

引数がない場合は、現在のブランチのPRを自動検出。

### 2. 現在のブランチのPR自動検出（番号指定がない場合）

PR番号が指定されていない場合、現在のブランチのPRを検索：

```bash
gh pr view --json number,state,title
```

検出できた場合：そのPR番号を使用
検出できない場合：ユーザーに番号を尋ねる

### 3. PR情報の確認

PR の詳細を取得して内容を確認：

```bash
gh pr view [PR_NUMBER]
```

以下の情報を確認：
- タイトル
- 現在のステータス（open/closed/merged）
- 作成者
- ブランチ
- 関連するIssue

### 4. 既にクローズ・マージされているか確認

既にクローズまたはマージされている場合は、ユーザーに通知：

**クローズ済みの場合**:
```
PR #[PR_NUMBER] は既にクローズされています。
```

**マージ済みの場合**:
```
PR #[PR_NUMBER] は既にマージされています。クローズできません。
```

### 5. クローズ理由の確認

ユーザーが指定した理由、または以下から選択：

- **作業中止** - 実装しないことにした
- **別PRに統合** - 別のPRに統合するため
- **誤作成** - 間違って作成した
- **その他** - カスタム理由

### 6. 関連Issueの検出と処理

PR本文やコミットメッセージから関連Issueを検出：

```bash
gh pr view [PR_NUMBER] --json body,commits
```

`Closes #123`、`Fixes #45`、`Resolves #78` などのパターンを検索。

#### 関連Issueが見つかった場合

ユーザーに確認：

```
このPRは以下のIssueと連動しています：
- Issue #123

PRと一緒にIssueもクローズしますか？
1. はい - PRとIssueの両方をクローズ
2. いいえ - PRのみクローズ（Issueは開いたまま）
```

**ユーザーが「はい」を選択した場合**:

1. PRをクローズ
2. 関連Issueもクローズ：

```bash
gh issue close [ISSUE_NUMBER] --comment "関連する PR #[PR_NUMBER] をクローズしたため、このIssueもクローズします。\n\n🤖 Closed with [Codex CLI](https://openai.com/codex)"
```

**ユーザーが「いいえ」を選択した場合**:

- PRのみクローズ
- Issueは開いたまま

#### 関連Issueが見つからなかった場合

通常通りPRのみクローズ

### 7. クローズの実行

PR をクローズ：

**理由を指定する場合**:

```bash
gh pr close [PR_NUMBER] --comment "[理由]\n\n🤖 Closed with [Codex CLI](https://openai.com/codex)"
```

**理由なしの場合**:

```bash
gh pr close [PR_NUMBER] --comment "この PR をクローズします。\n\n🤖 Closed with [Codex CLI](https://openai.com/codex)"
```

### 8. ブランチの削除確認（オプション）

PRをクローズした後、ブランチを削除するか確認：

```
PRをクローズしました。ブランチも削除しますか？
- ローカルブランチを削除: git branch -d <branch>
- リモートブランチを削除: git push origin --delete <branch>
```

ユーザーが承認した場合、ブランチを削除：

```bash
git branch -d [BRANCH_NAME]
git push origin --delete [BRANCH_NAME]
```

### 9. 完了確認

クローズ後、PR のステータスを確認：

```bash
gh pr view [PR_NUMBER]
```

完了メッセージをユーザーに表示：

```
✅ PR #[PR_NUMBER] をクローズしました。
[関連Issueもクローズした場合: Issue #123 もクローズしました。]
```

---

## 注意事項

- クローズ前に必ずPR内容を確認する
- 既にマージされたPRはクローズできない
- 関連Issueは任意でクローズ（ユーザーに確認）
- ブランチ削除は任意（ユーザーに確認）
- GitHub CLIが認証されていることを確認（`gh auth status`）
- リポジトリの権限がない場合はエラーになります
