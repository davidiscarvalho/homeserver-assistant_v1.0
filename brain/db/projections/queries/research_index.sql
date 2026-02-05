SELECT id, created_at, title, source, ref_path, tags
FROM memories
WHERE kind = 'knowledge'
  AND ref_path IS NOT NULL
ORDER BY created_at DESC, id DESC
LIMIT 200;
