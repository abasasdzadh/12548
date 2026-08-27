#!/usr/bin/env bash
# ====================================================================
# Start the Automatic Video Dubbing Engine (backend + frontend).
# Run from the project root:  ./start.sh
# ====================================================================
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

# --- Backend setup ---
BACKEND="$ROOT/backend"
if [ ! -f "$BACKEND/.env" ]; then
  cp "$BACKEND/.env.example" "$BACKEND/.env"
  echo "[start] Created backend/.env from .env.example"
  echo "[start] Edit it to add GEMINI_API_KEY, then re-run."
fi

# Make sure the venv has the python deps.
python3 -c "import fastapi, yt_dlp, faster_whisper, edge_tts" 2>/dev/null \
  || pip3 install -r "$BACKEND/requirements.txt"

# --- Start backend (port 8000) ---
echo "[start] Starting backend on :8000 ..."
(
  cd "$BACKEND"
  PYTHONPATH="$BACKEND" \
  HOST=0.0.0.0 PORT=8000 \
  setsid python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 1 \
    > "$BACKEND/backend.log" 2>&1 &
)

# --- Start frontend (port 3000) ---
echo "[start] Starting frontend on :3000 ..."
bun run dev > "$ROOT/dev.log" 2>&1 &

echo ""
echo "[start] Backend:  http://localhost:8000  (logs: backend/backend.log)"
echo "[start] Frontend: http://localhost:3000   (logs: dev.log)"
echo "[start] Open http://localhost:3000 in your browser."
echo ""
echo "Press Ctrl+C to stop both services."
wait
