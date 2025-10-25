#!/usr/bin/env node

const fs = require("fs");
const os = require("os");
const { execSync } = require("child_process");

// ============ 設定 ============

const CONFIG = {
  maxTokens: 200000, // Claude Sonnet 4.5 のコンテキスト制限

  // 表示する項目と順序（ここで追加・削除・並び替え）
  displayItems: ["git", "folder", "model", "memory"],

  // トークン使用量の閾値
  tokenThresholds: {
    warning: 70, // 70%で黄色
    critical: 85, // 85%で赤
  },

  // NERD Fonts アイコン
  icons: {
    git: "\uE0A0",
    folder: "\uF07C",
    model: "\udb85\udea4",
    memory: "\udb80\uddaa",
  },

  // ANSI カラーコード
  colors: {
    reset: "\x1b[0m",
    green: "\x1b[32m",
    yellow: "\x1b[33m",
    red: "\x1b[31m",
    cyan: "\x1b[36m",
    gray: "\x1b[90m",
  },

  // ホームディレクトリ
  home: os.homedir(),
};

// ============ ユーティリティ関数 ============

/**
 * 数値をK/M接尾辞でフォーマット
 */
function formatNumber(num) {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + "M";
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + "K";
  }
  return num.toString();
}

/**
 * パーセンテージに基づいて色を取得
 */
function getColorForPercentage(percentage) {
  const { warning, critical } = CONFIG.tokenThresholds;
  const { red, yellow, green } = CONFIG.colors;

  if (percentage >= critical) return red;
  if (percentage >= warning) return yellow;
  return green;
}

/**
 * パーセンテージに基づいて絵文字インジケータを取得
 */
function getEmojiForPercentage(percentage) {
  const { warning, critical } = CONFIG.tokenThresholds;

  if (percentage >= critical) return "🔴";
  if (percentage >= warning) return "🟡";
  return "🟢";
}

/**
 * Gitブランチ名を短縮（プレフィックスを削除）
 */
function shortenBranchName(branch) {
  if (!branch) return "unknown";
  const parts = branch.split("/");
  return parts.length > 1 ? parts[parts.length - 1] : branch;
}

/**
 * パスを省略形で短縮
 */
function shortenPath(dir) {
  if (!dir) return "~";

  // ホームディレクトリを ~ に置換
  let pathStr = dir;
  if (dir.startsWith(CONFIG.home)) {
    pathStr = "~" + dir.slice(CONFIG.home.length);
  }

  const parts = pathStr.split("/");
  if (parts.length === 1) {
    return pathStr;
  }

  // 最初(~)と最後(カレントディレクトリ名)以外を省略
  const abbreviated = parts.map((part, index) => {
    if (index === 0 || index === parts.length - 1) {
      return part;
    }
    // 隠しファイル(.dotfiles)の場合、ドットをスキップ
    if (part.startsWith(".") && part.length > 1) {
      return "." + part.charAt(1);
    }
    return part.charAt(0);
  });

  return abbreviated.join("/");
}

/**
 * メモリ使用量の表示をフォーマット
 */
function formatMemoryDisplay(data) {
  const { total, percentage } = data;
  const percentageStr = percentage.toFixed(1);
  const color = getColorForPercentage(percentage);
  const emoji = getEmojiForPercentage(percentage);

  return `${formatNumber(total)}/${formatNumber(CONFIG.maxTokens)}(${color}${percentageStr}%${emoji}${CONFIG.colors.reset})`;
}

// ============ データ収集関数 ============

/**
 * 現在のGitブランチを取得
 */
function getCurrentBranch() {
  try {
    const branch = execSync("git branch --show-current", {
      encoding: "utf8",
      cwd: process.cwd(),
      stdio: ["pipe", "pipe", "ignore"], // stderrを抑制
    });
    return branch.trim() || null;
  } catch (error) {
    return null;
  }
}

/**
 * トランスクリプトを解析してセッションのトークン使用量を計算
 */
function parseTranscript(transcriptPath, sessionId) {
  try {
    const content = fs.readFileSync(transcriptPath, "utf8");
    const lines = content.trim().split("\n");

    let totalTokens = 0;

    for (const line of lines) {
      try {
        const entry = JSON.parse(line);

        // 現在のセッションのエントリのみ処理
        if (entry.sessionId !== sessionId) {
          continue;
        }

        // アシスタントメッセージからトークンを取得
        if (entry.type === "assistant" && entry.message?.usage) {
          const usage = entry.message.usage;
          // コンテキストサイズには実際の入出力トークンのみをカウント
          totalTokens += usage.input_tokens || 0;
          totalTokens += usage.output_tokens || 0;
        }
      } catch (parseError) {
        // 無効なJSON行をスキップ
      }
    }

    return totalTokens;
  } catch (error) {
    return 0;
  }
}

/**
 * トークン使用量データを取得
 */
function getTokenData(context) {
  const { transcriptPath, sessionId } = context;

  if (!transcriptPath || !sessionId) {
    return { total: 0, percentage: 0 };
  }

  const totalTokens = parseTranscript(transcriptPath, sessionId);
  const percentage = (totalTokens / CONFIG.maxTokens) * 100;

  return {
    total: totalTokens,
    percentage: percentage,
  };
}

/**
 * stdinからJSONを読み込み
 */
async function readStdin() {
  return new Promise((resolve) => {
    let data = "";
    process.stdin.on("data", (chunk) => {
      data += chunk;
    });
    process.stdin.on("end", () => {
      try {
        resolve(JSON.parse(data));
      } catch (error) {
        resolve(null);
      }
    });
  });
}

// ============ ステータス項目定義 ============

const STATUS_ITEMS = {
  git: {
    icon: "git",
    getData: () => getCurrentBranch(),
    format: (data) => shortenBranchName(data),
  },

  folder: {
    icon: "folder",
    getData: (context) => context.cwd,
    format: (data) => shortenPath(data),
  },

  model: {
    icon: "model",
    getData: (context) => context.modelName || "Unknown",
    format: (data) => data,
  },

  memory: {
    icon: "memory",
    getData: (context) => getTokenData(context),
    format: formatMemoryDisplay,
  },
};

// ============ レンダリングエンジン ============

/**
 * 単一のステータス項目をレンダリング
 */
function renderItem(itemName, context) {
  try {
    const item = STATUS_ITEMS[itemName];
    if (!item) {
      return null;
    }

    const data = item.getData(context);
    const formatted = item.format(data);
    const icon = CONFIG.icons[item.icon] || "";

    return `${CONFIG.colors.cyan}${icon}${CONFIG.colors.reset} ${formatted}`;
  } catch (error) {
    // 項目が失敗した場合は静かにスキップ
    return null;
  }
}

/**
 * 完全なステータスラインをレンダリング
 */
function renderStatusLine(context) {
  return CONFIG.displayItems
    .map((name) => renderItem(name, context))
    .filter(Boolean)
    .join("  ");
}

// ============ メイン処理 ============

async function main() {
  // stdinからJSONを読み込み
  const stdinData = await readStdin();
  console.log(stdinData);

  if (!stdinData) {
    console.log("No stdin data");
    return;
  }

  // stdinデータからコンテキストを構築
  const context = {
    modelName: stdinData.model?.display_name,
    cwd: stdinData.workspace?.current_dir,
    transcriptPath: stdinData.transcript_path,
    sessionId: stdinData.session_id,
  };

  // ステータスラインをレンダリングして出力
  const statusLine = renderStatusLine(context);
  console.log(statusLine);
}

main();
