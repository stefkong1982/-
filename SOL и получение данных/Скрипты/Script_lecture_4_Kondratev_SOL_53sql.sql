SELECT constraint_name, table_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
AND constraint_type = 'PRIMARY KEY'
ORDER BY constraint_type DESC;