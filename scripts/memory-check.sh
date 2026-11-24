#!/bin/sh

echo "===== MEMORY ====="
free -m 2>/dev/null || true

echo
echo "===== TOP MEMORY PROCESSES ====="
ps -eo pid,ppid,%cpu,%mem,rss,comm --sort=-rss 2>/dev/null | head -15

echo
echo "===== CGROUP MEMORY ====="
for f in /sys/fs/cgroup/memory.max /sys/fs/cgroup/memory.current \
         /sys/fs/cgroup/memory/memory.limit_in_bytes \
         /sys/fs/cgroup/memory/memory.usage_in_bytes; do
    if [ -r "$f" ]; then
        printf '%s: ' "$f"
        cat "$f"
    fi
done

echo
echo "===== BROWSER / AUDIO PROCESSES ====="
ps aux 2>/dev/null | grep -Ei 'chromium|pulse|pipewire|ffmpeg' | grep -v grep || true
