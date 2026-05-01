DROP SCHEMA IF EXISTS rideshare CASCADE;
CREATE SCHEMA rideshare;

CREATE TABLE rideshare.drivers (
    driver_id integer PRIMARY KEY,
    city text NOT NULL,
    joined_date date NOT NULL,
    vehicle_type text NOT NULL,
    rating numeric(3, 2) NOT NULL CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE rideshare.riders (
    rider_id integer PRIMARY KEY,
    city text NOT NULL,
    signup_date date NOT NULL,
    referral_source text NOT NULL
);

CREATE TABLE rideshare.rides (
    ride_id bigint PRIMARY KEY,
    rider_id integer NOT NULL REFERENCES rideshare.riders(rider_id),
    driver_id integer NOT NULL REFERENCES rideshare.drivers(driver_id),
    requested_ts timestamptz NOT NULL,
    accepted_ts timestamptz,
    pickup_ts timestamptz,
    completed_ts timestamptz,
    cancelled_ts timestamptz,
    status text NOT NULL CHECK (status IN ('requested', 'accepted', 'completed', 'rider_cancelled', 'driver_cancelled')),
    estimated_fare numeric(10, 2) NOT NULL,
    actual_fare numeric(10, 2),
    surge_multiplier numeric(4, 2) NOT NULL DEFAULT 1.0
);

CREATE TABLE rideshare.payments (
    payment_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ride_id bigint NOT NULL UNIQUE REFERENCES rideshare.rides(ride_id),
    paid_ts timestamptz,
    payment_method text NOT NULL,
    gross_amount numeric(10, 2) NOT NULL,
    driver_payout numeric(10, 2),
    platform_fee numeric(10, 2)
);

CREATE TABLE rideshare.app_events (
    event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rider_id integer NOT NULL REFERENCES rideshare.riders(rider_id),
    event_ts timestamptz NOT NULL,
    event_name text NOT NULL,
    city text NOT NULL
);

INSERT INTO rideshare.drivers (driver_id, city, joined_date, vehicle_type, rating) VALUES
(1, 'Bengaluru', DATE '2022-01-10', 'sedan', 4.90),
(2, 'Bengaluru', DATE '2022-02-14', 'bike', 4.75),
(3, 'Hyderabad', DATE '2022-04-01', 'sedan', 4.82),
(4, 'Mumbai', DATE '2022-05-11', 'auto', 4.60),
(5, 'Bengaluru', DATE '2023-01-02', 'sedan', 4.88);

INSERT INTO rideshare.riders (rider_id, city, signup_date, referral_source) VALUES
(101, 'Bengaluru', DATE '2023-01-01', 'organic'),
(102, 'Bengaluru', DATE '2023-01-03', 'friend_referral'),
(103, 'Hyderabad', DATE '2023-01-10', 'organic'),
(104, 'Mumbai', DATE '2023-02-08', 'paid_search'),
(105, 'Bengaluru', DATE '2023-02-21', 'organic'),
(106, 'Bengaluru', DATE '2023-03-04', 'paid_social');

INSERT INTO rideshare.rides (
    ride_id,
    rider_id,
    driver_id,
    requested_ts,
    accepted_ts,
    pickup_ts,
    completed_ts,
    cancelled_ts,
    status,
    estimated_fare,
    actual_fare,
    surge_multiplier
) VALUES
(5001, 101, 1, TIMESTAMPTZ '2023-03-01 08:00:00+05:30', TIMESTAMPTZ '2023-03-01 08:01:00+05:30', TIMESTAMPTZ '2023-03-01 08:10:00+05:30', TIMESTAMPTZ '2023-03-01 08:35:00+05:30', NULL, 'completed', 320, 340, 1.0),
(5002, 101, 2, TIMESTAMPTZ '2023-03-01 18:05:00+05:30', TIMESTAMPTZ '2023-03-01 18:06:00+05:30', TIMESTAMPTZ '2023-03-01 18:11:00+05:30', TIMESTAMPTZ '2023-03-01 18:30:00+05:30', NULL, 'completed', 180, 195, 1.2),
(5003, 102, 1, TIMESTAMPTZ '2023-03-02 09:15:00+05:30', TIMESTAMPTZ '2023-03-02 09:17:00+05:30', NULL, NULL, TIMESTAMPTZ '2023-03-02 09:20:00+05:30', 'rider_cancelled', 260, NULL, 1.0),
(5004, 103, 3, TIMESTAMPTZ '2023-03-03 19:00:00+05:30', TIMESTAMPTZ '2023-03-03 19:02:00+05:30', TIMESTAMPTZ '2023-03-03 19:09:00+05:30', TIMESTAMPTZ '2023-03-03 19:41:00+05:30', NULL, 'completed', 410, 430, 1.3),
(5005, 104, 4, TIMESTAMPTZ '2023-03-05 11:30:00+05:30', NULL, NULL, NULL, TIMESTAMPTZ '2023-03-05 11:36:00+05:30', 'driver_cancelled', 220, NULL, 1.0),
(5006, 105, 5, TIMESTAMPTZ '2023-03-08 08:20:00+05:30', TIMESTAMPTZ '2023-03-08 08:21:00+05:30', TIMESTAMPTZ '2023-03-08 08:25:00+05:30', TIMESTAMPTZ '2023-03-08 08:55:00+05:30', NULL, 'completed', 380, 400, 1.1),
(5007, 106, 1, TIMESTAMPTZ '2023-03-10 22:00:00+05:30', TIMESTAMPTZ '2023-03-10 22:02:00+05:30', TIMESTAMPTZ '2023-03-10 22:08:00+05:30', TIMESTAMPTZ '2023-03-10 22:33:00+05:30', NULL, 'completed', 360, 390, 1.4),
(5008, 101, 5, TIMESTAMPTZ '2023-03-11 07:45:00+05:30', TIMESTAMPTZ '2023-03-11 07:46:00+05:30', TIMESTAMPTZ '2023-03-11 07:52:00+05:30', TIMESTAMPTZ '2023-03-11 08:10:00+05:30', NULL, 'completed', 150, 150, 1.0);

INSERT INTO rideshare.payments (ride_id, paid_ts, payment_method, gross_amount, driver_payout, platform_fee) VALUES
(5001, TIMESTAMPTZ '2023-03-01 08:36:00+05:30', 'upi', 340, 255, 85),
(5002, TIMESTAMPTZ '2023-03-01 18:31:00+05:30', 'wallet', 195, 146.25, 48.75),
(5004, TIMESTAMPTZ '2023-03-03 19:42:00+05:30', 'card', 430, 322.50, 107.50),
(5006, TIMESTAMPTZ '2023-03-08 08:56:00+05:30', 'upi', 400, 300, 100),
(5007, TIMESTAMPTZ '2023-03-10 22:34:00+05:30', 'card', 390, 292.50, 97.50),
(5008, TIMESTAMPTZ '2023-03-11 08:11:00+05:30', 'upi', 150, 112.50, 37.50);

INSERT INTO rideshare.app_events (rider_id, event_ts, event_name, city) VALUES
(101, TIMESTAMPTZ '2023-03-01 07:58:00+05:30', 'open_app', 'Bengaluru'),
(101, TIMESTAMPTZ '2023-03-01 07:59:30+05:30', 'search_ride', 'Bengaluru'),
(101, TIMESTAMPTZ '2023-03-01 08:00:00+05:30', 'request_ride', 'Bengaluru'),
(101, TIMESTAMPTZ '2023-03-01 17:59:00+05:30', 'open_app', 'Bengaluru'),
(101, TIMESTAMPTZ '2023-03-01 18:05:00+05:30', 'request_ride', 'Bengaluru'),
(102, TIMESTAMPTZ '2023-03-02 09:10:00+05:30', 'open_app', 'Bengaluru'),
(102, TIMESTAMPTZ '2023-03-02 09:15:00+05:30', 'request_ride', 'Bengaluru'),
(103, TIMESTAMPTZ '2023-03-03 18:50:00+05:30', 'open_app', 'Hyderabad'),
(103, TIMESTAMPTZ '2023-03-03 19:00:00+05:30', 'request_ride', 'Hyderabad'),
(105, TIMESTAMPTZ '2023-03-08 08:10:00+05:30', 'open_app', 'Bengaluru'),
(105, TIMESTAMPTZ '2023-03-08 08:20:00+05:30', 'request_ride', 'Bengaluru'),
(106, TIMESTAMPTZ '2023-03-10 21:50:00+05:30', 'open_app', 'Bengaluru'),
(106, TIMESTAMPTZ '2023-03-10 22:00:00+05:30', 'request_ride', 'Bengaluru');
