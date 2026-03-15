# setup-auto-close-pr

PRがApproveされたら連動するPRを自動クローズするワークフローを設定します。

## 概要

このプロンプトは、開発リポジトリに以下のファイルを作成します：

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
!pwd
!git remote -v
```

### 2. ディレクトリを作成

`.github/workflows` ディレクトリを作成：

```bash
!mkdir -p .github/workflows
```

### 3. ワークフローファイルを作成

`.github/workflows/auto-close-linked-pr.yml` を作成：

<details>
<summary>ワークフローファイルの内容（クリックして展開）</summary>

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

          # Extract PR numbers from patterns
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
                echo "⏭️  PR #$linked_pr is already merged"
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

</details>

### 4. 使い方ドキュメントを作成

`.github/workflows/README.md` を作成

### 5. コミットとプッシュ（オプション）

ユーザーに確認してから、変更をコミット・プッシュ：

```bash
!git add .github/
!git commit -m "feat: add auto-close linked PRs workflow"
!git push
```

### 6. 完了メッセージ

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

- **Supersedes #123** - 置き換え
- **Replaces #456** - 置き換え
- **Deprecates #789** - 非推奨化
- **Closes #101 (alternative)** - 代替案のクローズ

## 使用例

**PR本文の例:**

```markdown
## Summary
ダークモード実装の改善版です。パフォーマンスを向上させました。

## Changes
- CSS変数を使用
- アクセシビリティ改善

Supersedes #95
Replaces #98
```

このPRがApproveされると、PR #95 と #98 が自動的にクローズされます。

## 注意事項

- GitHub Actions が有効なリポジトリでのみ動作します
- リポジトリの Settings > Actions で「Read and write permissions」が必要です
- PRのApproveが必要（コメントだけでは動作しません）

## トラブルシューティング

### 権限エラーが発生する場合

リポジトリの Settings を確認：

1. Settings > Actions > General
2. Workflow permissions
3. 「Read and write permissions」を選択
4. 「Allow GitHub Actions to create and approve pull requests」にチェック
