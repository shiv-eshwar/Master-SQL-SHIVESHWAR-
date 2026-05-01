-- Pattern: median and percentiles
-- Prompt: compute the median completed ride fare.

SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY actual_fare) AS median_completed_fare,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY actual_fare) AS p90_completed_fare
FROM rideshare.rides
WHERE status = 'completed'
  AND actual_fare IS NOT NULL;
