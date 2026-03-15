# スキル活用シーケンス図

開発で利用できる主要スキルのフローと条件分岐を視覚化しました。Issue駆動の全自動フローから、ブランチ作成・PR作成・マージ時のチェックまでを 1 つのドキュメントで把握できます。

## 1. `/auto-implement-issue` 完全自動フロー

Issue番号だけ指定すれば、実装からPR作成・Issueコメントまでを全自動で行うシーケンス図です。

```mermaid
sequenceDiagram
    autonumber
    participant Dev as 開発者
    participant CLI as AI CLI
    participant Repo as ローカルGit
    participant GH as GitHub

    Dev->>CLI: /auto-implement-issue <issue>
    CLI->>GH: Issue情報取得 (gh issue view)
    CLI->>Repo: ブランチ作成 (git checkout -b)
    CLI->>Repo: 実装 (編集/生成/移動)
    CLI->>Repo: テスト・ビルド実行 (npm, tsc, etc.)
    alt テスト/ビルド失敗
        CLI->>CLI: 最大3回まで自動修正
        CLI->>Repo: 修正内容を適用
        CLI->>Repo: テストを再実行
        CLI-->>Dev: 失敗を報告 (3回失敗時)
    else 成功
        CLI->>Repo: git add .
        CLI->>Repo: git commit (IssueをCloses)
        CLI->>GH: git push -u origin <branch>
        CLI->>GH: gh pr create --title/--body
        CLI->>GH: gh issue comment (完了報告)
        CLI-->>Dev: PRリンクと次のステップを通知
    end
```

## 2. `/implement-issue`（半自動）との比較

`/implement-issue` は途中でユーザー確認が入る以外、上記とほぼ同じ流れです。以下の図は「確認あり」の分岐を表しています。

```mermaid
sequenceDiagram
    autonumber
    participant Dev as 開発者
    participant CLI as AI CLI

    Dev->>CLI: /implement-issue <issue>
    CLI->>Dev: 実装計画を提案
    alt 承認
        Dev-->>CLI: OK
        CLI->>CLI: 実装・テスト・コミット (stepごとに確認)
    else 差戻し
        Dev-->>CLI: 修正依頼
        CLI->>CLI: 計画を更新して再提案
    end
    CLI->>Dev: PR作成やIssueコメントの実行可否を毎回確認
```

## 3. スキル選択フローチャート（条件分岐）

タスクの規模や確認の要否に応じて、どのスキルを選ぶべきかをまとめています。

```mermaid
flowchart TD
    Start([作業開始]) --> Issue{Issueはある？}
    Issue -->|Yes| Size{変更規模は？}
    Issue -->|No| Manual[/cxb → 編集 → cxc/cxcp → cxpr → cxm/]

    Size -->|小 (1-2ファイル)| Auto[/auto-implement-issue/]
    Size -->|中 (3-10ファイル)| Choice{確認は必要？}
    Size -->|大 (10ファイル以上)| Manual

    Choice -->|Yes| Implement[/implement-issue/]
    Choice -->|No| Auto

    Manual --> Done([PR & Issue 更新])
    Auto --> Done
    Implement --> Done
```

## 4. `/merge-pr` のマージ前チェック

PRをマージする際の自動チェックと分岐を表したシーケンス図です。

```mermaid
sequenceDiagram
    autonumber
    participant Dev as 開発者
    participant CLI as AI CLI
    participant GH as GitHub

    Dev->>CLI: /merge-pr [番号]
    CLI->>GH: PR情報取得 (state, draft, reviews, checks)
    CLI->>Dev: Draft/未承認/CI失敗の警告
    alt 問題あり
        Dev-->>CLI: 強制マージする？ (y/N)
        opt キャンセル
            Dev-->>CLI: N
            CLI-->>Dev: 中断
        end
    else 問題なし
        CLI->>Dev: merge/squash/rebase を提案
        Dev-->>CLI: 選択
        CLI->>GH: gh pr merge --<method> --delete-branch
        CLI->>GH: Issue自動クローズ結果を確認
        CLI-->>Dev: 完了メッセージ
    end
```

## 5. ドキュメントの使い方

1. タスク開始時に **セクション3** のフローチャートでスキルを選ぶ。
2. 選んだスキルの詳細フロー（セクション1,2,4）を参照し、どの工程が自動化されているか把握する。
3. レビュー時は、図を見ながら「どのステップで問題が起きたか」「自動修正の上限に達したか」を共有するとスムーズです。

必要に応じて、今後は `/resume-session` や `/branch-name-helper` など他スキルの図も追記できます。
