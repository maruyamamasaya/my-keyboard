CREATE TABLE IF NOT EXISTS clipboard (
    id TEXT PRIMARY KEY NOT NULL,
    text TEXT NOT NULL UNIQUE COLLATE BINARY,
    created_at REAL NOT NULL,
    last_used_at REAL NOT NULL,
    pinned INTEGER NOT NULL DEFAULT 0 CHECK (pinned IN (0, 1))
);
CREATE INDEX IF NOT EXISTS clipboard_order ON clipboard(pinned DESC, last_used_at DESC);
PRAGMA user_version = 1;
