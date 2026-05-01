# Cohort Retention

## Use When

You need a retention table such as signup month by months-since-signup.

## Core Trick

1. Assign each user to a cohort period.
2. Build distinct active periods.
3. Compute the offset between active period and cohort period.
4. Aggregate retained users by cohort and offset.

## Worked Ideas

- customer order retention
- app user retention
- employee training completion retention

## Interview Note

Count distinct users, not raw events.
