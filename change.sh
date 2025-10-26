#!/bin/bash

# Generate the date mapping with Python
python3 << 'PYTHON_SCRIPT' > /tmp/commit_dates_map.txt
import subprocess
import random
from datetime import datetime, timedelta

# Get all commits in reverse order (oldest first)
result = subprocess.run(
    ['git', 'rev-list', '--reverse', 'HEAD'],
    capture_output=True,
    text=True
)
commits = result.stdout.strip().split('\n')

# Time range
now = datetime.now()
yesterday = now - timedelta(days=1)

# Generate random timestamps
timestamps = []
for i in range(len(commits) - 1):
    random_seconds = random.uniform(0, (now - yesterday).total_seconds())
    random_time = yesterday + timedelta(seconds=random_seconds)
    timestamps.append(random_time)

# Last commit is NOW
timestamps.append(now)

# Sort timestamps
timestamps.sort()

# Output mapping: commit_hash timestamp
for commit, ts in zip(commits, timestamps):
    git_date = ts.strftime("%a %b %d %H:%M:%S %Y %z")
    print(f"{commit} {git_date}")
PYTHON_SCRIPT

# Show preview
echo "Generated date mappings:"
echo "First commit: $(head -1 /tmp/commit_dates_map.txt)"
echo "Last commit: $(tail -1 /tmp/commit_dates_map.txt)"
echo ""

# Apply using filter-branch
git filter-branch -f --env-filter '
    DATE=$(grep "^$GIT_COMMIT " /tmp/commit_dates_map.txt | cut -d" " -f2-)
    if [ -n "$DATE" ]; then
        export GIT_AUTHOR_DATE="$DATE"
        export GIT_COMMITTER_DATE="$DATE"
    fi
' --tag-name-filter cat -- --all

# Clean up
rm -rf .git/refs/original/
rm /tmp/commit_dates_map.txt

echo "✅ Complete! Check results:"
echo "git log --oneline --format='%h | %ai | %s'"
