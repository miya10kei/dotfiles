#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

// NERD Fonts icons
const ICONS = {
  git: '\uE0A0',      //
  folder: '\uF07C',   //
  ide: '\uF489',      //
  model: '\udb85\udea4',    //
  memory: '\uF85A',   //
};

// ANSI color codes
const COLORS = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  gray: '\x1b[90m',
};

const HOME = os.homedir();
const CLAUDE_DIR = path.join(HOME, '.claude');
const PROJECTS_DIR = path.join(CLAUDE_DIR, 'projects');
const IDE_DIR = path.join(CLAUDE_DIR, 'ide');
const MAX_TOKENS = 200000; // Claude Sonnet 4.5 context limit

function formatNumber(num) {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + 'M';
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K';
  }
  return num.toString();
}

function getColorForPercentage(percentage) {
  if (percentage >= 85) return COLORS.red;
  if (percentage >= 70) return COLORS.yellow;
  return COLORS.green;
}

function getEmojiForPercentage(percentage) {
  if (percentage >= 85) return '🔴';
  if (percentage >= 70) return '🟡';
  return '🟢';
}

function shortenBranchName(branch) {
  // "feature/claude-statusline" -> "claude-statusline"
  const parts = branch.split('/');
  return parts.length > 1 ? parts[parts.length - 1] : branch;
}

function shortenPath(dir) {
  // Replace home directory with ~
  let path = dir;
  if (dir.startsWith(HOME)) {
    path = '~' + dir.slice(HOME.length);
  }

  // Abbreviate each directory except the last one (current directory)
  // "~/.dotfiles" -> "~/.dotfiles" (current directory is kept full)
  // "~/dev/ghq/github.com/org/project" -> "~/d/g/g/o/project"
  const parts = path.split('/');
  if (parts.length === 1) {
    return path; // Don't abbreviate if only ~
  }

  // Abbreviate all except first (~) and last (current directory name)
  const abbreviated = parts.map((part, index) => {
    // Keep first part (~) and last part (current directory) as is
    if (index === 0 || index === parts.length - 1) {
      return part;
    }
    // Abbreviate middle parts to first character
    // For hidden files (.dotfiles), skip the dot and use the next character
    if (part.startsWith('.') && part.length > 1) {
      return '.' + part.charAt(1);
    }
    return part.charAt(0);
  });

  return abbreviated.join('/');
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

function isIDEConnected() {
  try {
    const files = fs.readdirSync(IDE_DIR);
    const lockFiles = files.filter(f => f.endsWith('.lock'));

    if (lockFiles.length === 0) {
      return false;
    }

    // Check if any lock file was modified recently (within last 5 minutes)
    const now = Date.now();
    const fiveMinutesAgo = now - (5 * 60 * 1000);

    for (const file of lockFiles) {
      const filePath = path.join(IDE_DIR, file);
      const stats = fs.statSync(filePath);
      if (stats.mtimeMs > fiveMinutesAgo) {
        return true;
      }
    }

    return false;
  } catch (error) {
    return false;
  }
}

function findCurrentProjectDir() {
  const cwd = process.cwd();
  // Replace /, ., and _ with -
  const normalizedCwd = cwd.replace(/[\/._]/g, '-');
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
    const jsonlFiles = files.filter(f => f.endsWith('.jsonl'));

    if (jsonlFiles.length === 0) {
      return null;
    }

    // Get the most recently modified file
    const latestFile = jsonlFiles
      .map(f => ({
        name: f,
        mtime: fs.statSync(path.join(projectDir, f)).mtime
      }))
      .sort((a, b) => b.mtime - a.mtime)[0];

    return path.join(projectDir, latestFile.name);
  } catch (error) {
    return null;
  }
}

function parseTranscript(transcriptPath) {
  const data = {
    branch: 'unknown',
    cwd: process.cwd(),
    model: 'unknown',
    totalTokens: 0,
  };

  try {
    const content = fs.readFileSync(transcriptPath, 'utf8');
    const lines = content.trim().split('\n');

    // First pass: find the latest sessionId
    let latestSessionId = null;
    let latestTimestamp = 0;

    for (const line of lines) {
      try {
        const entry = JSON.parse(line);
        if (entry.sessionId && entry.timestamp) {
          const timestamp = new Date(entry.timestamp).getTime();
          if (timestamp > latestTimestamp) {
            latestTimestamp = timestamp;
            latestSessionId = entry.sessionId;
          }
        }
      } catch (parseError) {
        // Skip invalid JSON lines
      }
    }

    // Second pass: collect data only from the latest session
    for (const line of lines) {
      try {
        const entry = JSON.parse(line);

        // Only process entries from the latest session
        if (entry.sessionId !== latestSessionId) {
          continue;
        }

        // Get branch from any message
        if (entry.gitBranch) {
          data.branch = entry.gitBranch;
        }

        // Get cwd from any message
        if (entry.cwd) {
          data.cwd = entry.cwd;
        }

        // Get model and tokens from assistant messages
        if (entry.type === 'assistant' && entry.message) {
          if (entry.message.model) {
            data.model = entry.message.model;
          }

          if (entry.message.usage) {
            const usage = entry.message.usage;
            // Only count actual input and output tokens for context size
            // cache_creation and cache_read are for billing, not context size
            data.totalTokens += (usage.input_tokens || 0);
            data.totalTokens += (usage.output_tokens || 0);
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

function main() {
  const projectDir = findCurrentProjectDir();

  if (!projectDir) {
    console.log('No project data found');
    return;
  }

  const transcriptPath = getLatestTranscript(projectDir);

  if (!transcriptPath) {
    console.log('No transcript found');
    return;
  }

  const data = parseTranscript(transcriptPath);
  const ideConnected = isIDEConnected();
  const percentage = ((data.totalTokens / MAX_TOKENS) * 100).toFixed(1);
  const percentageColor = getColorForPercentage(parseFloat(percentage));
  const emoji = getEmojiForPercentage(parseFloat(percentage));

  const parts = [
    `${COLORS.cyan}${ICONS.git}${COLORS.reset} ${shortenBranchName(data.branch)}`,
    `${COLORS.cyan}${ICONS.folder}${COLORS.reset} ${shortenPath(data.cwd)}`,
    `${COLORS.cyan}${ICONS.ide}${COLORS.reset} ${ideConnected ? 'ON' : 'OFF'}`,
    `${COLORS.cyan}${ICONS.model}${COLORS.reset} ${shortenModelName(data.model)}`,
    `${COLORS.cyan}${ICONS.memory}${COLORS.reset} ${formatNumber(data.totalTokens)}/${formatNumber(MAX_TOKENS)}(${percentageColor}${percentage}%${emoji}${COLORS.reset})`,
  ];

  console.log(parts.join('  '));
}

main();
