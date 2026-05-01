# YoY, MoM, and WoW Growth

## Use When

You need period-over-period comparisons.

## Core Trick

1. Aggregate to the correct time grain first.
2. Use `LAG` to bring the prior period alongside the current period.
3. Compute absolute and percentage deltas.

## Worked Ideas

- month-over-month orders
- year-over-year revenue
- week-over-week engagement

## Interview Note

Never compare raw timestamps directly when the question is monthly or weekly.
