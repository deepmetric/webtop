#!/bin/sh

echo "===== WEBTOP DIAGNOSTICS ====="
echo
echo "OS:"
cat /etc/os-release 2>/dev/null || true

echo
echo "Chromium:"
command -v chromium || command -v chromium-browser || true

echo
echo "Audio tools:"
command -v pactl || true
command -v pulseaudio || true

echo
echo "Supervised services:"
ls -la /run/service/ 2>/dev/null || true

echo
echo "Startup locations:"
for d in /etc/cont-init.d /etc/services.d /etc/xdg/autostart /config/.config/icewm; do
    if [ -d "$d" ]; then
        echo "--- $d"
        find "$d" -maxdepth 2 -type f 2>/dev/null
    fi
done

echo
echo "Memory:"
free -m 2>/dev/null || true

echo
echo "Disk:"
df -h 2>/dev/null || true
