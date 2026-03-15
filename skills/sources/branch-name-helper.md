---
description: Git差分を分析してブランチ名を提案・作成。新しいブランチを作成する際に、変更内容に基づいた適切な名前を提案します。
allowed-tools: Bash(git:*)
---

# /branch-name-helper

現在のGit差分を分析して、適切なブランチ名を提案し、選択したブランチを作成します。

## 実行手順

### 1. 現在の変更内容を確認

ステータス確認：

```bash
!git status --short
```

Unstaged変更の統計：

```bash
!git diff --stat
```

Staged変更の統計：

```bash
!git diff --cached --stat
```

未追跡ファイル：

```bash
!git ls-files --others --exclude-standard
```

### 2. 変更内容を分析

以下の観点で変更を分析：

**新規ファイルの種類**:
- コンポーネント（.vue, .tsx, .jsx）
- 設定ファイル（config.ts, .json）
- ドキュメント（.md）
- スタイル（.css, .scss）
- テスト（.test.ts, .spec.ts）

**変更されたファイルの種類と数**:
- 複数のディレクトリにまたがる変更か
- 特定の機能に集中した変更か

**package.jsonの変更**:
- 新規依存関係の追加
- スクリプトの追加・変更
- 設定の更新

**設定ファイルの変更**:
- ビルドツールの設定
- リンター・フォーマッター設定
- 環境変数

### 3. ブランチ名を提案

以下の形式で3つのブランチ名を提案：

**ブランチ名の形式**:
```
type/短い説明（kebab-case）
```

**ブランチタイプ**:
- `feature/` - 新機能追加
- `fix/` - バグ修正
- `refactor/` - リファクタリング
- `docs/` - ドキュメント更新
- `style/` - スタイル・UI変更
- `test/` - テスト追加・修正
- `chore/` - ビルド、ツール設定、依存関係更新
- `perf/` - パフォーマンス改善

**命名ルール**:
- 小文字のみ使用
- 単語はハイフン（-）で区切る
- 簡潔に（3-5単語、20-40文字推奨）
- 英語で記述
- 変更内容を的確に表現

**提案例**:
```
1. feature/add-panda-css-design-system
2. feature/integrate-panda-css
3. chore/setup-panda-css-tokens
```

### 4. ユーザーに選択を促す

提案したブランチ名をユーザーに提示し、どれを使用するか確認。

### 5. ブランチを作成

選択されたブランチ名で新しいブランチを作成：

```bash
!git checkout -b <選択されたブランチ名>
```

実行後、成功メッセージを表示。

---

## 分析のポイント

### Panda CSSの追加の場合
- `panda.config.ts` の追加 → `chore/setup-panda-css`
- コンポーネント + レシピ → `feature/add-panda-css-components`
- 既存コンポーネントの移行 → `refactor/migrate-to-panda-css`

### デザインシステムの追加の場合
- デザイントークン + コンポーネント → `feature/add-design-system`
- accessibility-learningからの移植 → `feature/port-accessibility-components`

### ヘッダー・ナビゲーションの追加の場合
- グローバルヘッダー → `feature/add-global-header`
- ナビゲーション改善 → `feature/improve-navigation`

---

## エラーハンドリング

### 変更がない場合
```
現在変更がありません。ブランチを作成する前にファイルを変更してください。
```

### Gitリポジトリでない場合
```
Gitリポジトリではありません。git initを実行してください。
```

### ブランチ名が既に存在する場合
```
ブランチ「feature/xxx」は既に存在します。
別の名前を選択するか、既存ブランチに切り替えますか？
```

---

## 使用例

```
/branch-name-helper
```

または自然な会話で：
- ブランチ名を提案して
- 適切なブランチ名を考えて
- この変更に合うブランチ名は？

---

## 注意事項

- 変更がない場合は提案できません
- Gitリポジトリでない場合はエラーになります
- ブランチ名が既に存在する場合は警告します
- 1つのブランチに1つの目的を推奨
- 複数の独立した変更がある場合は分割を提案
