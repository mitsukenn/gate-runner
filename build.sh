#!/bin/sh
# zoshoku-gate.html から、単体で開ける index.html を生成する。
#
# zoshoku-gate.html は Claude の Artifact 形式に合わせた「断片」で、
# doctype / html / head / body タグを持たない（公開時にホスト側が包むため）。
# GitHub Pages ではそれらが必要なので、ここで包み直す。
#
# リセットCSSは Artifact ホストの注入内容に合わせてある。box-sizing は
# 意図的に触っていない（border-box にするとパネル幅がずれる）。
set -e
cd "$(dirname "$0")"

SRC=zoshoku-gate.html
OUT=index.html

# <style> の閉じタグまでが head 相当、その先が body 相当
SPLIT=$(grep -n '^</style>$' "$SRC" | head -1 | cut -d: -f1)
[ -n "$SPLIT" ] || { echo "head/body の分割点が見つかりません" >&2; exit 1; }

{
  cat <<'HEAD'
<!doctype html>
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="description" content="ゲートをくぐって軍勢を増やし、武器を鍛え、赤軍を薙ぎ倒す疑似3Dランナー。全10ステージ。">
<meta name="theme-color" content="#241c18">
<meta property="og:title" content="増殖ゲート">
<meta property="og:description" content="広告でよく見るあの系統を、実際に遊べる形にしたブラウザゲーム。">
<meta property="og:type" content="website">
<style>
  :root{color-scheme:light}
  body{margin:0; font:14px system-ui, sans-serif; background:#fafaf9}
  img{max-width:100%}
  [hidden]{display:none!important}
</style>
HEAD
  head -n "$SPLIT" "$SRC"
  echo '</head>'
  echo '<body>'
  tail -n +"$((SPLIT + 1))" "$SRC"
  echo '</body>'
  echo '</html>'
} > "$OUT"

echo "generated $OUT ($(wc -l < "$OUT") lines)"
