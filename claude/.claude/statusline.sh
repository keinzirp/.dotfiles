#!/bin/bash
# Wrapper to invoke TypeScript statusline script
exec pnpx tsx "$(dirname "$0")/statusline.ts"
