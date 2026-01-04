INSERT INTO $metrics_table ($metrics_pk, data, last_updated)
WITH RECURSIVE
    batch_inputs AS (
        SELECT 
            key AS batch_idx,
            value ->> '$.target' AS target_id,
            jsonb(value -> '$.data') AS metric_data
        FROM json_each(@group_records)
    ),
    updates AS (
        SELECT 
            b.batch_idx,
            b.target_id,
            tree.fullkey as path,
            json_extract(ms.data, '$.""' || tree.fullkey || '""') as op,
            tree.value as new_val,
            ROW_NUMBER() OVER (PARTITION BY b.target_id ORDER BY b.batch_idx, tree.fullkey) AS seq
        FROM batch_inputs b
        JOIN json_tree(b.metric_data) tree ON tree.atom IS NOT NULL
        JOIN metrics_schema ms ON ms.plugin = @plugin_name AND ms.name = @schema_name
        WHERE json_extract(ms.data, '$.""' || tree.fullkey || '""') IS NOT NULL
    ),
    initial_state AS (
        SELECT 
            b.target_id,
            COALESCE(t.data, jsonb('{}')) AS current_data
        FROM (SELECT DISTINCT target_id FROM batch_inputs) b
        JOIN $target_table tt ON b.target_id = tt.$target_id
        LEFT JOIN $metrics_table t ON tt.$target_id = t.$metrics_pk
    ),
    apply_updates(target_id, current_data, next_seq) AS (
        SELECT target_id, current_data, 1
        FROM initial_state
        UNION ALL
        SELECT 
            a.target_id,
            jsonb_set(
                a.current_data, 
                u.path, 
                CASE u.op
                    WHEN 'ADD' THEN COALESCE(json_extract(a.current_data, u.path), 0) + u.new_val
                    WHEN 'SUB' THEN COALESCE(json_extract(a.current_data, u.path), 0) - u.new_val
                    WHEN 'MAX' THEN MAX(COALESCE(json_extract(a.current_data, u.path), 0), u.new_val)
                    WHEN 'MIN' THEN MIN(COALESCE(json_extract(a.current_data, u.path), 0), u.new_val)
                    WHEN 'KEEP' THEN COALESCE(json_extract(a.current_data, u.path), u.new_val)
                    WHEN 'BIT_OR' THEN COALESCE(json_extract(a.current_data, u.path), 0) | u.new_val
                    WHEN 'NON_ZERO' THEN CASE WHEN u.new_val != 0 THEN u.new_val ELSE json_extract(a.current_data, u.path) END
                    WHEN 'APPEND' THEN jsonb_insert(COALESCE(json_extract(a.current_data, u.path), jsonb('[]')), '$[#]', u.new_val)
                    ELSE u.new_val
                END
            ),
            a.next_seq + 1
        FROM apply_updates a
        JOIN updates u ON a.target_id = u.target_id AND a.next_seq = u.seq
    )
SELECT 
    tt.$target_id,
    final.current_data,
    CURRENT_TIMESTAMP
FROM (
    SELECT target_id, current_data
    FROM apply_updates
    WHERE (target_id, next_seq) IN (
        SELECT target_id, MAX(next_seq) 
        FROM apply_updates 
        GROUP BY target_id
    )
) final
JOIN $target_table tt ON final.target_id = tt.$target_id
ON CONFLICT($metrics_pk) DO UPDATE SET
    data = excluded.data,
    last_updated = excluded.last_updated;