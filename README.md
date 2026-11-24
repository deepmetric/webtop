# Optimised Webtop Alpine-IceWM overlay

This project is a conservative overlay for an existing image named
`webtop:alpine-icewm`. It preserves the base image's original entrypoint,
CMD and service supervision. It does **not** aggressively delete services.

## Contents

- `Dockerfile`: adds Chromium only if it is absent, plus diagnostic utilities.
- `scripts/chromium-start.sh`: optional Chromium launcher with conservative flags.
- `scripts/memory-check.sh`: reports memory and largest processes.
- `scripts/diagnose.sh`: reports image, audio, service and startup details.
- `docker-compose.yml`: local test configuration with a 512 MB memory limit.

## Build and run

1. Ensure the base image exists locally:

   ```sh
   docker image inspect webtop:alpine-icewm
   ```

2. Copy `.env.example` to `.env` and set a strong password:

   ```sh
   cp .env.example .env
   ```

3. Build and start:

   ```sh
   docker compose build
   docker compose up -d
   docker compose logs -f webtop
   ```

4. Open `https://localhost:3001` if your Webtop image serves HTTPS on port 3001.
   If your image uses different ports or authentication variables, follow that
   image's own documentation and adjust Compose accordingly.

## Run diagnostics

```sh
docker exec -it webtop-optimised /opt/webtop/scripts/diagnose.sh
docker exec -it webtop-optimised /opt/webtop/scripts/memory-check.sh
```

## Optional Chromium launch

The launcher is provided but is **not automatically installed into IceWM
startup**. First inspect the base image's existing startup mechanism:

```sh
docker exec -it webtop-optimised sh
find /etc/cont-init.d /etc/services.d /etc/xdg/autostart \
     /config/.config/icewm -maxdepth 2 -type f 2>/dev/null
```

Integrate `/opt/webtop/scripts/chromium-start.sh` into the existing desktop
startup mechanism only after confirming the correct location and preserving
the existing startup script. Avoid starting a second Chromium instance if
Webtop already launches one.

## Audio

The launcher does not mute audio. Keep the audio server and Webtop audio
configuration supplied by the base image. Do not add PulseAudio or FFmpeg
unless diagnostics show they are missing and your audio routing requires them.
`pactl` can be used to inspect an existing PulseAudio-compatible server.

## Important 512 MB notes

- 512 MB is very tight for Webtop + X11 + KasmVNC + Chromium + audio.
- `mem_limit: 512m` is a local Docker limit; it does not configure Render's
  service plan.
- `shm_size: 64mb` is an experimental compromise and may cause browser or
  display crashes. Increase it if you see shared-memory errors.
- Chromium flags can affect site compatibility. Remove individual flags if
  playback or a website stops working.
- Do not blindly remove D-Bus, s6 services, audio services, X11 or KasmVNC.
- Do not expose the desktop directly to the public internet. Use HTTPS and
  strong authentication, and put it behind an appropriately secured proxy.

## Next step: inspect the exact base image

Run:

```sh
docker run --rm --entrypoint sh webtop:alpine-icewm -c '
  cat /etc/os-release
  echo "=== browser ==="
  command -v chromium || command -v chromium-browser || true
  echo "=== audio ==="
  command -v pactl || true
  command -v pulseaudio || true
  echo "=== services ==="
  ls -la /run/service/ 2>/dev/null || true
  echo "=== startup ==="
  find /etc/cont-init.d /etc/services.d /etc/xdg/autostart \
       /config/.config/icewm -maxdepth 2 -type f 2>/dev/null
' > webtop-inspection.txt
```

Share `webtop-inspection.txt` to identify safe, image-specific service changes.
