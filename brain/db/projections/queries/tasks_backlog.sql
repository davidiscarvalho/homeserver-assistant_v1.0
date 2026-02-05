SELECT id, title, priority, due_at, status
FROM tasks
WHERE status != 'done'
ORDER BY priority ASC, due_at IS NULL, due_at, id ASC
LIMIT 50;
