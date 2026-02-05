SELECT id, created_at, event_type, source, substr(payload, 1, 200) AS payload_preview
FROM events
WHERE created_at >= datetime('now','-1 day')
ORDER BY created_at DESC, id DESC
LIMIT 100;
