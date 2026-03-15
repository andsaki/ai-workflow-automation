---
description: GitHub issueを読んで実装を自動実行（使用例: /implement-issue 123）
allowed-tools: Bash(git:*), Bash(gh:*), Bash(npm:*), Bash(npx:*), Read, Write, Edit, Glob, Grep
---

# /implement-issue

GitHub issueを読み取り、その内容に基づいて実装を実行します。

**使用方法**: `/implement-issue <issue番号>`

例: `/implement-issue 123`

## 実行手順

### 1. Issue番号の取得

**重要**: ユーザーのメッセージから Issue 番号を抽出します。

- `/implement-issue 123` の形式で指定された場合は、`123` を Issue 番号として使用
- `/implement-issue #123` の形式でも対応
- 番号のみの場合（`123`）も Issue 番号として扱う
- 引数がない場合は、ユーザーに「Issue 番号を指定してください」と確認します

### 2. Issue情報の取得

指定されたissue番号の詳細を取得：

```bash
!gh issue view [ISSUE_NUMBER]
```

Issue の以下の情報を確認：
- タイトル
- 本文（Description）
- ラベル
- 担当者
- コメント

### 3. Issue内容の分析

以下の観点でIssueを分析：

**実装内容の特定**:
- 新機能追加（feature）
- バグ修正（bug）
- リファクタリング（refactor）
- ドキュメント更新（docs）
- パフォーマンス改善（perf）

**必要なファイルの特定**:
- 変更が必要なファイル
- 新規作成が必要なファイル
- テストファイル

**実装の優先順位**:
- 依存関係の確認
- 実装順序の決定

### 4. 現在のブランチ確認

```bash
!git branch --show-current
```

master/main ブランチにいる場合は、Issue内容からブランチ名を生成して新しいブランチを作成：

```bash
!git checkout -b <type>/<issue-description>
```

ブランチ名の例：
- `feature/add-dark-mode` (Issue #123: ダークモード実装)
- `fix/login-error` (Issue #45: ログインエラー修正)
- `refactor/api-client` (Issue #78: APIクライアントのリファクタリング)

### 5. 実装計画の作成と提示

実装タスクを細分化し、**必ずユーザーに確認**：

1. **必要な調査**
   - 既存コードの確認
   - 使用するライブラリの調査
   - 関連するドキュメントの確認

2. **実装ステップ**
   - コアロジックの実装
   - UIコンポーネントの実装
   - テストの作成
   - ドキュメントの更新

3. **検証項目**
   - 型チェック
   - Lint
   - テスト実行
   - ビルド確認

**重要**: 実装計画をユーザーに提示し、承認を得てから実装を開始する

### 6. 実装の実行

実装計画に基づいて順次実装：

- ファイルの作成・編集（Read, Write, Edit ツールを使用）
- 必要に応じてライブラリのインストール
- コードの記述

**実装中の注意点**:
- 既存のコーディング規約に従う
- 適切なコメント・ドキュメントを追加
- セキュリティを考慮
- パフォーマンスを考慮

### 7. テストとビルド

実装後、必ず以下を実行：

**型チェック**:
```bash
!npx tsc --noEmit
```

**Lint**:
```bash
!npm run lint
```

**テスト**（存在する場合）:
```bash
!npm test
```

**ビルド**:
```bash
!npm run build
```

エラーが出た場合は修正してから次へ進む。

### 8. コミットとプッシュ

変更をコミット（`/commit-push` スキルを使用するか、手動で実行）：

```bash
!git add .
!git commit -m "$(cat <<'EOF'
<type>: <タイトル>

<詳細な説明>

Closes #<ISSUE_NUMBER>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

リモートにプッシュ：

```bash
!git push -u origin $(git branch --show-current)
```

### 9. プルリクエストの作成

PRを作成（`/create-pr` スキルを使用するか、手動で実行）：

```bash
!gh pr create --title "<type>: <タイトル>" --body "$(cat <<'EOF'
## Summary
- Issueの内容を要約

## Changes
- 主要な変更点

## Test plan
- [ ] 型チェック通過
- [ ] Lint通過
- [ ] テスト通過
- [ ] ビルド成功
- [ ] 動作確認完了

Closes #<ISSUE_NUMBER>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### 10. Issue ステータスの更新

実装完了後、Issueのステータスを更新します。以下の2つのオプションがあります：

#### オプション1: PR経由で自動クローズ（推奨）

コミットメッセージとPR本文に `Closes #<ISSUE_NUMBER>` が含まれているため、**PRがマージされると自動的にIssueがクローズされます**。

Issueにコメントを追加：

```bash
!gh issue comment [ISSUE_NUMBER] --body "✅ 実装完了しました。PR: #<PR_NUMBER>
PRマージ時に自動的にクローズされます。"
```

#### オプション2: 手動でクローズ（直接main/masterにマージする場合）

PRを作成せずに直接main/masterブランチにマージする場合は、手動でIssueをクローズ：

```bash
!gh issue close [ISSUE_NUMBER] --comment "✅ 実装完了しました。"
```

ラベルを追加してクローズする場合：

```bash
!gh issue close [ISSUE_NUMBER] --comment "✅ 実装完了しました。" --reason completed
```

#### オプション3: Issueをopenのままにしてコメントだけ追加

レビュー待ちの場合など、Issueを開いたままにする場合：

```bash
!gh issue comment [ISSUE_NUMBER] --body "✅ 実装完了しました。PR: #<PR_NUMBER>
レビューをお願いします。"
```

---

## 実装例

### Issue #123: ダークモード実装の場合

1. Issue取得: `gh issue view 123`
2. ブランチ作成: `git checkout -b feature/add-dark-mode`
3. 実装計画をユーザーに提示して承認を得る
4. 実装:
   - `src/hooks/useDarkMode.ts` を作成
   - `src/components/ThemeToggle.tsx` を作成
   - `src/styles/theme.css` を更新
5. テスト: `npm test`
6. コミット: `feat: ダークモード実装 (#123)`
7. PR作成: `gh pr create ...`
8. Issueコメント: `gh issue comment 123 ...`

---

## 使用例

```
/implement-issue 123
```

または自然な会話で：
- Issue #123 を実装して
- Issue 45 のバグを修正して
- #78 のリファクタリングをやって

---

## 注意事項

- 実装前に必ずIssue内容を確認し、不明点があればユーザーに確認
- **大規模な変更の場合は、必ず実装計画をユーザーに提示してから進める**
- テストやビルドでエラーが出た場合は、必ず修正してから次へ進む
- PRのタイトルと本文は、Issueの内容を反映させる
- コミットメッセージに `Closes #<ISSUE_NUMBER>` を含めて、Issue自動クローズを有効化
- Issue番号が指定されていない場合は、ユーザーに確認する
- GitHub CLIが認証されていることを確認（`gh auth status`）

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

### master/mainブランチで作業している場合

自動的にフィーチャーブランチを作成します。
