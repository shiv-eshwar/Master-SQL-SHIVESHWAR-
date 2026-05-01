# Running Totals and Moving Averages

## Use When

You need cumulative or rolling metrics over time.

## Core Tools

- `SUM() OVER`
- `AVG() OVER`
- `ROWS BETWEEN ...`

## Core Trick

Choose the right partition, order, and frame. The frame is what turns a simple window into a running or rolling metric.

## Worked Ideas

- cumulative revenue
- 7-day moving average
- rolling completed rides

## Interview Note

Explain whether your metric is cumulative from the start or rolling over a fixed horizon.
