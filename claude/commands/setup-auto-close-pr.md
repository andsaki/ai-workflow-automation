---
description: PRがApproveされたら連動するPRを自動クローズするワークフローを設定
allowed-tools: Read, Write, Bash(git:*), Bash(gh:*), Bash(mkdir:*)
---

# setup-auto-close-pr

PRがApproveされたときに、本文中で指定された連動PRを自動的にクローズするGitHub Actionsワークフローを設定します。

**使用方法**: `/setup-auto-close-pr`

## 概要

このスキルは、開発リポジトリに以下のファイルを作成します：

- `.github/workflows/auto-close-linked-pr.yml` - ワークフローファイル
- `.github/workflows/README.md` - 使い方ドキュメント

## ユースケース

代替実装のPRを作成した場合、元のPRが不要になります。このワークフローを使うと：

1. 新しいPR本文に `Supersedes #123` と記述
2. 新しいPRがApproveされる
3. PR #123 が自動的にクローズされる

## 実行手順

### 1. 現在のリポジトリを確認

ワークフローを設定するリポジトリにいるか確認：

```bash
pwd
git remote -v
```

### 2. ディレクトリを作成

`.github/workflows` ディレクトリを作成：

```bash
mkdir -p .github/workflows
```

### 3. ワークフローファイルを作成

`.github/workflows/auto-close-linked-pr.yml` を作成：

```yaml
name: Auto Close Linked PRs

on:
  pull_request_review:
    types: [submitted]

permissions:
  pull-requests: write
  issues: write

jobs:
  close-linked-prs:
    if: github.event.review.state == 'approved'
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Get PR details
        id: pr
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          pr_number="${{ github.event.pull_request.number }}"
          pr_body=$(gh pr view $pr_number --json body -q .body)
          echo "body<<EOF" >> $GITHUB_OUTPUT
          echo "$pr_body" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Extract linked PR numbers
        id: extract
        run: |
          pr_body="${{ steps.pr.outputs.body }}"

          # Extract PR numbers from patterns like:
          # - Supersedes #123
          # - Replaces #456
          # - Closes #789 (alternative PR)
          # - Deprecates #101
          linked_prs=$(echo "$pr_body" | grep -iE "(supersedes|replaces|deprecates|closes.*alternative)" | grep -oE "#[0-9]+" | sed 's/#//' | sort -u)

          if [ -z "$linked_prs" ]; then
            echo "No linked PRs found"
            echo "has_linked_prs=false" >> $GITHUB_OUTPUT
          else
            echo "Found linked PRs: $linked_prs"
            echo "has_linked_prs=true" >> $GITHUB_OUTPUT
            echo "linked_prs<<EOF" >> $GITHUB_OUTPUT
            echo "$linked_prs" >> $GITHUB_OUTPUT
            echo "EOF" >> $GITHUB_OUTPUT
          fi

      - name: Close linked PRs
        if: steps.extract.outputs.has_linked_prs == 'true'
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          pr_number="${{ github.event.pull_request.number }}"

          echo "${{ steps.extract.outputs.linked_prs }}" | while read -r linked_pr; do
            if [ -n "$linked_pr" ]; then
              echo "Closing PR #$linked_pr..."

              pr_state=$(gh pr view $linked_pr --json state -q .state 2>/dev/null || echo "NOT_FOUND")

              if [ "$pr_state" = "OPEN" ]; then
                comment_msg=$(cat <<EOF
          🔗 Automatically closed because PR #$pr_number was approved and supersedes this PR.

          This PR has been replaced by the approved changes in #$pr_number.

          🤖 Auto-closed by GitHub Actions
          EOF
                )

                gh pr close $linked_pr --comment "$comment_msg"
                echo "✅ Closed PR #$linked_pr"
              elif [ "$pr_state" = "CLOSED" ]; then
                echo "⏭️  PR #$linked_pr is already closed"
              elif [ "$pr_state" = "MERGED" ]; then
                echo "⏭️  PR #$linked_pr is already merged (cannot close)"
              else
                echo "⚠️  PR #$linked_pr not found"
              fi
            fi
          done

      - name: Summary
        if: steps.extract.outputs.has_linked_prs == 'true'
        run: |
          echo "### Auto Close Summary 🎯" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "PR #${{ github.event.pull_request.number }} was approved." >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "**Linked PRs processed:**" >> $GITHUB_STEP_SUMMARY
          echo "${{ steps.extract.outputs.linked_prs }}" | while read -r linked_pr; do
            if [ -n "$linked_pr" ]; then
              echo "- PR #$linked_pr" >> $GITHUB_STEP_SUMMARY
            fi
          done
```

### 4. 使い方ドキュメントを作成

`.github/workflows/README.md` を作成：

```markdown
# GitHub Actions Workflows

このディレクトリには、リポジトリの自動化ワークフローが含まれています。

## Auto Close Linked PRs

PRがApproveされたときに、連動する他のPRを自動的にクローズします。

### 使い方

PR本文に以下のようなパターンを記述すると、そのPRがApproveされたときに自動的にクローズされます：

```markdown
## Summary
この PR は機能 X の改善版です。

Supersedes #123
```

### サポートされているキーワード

- `Supersedes #123` - PR #123 を置き換える
- `Replaces #456` - PR #456 を置き換える
- `Deprecates #789` - PR #789 を非推奨にする
- `Closes #101 (alternative)` - 代替PR #101 をクローズ

### 動作フロー

1. PRがApproveされる
2. ワークフローがPR本文をスキャン
3. キーワードパターンから連動するPR番号を抽出
4. 抽出されたPRが `OPEN` 状態の場合、自動的にクローズ
5. クローズ時に、Approveされたプルリクエストへのリンクを含むコメントを追加

### 例

**PR #100 の本文:**

```markdown
## Summary
ダークモード実装の改善版です。

Supersedes #95
Replaces #98
```

このPR #100がApproveされると：

- PR #95 が自動的にクローズされます
- PR #98 も自動的にクローズされます
- 両方のPRに「PR #100 に置き換えられました」というコメントが追加されます

### トラブルシューティング

**ワークフローが実行されない:**

- PRがApproveされているか確認してください
- リポジトリの Settings > Actions > General で、ワークフローの権限が有効になっているか確認してください

**PRが自動的にクローズされない:**

- PR本文にサポートされているキーワード（Supersedes、Replaces など）が含まれているか確認してください
- PR番号が正しい形式（`#123`）で記述されているか確認してください
- Actions タブでワークフローのログを確認してください

**権限エラーが発生する:**

- リポジトリの Settings > Actions > General > Workflow permissions で「Read and write permissions」が有効になっているか確認してください
```

### 5. ファイルを確認

作成されたファイルを確認：

```bash
ls -la .github/workflows/
cat .github/workflows/auto-close-linked-pr.yml
```

### 6. コミットとプッシュ（オプション）

ユーザーに確認してから、変更をコミット・プッシュ：

```
ワークフローファイルを作成しました。

作成されたファイル:
- .github/workflows/auto-close-linked-pr.yml
- .github/workflows/README.md

コミットしてプッシュしますか？
```

ユーザーが承認した場合：

```bash
git add .github/
git commit -m "feat: add auto-close linked PRs workflow

Automatically closes linked PRs when a PR is approved.

Supports keywords:
- Supersedes #123
- Replaces #456
- Deprecates #789
- Closes #101 (alternative)

🤖 Generated with Claude Code"
git push
```

### 7. 完了メッセージ

設定完了をユーザーに通知：

```
✅ Auto Close Linked PRs ワークフローを設定しました！

使い方:
PR本文に以下のように記述してください：

  Supersedes #123

そのPRがApproveされると、PR #123 が自動的にクローズされます。

詳細は .github/workflows/README.md を参照してください。
```

---

## サポートされているキーワード

以下のキーワードを検出します：

- **Supersedes #123** - 置き換え（最も一般的）
- **Replaces #456** - 置き換え
- **Deprecates #789** - 非推奨化
- **Closes #101 (alternative)** - 代替案のクローズ

## 注意事項

- GitHub Actions が有効なリポジトリでのみ動作します
- リポジトリの Settings > Actions > General > Workflow permissions で「Read and write permissions」が必要です
- PRのApproveが必要（コメントだけでは動作しません）
- すでにクローズまたはマージされたPRはスキップされます

## トラブルシューティング

### 権限エラーが発生する場合

リポジトリの Settings を確認：

1. Settings > Actions > General
2. Workflow permissions
3. 「Read and write permissions」を選択
4. 「Allow GitHub Actions to create and approve pull requests」にチェック

### ワークフローが実行されない場合

- PRが実際にApproveされているか確認
- Actions タブでワークフローの実行履歴を確認
- ワークフローファイルの構文エラーがないか確認
