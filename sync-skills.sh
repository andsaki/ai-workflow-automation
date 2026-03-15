#!/bin/bash
# スキルファイルを一元管理から各ディレクトリに同期するスクリプト

set -euo pipefail

# カラーコード
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📦 スキルファイルを同期中...${NC}"

# skills/sources/ から claude/commands/ と codex/prompts/ にコピー
SKILLS_DIR="skills/sources"
CLAUDE_DIR="claude/commands"
CODEX_DIR="codex/prompts"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "エラー: $SKILLS_DIR ディレクトリが見つかりません"
  exit 1
fi

# ディレクトリを作成（存在しない場合）
mkdir -p "$CLAUDE_DIR"
mkdir -p "$CODEX_DIR"

# skills/sources/ 内の全ての .md ファイルを同期
sync_count=0
for skill_file in "$SKILLS_DIR"/*.md; do
  if [ -f "$skill_file" ]; then
    filename=$(basename "$skill_file")

    # claude/commands/ にコピー
    cp "$skill_file" "$CLAUDE_DIR/$filename"

    # codex/prompts/ にコピー
    cp "$skill_file" "$CODEX_DIR/$filename"

    echo -e "${GREEN}✓${NC} $filename を同期しました"
    ((sync_count++))
  fi
done

echo ""
echo -e "${GREEN}✅ 完了: ${sync_count} 個のスキルファイルを同期しました${NC}"
echo ""
echo "同期先:"
echo "  - $CLAUDE_DIR/"
echo "  - $CODEX_DIR/"
