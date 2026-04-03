#!/usr/bin/env bash
# Claude Code status line script
# Reads JSON from stdin and outputs a formatted status line.

input=$(cat)

user=$(whoami)
host=$(hostname -s)
dir=$(echo "$input" | jq -r '.cwd' | xargs basename)

# Token usage (current context window call)
input_tok=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
output_tok=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // empty')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')
cache_write=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Build token stats segment only when data is available
token_part=""
if [ -n "$input_tok" ]; then
  token_part=" in:${input_tok}"
fi
if [ -n "$output_tok" ]; then
  token_part="${token_part} out:${output_tok}"
fi
if [ -n "$cache_read" ] && [ "$cache_read" != "0" ]; then
  token_part="${token_part} cr:${cache_read}"
fi
if [ -n "$cache_write" ] && [ "$cache_write" != "0" ]; then
  token_part="${token_part} cw:${cache_write}"
fi
if [ -n "$used_pct" ]; then
  used_fmt=$(printf "%.0f" "$used_pct")
  token_part="${token_part} ctx:${used_fmt}%"
fi

# prompt-style: user@host:dir [in:N out:N cr:N cw:N ctx:N%]
if [ -n "$token_part" ]; then
  printf '\033[32m%s@%s\033[0m:\033[34m%s\033[0m \033[90m[%s\033[90m]\033[0m' \
    "$user" "$host" "$dir" "${token_part# }"
else
  printf '\033[32m%s@%s\033[0m:\033[34m%s\033[0m' \
    "$user" "$host" "$dir"
fi
