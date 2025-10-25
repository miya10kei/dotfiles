#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const os = require("os");

// NERD Fonts icons
const ICONS = {
  git: "\uE0A0",
  folder: "\uF07C",
  model: "\udb85\udea4",
  memory: "\udb80\uddaa",
};

// ANSI color codes
const COLORS = {
  reset: "\x1b[0m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  red: "\x1b[31m",
  cyan: "\x1b[36m",
  gray: "\x1b[90m",
};

const HOME = os.homedir();
const CLAUDE_DIR = path.join(HOME, ".claude");
const PROJECTS_DIR = path.join(CLAUDE_DIR, "projects");
const MAX_TOKENS = 200000; // Claude Sonnet 4.5 context limit

function formatNumber(num) {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + "M";
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + "K";
  }
  return num.toString();
}

function getColorForPercentage(percentage) {
  if (percentage >= 85) return COLORS.red;
  if (percentage >= 70) return COLORS.yellow;
  return COLORS.green;
}

function getEmojiForPercentage(percentage) {
  if (percentage >= 85) return "🔴";
  if (percentage >= 70) return "🟡";
  return "🟢";
}

function shortenBranchName(branch) {
  // "feature/claude-statusline" -> "claude-statusline"
  const parts = branch.split("/");
  return parts.length > 1 ? parts[parts.length - 1] : branch;
}

function shortenPath(dir) {
  // Replace home directory with ~
  let pathStr = dir;
  if (dir.startsWith(HOME)) {
    pathStr = "~" + dir.slice(HOME.length);
  }

  // "~/dev/ghq/github.com/org/project" -> "~/d/g/g/o/project"
  const parts = pathStr.split("/");
  if (parts.length === 1) {
    return pathStr; // Don't abbreviate if only ~
  }

  // Abbreviate all except first (~) and last (current directory name)
  const abbreviated = parts.map((part, index) => {
    // Keep first part (~) and last part (current directory) as is
    if (index === 0 || index === parts.length - 1) {
      return part;
    }
    // Abbreviate middle parts to first character
    // For hidden files (.dotfiles), skip the dot and use the next character
    if (part.startsWith(".") && part.length > 1) {
      return "." + part.charAt(1);
    }
    return part.charAt(0);
  });

  return abbreviated.join("/");
}

function shortenModelName(modelName) {
  // "claude-sonnet-4-5-20250929" -> "Son4.5"
  // "claude-opus-4-0-20250101" -> "Opu4.0"
  // "claude-haiku-4-0-20250101" -> "Hai4.0"
  const match = modelName.match(/claude-(sonnet|opus|haiku)-(\d)-(\d)/);
  if (match) {
    const type = match[1].charAt(0).toUpperCase() + match[1].slice(1, 3);
    return `${type}${match[2]}.${match[3]}`;
  }
  return modelName;
}

function getCurrentBranch() {
  try {
    const { execSync } = require("child_process");
    const branch = execSync("git branch --show-current", {
      encoding: "utf8",
      cwd: process.cwd(),
    });
    return branch.trim();
  } catch (error) {
    return null;
  }
}

function findCurrentProjectDir(cwd) {
  // Replace /, ., and _ with -
  const normalizedCwd = cwd.replace(/[\/._]/g, "-");
  const projectDirName = normalizedCwd;
  const projectDir = path.join(PROJECTS_DIR, projectDirName);

  if (fs.existsSync(projectDir)) {
    return projectDir;
  }

  return null;
}

function getLatestTranscript(projectDir) {
  try {
    const files = fs.readdirSync(projectDir);
    const jsonlFiles = files.filter((f) => f.endsWith(".jsonl"));

    if (jsonlFiles.length === 0) {
      return null;
    }

    // Get the most recently modified file
    const latestFile = jsonlFiles
      .map((f) => ({
        name: f,
        mtime: fs.statSync(path.join(projectDir, f)).mtime,
      }))
      .sort((a, b) => b.mtime - a.mtime)[0];

    return path.join(projectDir, latestFile.name);
  } catch (error) {
    return null;
  }
}

function parseTranscript(transcriptPath, sessionId) {
  const data = {
    totalTokens: 0,
  };

  try {
    const content = fs.readFileSync(transcriptPath, "utf8");
    const lines = content.trim().split("\n");

    // Collect data only from the current session
    for (const line of lines) {
      try {
        const entry = JSON.parse(line);

        // Only process entries from the current session
        if (entry.sessionId !== sessionId) {
          continue;
        }

        // Get model and tokens from assistant messages
        if (entry.type === "assistant" && entry.message) {
          if (entry.message.usage) {
            const usage = entry.message.usage;
            // Only count actual input and output tokens for context size
            // cache_creation and cache_read are for billing, not context size
            data.totalTokens += usage.input_tokens || 0;
            data.totalTokens += usage.output_tokens || 0;
          }
        }
      } catch (parseError) {
        // Skip invalid JSON lines
      }
    }
  } catch (error) {
    // Return default data if file reading fails
  }

  return data;
}

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

async function main() {
  // Read JSON from stdin
  const stdinData = await readStdin();

  if (!stdinData) {
    console.log("No stdin data");
    return;
  }

  // Get information from stdin
  const modelName = stdinData.model.display_name;
  const cwd = stdinData.workspace.current_dir;
  const sessionId = stdinData.session_id;

  // Get branch from git command
  const branch = getCurrentBranch() || "unknown";

  // Calculate token usage from transcript
  let totalTokens = 0;
  const projectDir = findCurrentProjectDir(cwd);
  if (projectDir && sessionId) {
    const transcriptPath = getLatestTranscript(projectDir);
    if (transcriptPath) {
      const transcriptData = parseTranscript(transcriptPath, sessionId);
      totalTokens = transcriptData.totalTokens;
    }
  }

  const percentage = ((totalTokens / MAX_TOKENS) * 100).toFixed(1);
  const percentageColor = getColorForPercentage(parseFloat(percentage));
  const emoji = getEmojiForPercentage(parseFloat(percentage));

  const parts = [
    `${COLORS.cyan}${ICONS.git}${COLORS.reset} ${shortenBranchName(branch)}`,
    `${COLORS.cyan}${ICONS.folder}${COLORS.reset} ${shortenPath(cwd)}`,
    `${COLORS.cyan}${ICONS.model}${COLORS.reset} ${modelName}`,
    `${COLORS.cyan}${ICONS.memory}${COLORS.reset} ${formatNumber(totalTokens)}/${formatNumber(MAX_TOKENS)}(${percentageColor}${percentage}%${emoji}${COLORS.reset})`,
  ];

  console.log(parts.join("  "));
}

main();
