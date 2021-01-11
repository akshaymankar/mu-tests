# Mu Tests

## How to run

0. Make sure you're in the nix-shell or direnv/lorri have loaded everything.
1. Build dependencies:
   ```
   cabal build --dependencies-only many-messages-first
   ```
1. Build each of the libraries while timing it:
   ```
   \time cabal build many-messages-first
   \time cabal build many-messages-last
   \time cabal build many-messages-nested
   \time cabal build waypoint
   ```

## What are these libraries?

Each of these libraries has a protobuf definitions file. Each library serves
exactly one of the services from there corresponding protobuf file.

1. `waypoint` serves the `Builder` service from waypoint.proto. This file is
   copied and modified from
   https://github.com/hashicorp/waypoint-plugin-sdk/blob/main/proto/plugin.proto
   This is my original problem, it is here just for comparison.
1. `nested-messages` serves the `Service` defined in nested.proto. This services
   accepts and returns `Foo` which has 100 levels of nested objects.
1. `many-messages-first` serve the `Service` defined in many.proto. This
   protofile has 101 message types defined, this library serves the first one.
1. `many-messages-last` serve the `Service` defined in many.proto. This
   protofile has 101 message types defined, this library serves the last one.

## Observations

All code compiled with `-ddump-core-stats`. Some stats recorded while compiling:

| Name                 | Time    | RAM    | Core terms | Core Types | Core Coercions |
| -------------------- | ----    | ----   | ---------- | ---------- | -------------- |
| many-messages-first  | 6.23s   | 440 MB | 587        | 179019     | 60249          |
| many-messages-last   | 17.47s  | 912 MB | 587        | 179019     | 855999         |
| nested-messages      | 74.33s  | 3.9 GB | 1853       | 3081127    | 6172627        |
| waypoint             | 183.36s | 8.3 GB | 4724       | 2749039    | 6230708        |

1. I wouldn't have expected `many-messages-last` to be any different from
   `many-messages-first` but it takes about 3 times the time and consumes more
   than 2 times the RAM. The number of coercions has increased by an order of
   magnitude.
1. The `nested-messages` library increase the number of coercions by another
   order of magnitude.
1. These problems go away if the function calling `runGRpcApp` is removed.
