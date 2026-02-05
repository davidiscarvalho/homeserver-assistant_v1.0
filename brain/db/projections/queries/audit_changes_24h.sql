SELECT id, created_at, object_type, object_id, action, performed_by, reason
FROM audit_logs
WHERE created_at >= datetime('now','-1 day')
ORDER BY created_at DESC, id DESC
LIMIT 200;
