#!/usr/bin/env bash

# Get the starting directory (default: current directory)
START_DIR="${1:-.}"

# Directories to ignore
IGNORE_DIRS=("node_modules" "test" "venv" ".git" "dist" "target" "build" ".idea" ".mvn")

# Files to ignore (exact matches, case-sensitive)
IGNORE_FILES=("secrets.env" "config.json" "debug.log" ".gitignore" "package-lock.json" "README.md" "eslint.config.js" "PROMPT.md" "DEV.md" "mvnw" "mvnw.cmd" ".gitattributes" "backend3-sql-access-key.json" "cloud_sql_proxy" "HELP.md" "DEPLOY.md")

# File patterns to ignore (wildcards)
IGNORE_PATTERNS=("*.css" "*.log" "*.env" "*.svg")

# Build the find command dynamically to exclude directories
FIND_CMD="find \"$START_DIR\""
for DIR in "${IGNORE_DIRS[@]}"; do
    FIND_CMD+=" -type d -name \"$DIR\" -prune -o"
done
FIND_CMD+=" -type f -print"  # Ensure it prints files that are not pruned

# Initialize output string
OUTPUT="\n---START-OF-PROJECT-FILES---\n\n"

# Recursively find all files and process them
while IFS= read -r file; do
    # Extract base name
    BASENAME=$(basename "$file")
    NAME_ONLY="${BASENAME%.*}" # Remove extension

    # Skip exact file matches
    for IGNORED_FILE in "${IGNORE_FILES[@]}"; do
        if [[ "$BASENAME" == "$IGNORED_FILE" ]]; then
            continue 2  # Skip to the next file
        fi
    done

    # Skip files matching wildcard patterns
    for PATTERN in "${IGNORE_PATTERNS[@]}"; do
        if [[ "$BASENAME" == $PATTERN ]]; then
            continue 2  # Skip to the next file
        fi
    done

    # Skip files where NAME_ONLY ends with "test" (case-insensitive)
    if [[ "$NAME_ONLY" =~ [Tt][Ee][Ss][Tt]$ ]]; then
        continue
    fi

    # Read file content
    CONTENT=$(cat "$file")
    OUTPUT+="${file}\n\`\`\`\n${CONTENT}\n\`\`\`\n\n"
done < <(eval "$FIND_CMD")

OUTPUT+="---END-OF-PROJECT-FILES---"

# Copy to clipboard (works on macOS)
echo -e "$OUTPUT" | pbcopy
echo -e "$OUTPUT" > clipboard.txt



echo "Combined content copied to clipboard!"

