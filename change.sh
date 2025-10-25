#!/bin/bash

# Configuration
NOW=$(date +%s)
YESTERDAY=$(date -d "yesterday" +%s)
COMMIT_COUNT=$(git rev-list --count HEAD)

echo "Scattering $COMMIT_COUNT commits between yesterday and today..."

# Generate random timestamps
TIMESTAMPS=()
for ((i=0; i<COMMIT_COUNT-1; i++)); do
    RANDOM_TIMESTAMP=$((YESTERDAY + RANDOM % (NOW - YESTERDAY)))
    TIMESTAMPS+=($RANDOM_TIMESTAMP)
done

# Add current time as last commit
TIMESTAMPS+=($NOW)

# Sort timestamps
IFS=$'\n' TIMESTAMPS=($(sort -n <<<"${TIMESTAMPS[*]}"))
unset IFS

# Convert to git date format
DATES=()
for ts in "${TIMESTAMPS[@]}"; do
    DATES+=("$(date -d "@$ts" "+%a %b %d %H:%M:%S %Y %z")")
done

# Show preview
echo "Generated dates:"
for i in "${!DATES[@]}"; do
    echo "  Commit $((i+1)): ${DATES[$i]}"
done

# Apply changes
git filter-branch -f --env-filter '
    commit_num=$(git rev-list --reverse HEAD | grep -n $GIT_COMMIT | cut -d: -f1)
    commit_index=$((commit_num - 1))
    
    DATES=('"$(printf '"%s" ' "${DATES[@]}")"')
    NEW_DATE="${DATES[$commit_index]}"
    
    export GIT_AUTHOR_DATE="$NEW_DATE"
    export GIT_COMMITTER_DATE="$NEW_DATE"
' --tag-name-filter cat -- --all

echo "✅ Complete! Last commit is set to: $(date)"
