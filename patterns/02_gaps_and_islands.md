# Gaps and Islands

## Use When

You need consecutive runs such as streaks, adjacent dates, or uninterrupted sequences.

## Core Trick

Create a stable grouping key with something like:

`date_value - row_number`

Rows in the same streak produce the same derived key.

## Worked Ideas

- consecutive ride days
- employee attendance streaks
- contiguous active months

## Interview Note

First sort the events. Without clear ordering, there is no streak logic.
