-- Pattern: consecutive rows
-- Prompt: compare each completed ride fare with the previous completed fare for the same rider.

SELECT
    rider_id,
    ride_id,
    requested_ts,
    actual_fare,
    LAG(actual_fare) OVER (
        PARTITION BY rider_id
        ORDER BY requested_ts
    ) AS previous_fare,
    actual_fare - LAG(actual_fare) OVER (
        PARTITION BY rider_id
        ORDER BY requested_ts
    ) AS fare_change
FROM rideshare.rides
WHERE status = 'completed'
ORDER BY rider_id, requested_ts;
