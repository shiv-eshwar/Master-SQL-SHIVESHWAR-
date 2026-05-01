-- Week 9 examples: gaps and islands, sessionization, and cohort ideas.

WITH ordered_rides AS (
    SELECT
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
    FROM ordered_rides
)
SELECT rider_id, MIN(ride_date) AS streak_start, MAX(ride_date) AS streak_end, COUNT(*) AS streak_len
FROM islands
GROUP BY rider_id, island_key;

WITH ordered_events AS (
    SELECT
        rider_id,
        event_ts,
        CASE
            WHEN event_ts - LAG(event_ts) OVER (PARTITION BY rider_id ORDER BY event_ts) > INTERVAL '30 minutes'
              OR LAG(event_ts) OVER (PARTITION BY rider_id ORDER BY event_ts) IS NULL
            THEN 1 ELSE 0
        END AS is_new_session
    FROM rideshare.app_events
)
SELECT *
FROM ordered_events;
