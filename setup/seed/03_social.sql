DROP SCHEMA IF EXISTS social CASCADE;
CREATE SCHEMA social;

CREATE TABLE social.users (
    user_id integer PRIMARY KEY,
    username text NOT NULL UNIQUE,
    signup_ts timestamptz NOT NULL,
    country text NOT NULL,
    is_verified boolean NOT NULL DEFAULT false
);

CREATE TABLE social.posts (
    post_id bigint PRIMARY KEY,
    user_id integer NOT NULL REFERENCES social.users(user_id),
    created_ts timestamptz NOT NULL,
    content_type text NOT NULL CHECK (content_type IN ('text', 'image', 'video')),
    impressions integer NOT NULL DEFAULT 0,
    is_deleted boolean NOT NULL DEFAULT false
);

CREATE TABLE social.follows (
    follower_id integer NOT NULL REFERENCES social.users(user_id),
    followee_id integer NOT NULL REFERENCES social.users(user_id),
    followed_ts timestamptz NOT NULL,
    PRIMARY KEY (follower_id, followee_id),
    CHECK (follower_id <> followee_id)
);

CREATE TABLE social.likes (
    user_id integer NOT NULL REFERENCES social.users(user_id),
    post_id bigint NOT NULL REFERENCES social.posts(post_id),
    liked_ts timestamptz NOT NULL,
    PRIMARY KEY (user_id, post_id)
);

CREATE TABLE social.comments (
    comment_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    post_id bigint NOT NULL REFERENCES social.posts(post_id),
    user_id integer NOT NULL REFERENCES social.users(user_id),
    commented_ts timestamptz NOT NULL,
    comment_text text NOT NULL
);

INSERT INTO social.users (user_id, username, signup_ts, country, is_verified) VALUES
(1, 'ava', TIMESTAMPTZ '2023-01-01 09:00:00+05:30', 'India', true),
(2, 'ben', TIMESTAMPTZ '2023-01-04 10:00:00+05:30', 'India', false),
(3, 'cara', TIMESTAMPTZ '2023-01-09 11:00:00+05:30', 'US', true),
(4, 'dan', TIMESTAMPTZ '2023-01-15 12:00:00+05:30', 'UK', false),
(5, 'eva', TIMESTAMPTZ '2023-02-01 08:00:00+05:30', 'India', true),
(6, 'farah', TIMESTAMPTZ '2023-02-03 08:30:00+05:30', 'UAE', false),
(7, 'glen', TIMESTAMPTZ '2023-02-10 07:30:00+05:30', 'Singapore', false),
(8, 'hari', TIMESTAMPTZ '2023-02-22 18:00:00+05:30', 'India', true);

INSERT INTO social.posts (post_id, user_id, created_ts, content_type, impressions, is_deleted) VALUES
(1001, 1, TIMESTAMPTZ '2023-03-01 09:00:00+05:30', 'text', 500, false),
(1002, 1, TIMESTAMPTZ '2023-03-03 19:00:00+05:30', 'video', 3200, false),
(1003, 2, TIMESTAMPTZ '2023-03-04 10:30:00+05:30', 'image', 1200, false),
(1004, 3, TIMESTAMPTZ '2023-03-04 14:00:00+05:30', 'video', 4800, false),
(1005, 4, TIMESTAMPTZ '2023-03-10 08:15:00+05:30', 'text', 200, false),
(1006, 5, TIMESTAMPTZ '2023-03-11 17:45:00+05:30', 'image', 1700, false),
(1007, 6, TIMESTAMPTZ '2023-03-12 21:00:00+05:30', 'video', 2600, false),
(1008, 7, TIMESTAMPTZ '2023-03-20 09:10:00+05:30', 'text', 150, true),
(1009, 8, TIMESTAMPTZ '2023-03-25 13:20:00+05:30', 'video', 5400, false);

INSERT INTO social.follows (follower_id, followee_id, followed_ts) VALUES
(1, 2, TIMESTAMPTZ '2023-03-01 09:05:00+05:30'),
(1, 3, TIMESTAMPTZ '2023-03-01 09:06:00+05:30'),
(2, 1, TIMESTAMPTZ '2023-03-02 10:00:00+05:30'),
(2, 3, TIMESTAMPTZ '2023-03-02 10:01:00+05:30'),
(3, 1, TIMESTAMPTZ '2023-03-03 11:00:00+05:30'),
(4, 1, TIMESTAMPTZ '2023-03-11 08:20:00+05:30'),
(5, 1, TIMESTAMPTZ '2023-03-11 17:50:00+05:30'),
(5, 3, TIMESTAMPTZ '2023-03-12 09:00:00+05:30'),
(6, 5, TIMESTAMPTZ '2023-03-13 12:00:00+05:30'),
(7, 1, TIMESTAMPTZ '2023-03-20 09:20:00+05:30'),
(8, 1, TIMESTAMPTZ '2023-03-25 13:25:00+05:30'),
(8, 3, TIMESTAMPTZ '2023-03-25 13:26:00+05:30');

INSERT INTO social.likes (user_id, post_id, liked_ts) VALUES
(2, 1001, TIMESTAMPTZ '2023-03-01 09:15:00+05:30'),
(3, 1001, TIMESTAMPTZ '2023-03-01 09:17:00+05:30'),
(4, 1002, TIMESTAMPTZ '2023-03-03 19:20:00+05:30'),
(5, 1002, TIMESTAMPTZ '2023-03-03 19:30:00+05:30'),
(1, 1004, TIMESTAMPTZ '2023-03-04 14:20:00+05:30'),
(2, 1004, TIMESTAMPTZ '2023-03-04 14:22:00+05:30'),
(8, 1004, TIMESTAMPTZ '2023-03-25 13:40:00+05:30'),
(1, 1006, TIMESTAMPTZ '2023-03-11 18:00:00+05:30'),
(3, 1006, TIMESTAMPTZ '2023-03-11 18:05:00+05:30'),
(5, 1009, TIMESTAMPTZ '2023-03-25 13:50:00+05:30'),
(6, 1009, TIMESTAMPTZ '2023-03-25 14:00:00+05:30');

INSERT INTO social.comments (post_id, user_id, commented_ts, comment_text) VALUES
(1001, 3, TIMESTAMPTZ '2023-03-01 09:30:00+05:30', 'Clean explanation'),
(1002, 4, TIMESTAMPTZ '2023-03-03 19:45:00+05:30', 'Great walkthrough'),
(1002, 5, TIMESTAMPTZ '2023-03-03 20:00:00+05:30', 'Loved this'),
(1004, 1, TIMESTAMPTZ '2023-03-04 15:00:00+05:30', 'Very insightful'),
(1004, 2, TIMESTAMPTZ '2023-03-04 15:10:00+05:30', 'Nice edit'),
(1006, 7, TIMESTAMPTZ '2023-03-11 18:15:00+05:30', 'Useful example'),
(1009, 3, TIMESTAMPTZ '2023-03-25 14:15:00+05:30', 'This will go viral');
