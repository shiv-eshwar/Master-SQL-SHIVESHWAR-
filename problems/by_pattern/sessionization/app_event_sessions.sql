-- Pattern: sessionization
-- Prompt: group rider app events into 30-minute sessions.

WITH event_gaps AS (
    SELECT
        rider_id,
        event_ts,
        CASE
            WHEN LAG(event_ts) OVER (PARTITION BY rider_id ORDER BY event_ts) IS NULL
              OR event_ts - LAG(event_ts) OVER (PARTITION BY rider_id ORDER BY event_ts) > INTERVAL '30 minutes'
            THEN 1 ELSE 0
        END AS new_session_flag
    FROM rideshare.app_events
),
labeled AS (
    SELECT
        rider_id,
        event_ts,
        SUM(new_session_flag) OVER (
            PARTITION BY rider_id
            ORDER BY event_ts
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS session_id
    FROM event_gaps
)
SELECT
    rider_id,
    session_id,
    MIN(event_ts) AS session_start,
    MAX(event_ts) AS session_end,
    COUNT(*) AS event_count
FROM labeled
GROUP BY rider_id, session_id
ORDER BY rider_id, session_id;
