# implement-issue

GitHub issueを読み取り、その内容に基づいて実装を実行します。

## 実行手順

### 1. Issue情報の取得

指定されたissue番号の詳細を取得：

```bash
gh issue view [ISSUE_NUMBER]
```

Issue の以下の情報を確認：
- タイトル
- 本文（Description）
- ラベル
- 担当者
- コメント

### 2. Issue内容の分析

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

### 3. ブランチの作成

Issue内容からブランチ名を生成し、新しいブランチを作成：

```bash
git checkout -b <type>/<issue-description>
```

ブランチ名の例：
- `feature/add-dark-mode` (Issue #123: ダークモード実装)
- `fix/login-error` (Issue #45: ログインエラー修正)
- `refactor/api-client` (Issue #78: APIクライアントのリファクタリング)

### 4. 実装計画の作成

実装タスクを細分化：

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

### 5. 実装の実行

実装計画に基づいて順次実装：

- ファイルの作成・編集
- 必要に応じてライブラリのインストール
- コードの記述

**実装中の注意点**:
- 既存のコーディング規約に従う
- 適切なコメント・ドキュメントを追加
- セキュリティを考慮
- パフォーマンスを考慮

### 6. テストとビルド

実装後、必ず以下を実行：

**型チェック**:
```bash
npx tsc --noEmit
```

**Lint**:
```bash
npm run lint
```

**テスト**:
```bash
npm test
```

**ビルド**:
```bash
npm run build
```

エラーが出た場合は修正してから次へ進む。

### 7. コミットとプッシュ

変更をコミット：

```bash
git add .
git commit -m "$(cat <<'EOF'
<type>: <タイトル>

<詳細な説明>

Closes #<ISSUE_NUMBER>

🤖 Generated with [Codex CLI](https://openai.com/codex)

Co-Authored-By: OpenAI Codex <noreply@openai.com>
EOF
)"
```

リモートにプッシュ：

```bash
git push -u origin $(git branch --show-current)
```

### 8. プルリクエストの作成

PRを作成：

```bash
gh pr create --title "<type>: <タイトル>" --body "$(cat <<'EOF'
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

🤖 Generated with [Codex CLI](https://openai.com/codex)
EOF
)"
```

### 9. Issue ステータスの更新

実装完了後、Issueのステータスを更新します。以下の2つのオプションがあります：

#### オプション1: PR経由で自動クローズ（推奨）

コミットメッセージとPR本文に `Closes #<ISSUE_NUMBER>` が含まれているため、**PRがマージされると自動的にIssueがクローズされます**。

Issueにコメントを追加：

```bash
gh issue comment [ISSUE_NUMBER] --body "✅ 実装完了しました。PR: #<PR_NUMBER>
PRマージ時に自動的にクローズされます。"
```

#### オプション2: 手動でクローズ（直接main/masterにマージする場合）

PRを作成せずに直接main/masterブランチにマージする場合は、手動でIssueをクローズ：

```bash
gh issue close [ISSUE_NUMBER] --comment "✅ 実装完了しました。"
```

ラベルを追加してクローズする場合：

```bash
gh issue close [ISSUE_NUMBER] --comment "✅ 実装完了しました。" --reason completed
```

#### オプション3: Issueをopenのままにしてコメントだけ追加

レビュー待ちの場合など、Issueを開いたままにする場合：

```bash
gh issue comment [ISSUE_NUMBER] --body "✅ 実装完了しました。PR: #<PR_NUMBER>
レビューをお願いします。"
```

---

## 実装例

### Issue #123: ダークモード実装の場合

1. Issue取得: `gh issue view 123`
2. ブランチ作成: `git checkout -b feature/add-dark-mode`
3. 実装:
   - `src/hooks/useDarkMode.ts` を作成
   - `src/components/ThemeToggle.tsx` を作成
   - `src/styles/theme.css` を更新
4. テスト: `npm test`
5. コミット: `feat: ダークモード実装 (#123)`
6. PR作成: `gh pr create ...`
7. Issueコメント: `gh issue comment 123 ...`

---

## 注意事項

- Issue番号は引数で受け取る（例: `codex-issue 123`）
- 実装前に必ずIssue内容を確認し、不明点があればユーザーに確認
- 大規模な変更の場合は、実装計画をユーザーに提示してから進める
- テストやビルドでエラーが出た場合は、必ず修正してから次へ進む
- PRのタイトルと本文は、Issueの内容を反映させる
- コミットメッセージに `Closes #<ISSUE_NUMBER>` を含めて、Issue自動クローズを有効化
