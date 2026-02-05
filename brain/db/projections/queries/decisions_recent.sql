SELECT id, created_at, decision, made_by, autonomy_level
FROM decisions
WHERE created_at >= datetime('now','-7 days')
ORDER BY created_at DESC, id DESC
LIMIT 50;
