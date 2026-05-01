# Sessionization

## Use When

You have timestamped events and need to break them into sessions based on inactivity gaps.

## Core Trick

1. Order events per user.
2. Compare each event to the previous one with `LAG`.
3. Mark a new session when the gap exceeds a threshold.
4. Running-sum the marker to assign session IDs.

## Worked Ideas

- app sessions
- shopper browsing sessions
- user support activity windows

## Interview Note

Be explicit about the timeout threshold, such as 30 minutes.
