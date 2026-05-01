# Rideshare ERD

## Grain

- `rideshare.drivers`: one row per driver
- `rideshare.riders`: one row per rider
- `rideshare.rides`: one row per ride request
- `rideshare.payments`: one row per paid ride
- `rideshare.app_events`: one row per app event

## Relationships

- `rides.rider_id -> riders.rider_id`
- `rides.driver_id -> drivers.driver_id`
- `payments.ride_id -> rides.ride_id`
- `app_events.rider_id -> riders.rider_id`

## Interview Angles

- cancellation rate
- supply-demand and surge analysis
- sessionization from event streams
- acceptance latency
- completed ride streaks and cohort behavior
