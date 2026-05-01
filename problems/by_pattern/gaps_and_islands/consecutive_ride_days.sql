-- Pattern: gaps and islands
-- Prompt: find consecutive completed-ride date streaks per rider.

WITH ordered_days AS (
    SELECT DISTINCT
        rider_id,
        requested_ts::date AS ride_date,
        ROW_NUMBER() OVER (
            PARTITION BY rider_id
            ORDER BY requested_ts::date
        ) AS rn
    FROM rideshare.rides
    WHERE status = 'completed'
),
islands AS (
    SELECT
        rider_id,
        ride_date,
        ride_date - rn AS island_key
    FROM ordered_days
)
SELECT
    rider_id,
    MIN(ride_date) AS streak_start,
    MAX(ride_date) AS streak_end,
    COUNT(*) AS streak_length
FROM islands
GROUP BY rider_id, island_key
ORDER BY rider_id, streak_start;
