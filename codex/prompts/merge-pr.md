# merge-pr

指定したPRをマージします。PRに `Closes #123` が含まれていれば、GitHubの標準機能でIssueも自動クローズされます。

**使用方法**:
- `codex merge-pr 100` - PR #100 をマージ
- `codex merge-pr` - 現在のブランチのPRをマージ

## 実行手順

### 1. PR番号の取得

#### 引数がある場合
引数からPR番号を取得。

#### 引数がない場合
現在のブランチのPRを自動検出：
```bash
!gh pr view --json number -q .number
```

### 2. PR情報の確認

PRの詳細を取得：
```bash
!gh pr view [PR_NUMBER] --json number,title,state,isDraft,reviews,statusCheckRollup
```

表示する情報：
- タイトル
- 状態
- レビュー状態（Approved数）
- CIステータス
- マージ可能か

### 3. マージ前チェック

以下を確認して警告を表示：

- PRが既にマージ済みか
- Draftか
- Approveされているか
- CIが通っているか

警告がある場合は、続行するか確認。

### 4. Issue自動クローズの確認

PR本文から関連Issueを検出：

```bash
!gh pr view [PR_NUMBER] --json body -q .body | grep -iE "(close[sd]?|fix(e[sd])?|resolve[sd]?) #[0-9]+"
```

検出されたIssueを表示：
```
📋 以下のIssueがマージ時に自動クローズされます：
  - Issue #123
  - Issue #45
```

### 5. マージ方法の選択

コミット数を確認して推奨方法を提示：

```bash
!gh pr view [PR_NUMBER] --json commits -q '.commits | length'
```

**推奨**:
- 1-5コミット → `squash`（推奨）
- 6コミット以上 → ユーザーに確認

選択肢：
1. `squash` - 1つのコミットにまとめる（推奨）
2. `merge` - 全コミットを保持
3. `rebase` - 直線的な履歴

### 6. マージ実行

```bash
# Squash（推奨）
!gh pr merge [PR_NUMBER] --squash --delete-branch

# Merge
!gh pr merge [PR_NUMBER] --merge --delete-branch

# Rebase
!gh pr merge [PR_NUMBER] --rebase --delete-branch
```

### 7. マージ確認

マージ後、Issueのクローズ状態を確認：

```bash
!gh issue view 123 --json state -q .state
```

### 8. 完了メッセージ

```
✅ PR #100 をマージしました！

マージ方法: squash
ブランチ: feature/add-dark-mode → 削除済み

📋 自動クローズされたIssue:
  - Issue #123: CLOSED
  - Issue #45: CLOSED
```

---

## マージ方法の比較

| 方法 | 説明 | 使用ケース |
|-----|------|----------|
| **squash** | 1つにまとめる | 通常はこれ（推奨） |
| **merge** | 全コミットを保持 | 重要な履歴を残したい |
| **rebase** | 直線的な履歴 | クリーンな履歴重視 |

## Issue自動クローズのキーワード

以下のキーワードがPR本文に含まれていれば、マージ時に自動クローズ：

- `Closes #123`, `Fixes #123`, `Resolves #123`
- 複数形も可: `Closed`, `Fixed`, `Resolved`

**例**:
```markdown
## Summary
ダークモードを実装しました。

Closes #123
Fixes #45
```

---

## 使用例

```bash
# PR #100 をマージ
codex merge-pr 100

# 現在のブランチのPRをマージ
codex merge-pr
```

---

## 注意事項

- Issue自動クローズはGitHubの標準機能（ワークフロー不要）
- ブランチは自動削除される
- 同じリポジトリのIssueのみ自動クローズ
- 別リポジトリの場合: `Closes owner/repo#123`
