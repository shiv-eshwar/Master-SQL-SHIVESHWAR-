# Social ERD

## Grain

- `social.users`: one row per user
- `social.posts`: one row per post
- `social.follows`: one row per follower-followee edge
- `social.likes`: one row per user-post like
- `social.comments`: one row per comment

## Relationships

- `posts.user_id -> users.user_id`
- `follows.follower_id -> users.user_id`
- `follows.followee_id -> users.user_id`
- `likes.user_id -> users.user_id`
- `likes.post_id -> posts.post_id`
- `comments.user_id -> users.user_id`
- `comments.post_id -> posts.post_id`

## Interview Angles

- engagement rate
- mutual follows and graph-style joins
- creator leaderboard
- rolling activity windows
- dedup and anti-join questions
