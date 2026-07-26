# Performance diagnostics

Lumina records a small in-memory trace for panel, dropdown, event-loop, and
external-process latency. The trace keeps the most recent 96 events and does
not write them to disk.

## Capture an intermittent delay

Clear earlier samples before reproducing a problem:

```bash
qs -p . ipc call performance reset
```

Open and close the affected panel, launcher, or settings dropdown, then fetch
the trace:

```bash
qs -p . ipc call performance status | jq
```

The snapshot contains:

- `slowEventCount`: operations taking at least 120 ms;
- `activeProcesses`: tracked commands still running;
- `peakConcurrentProcesses`: maximum tracked process concurrency;
- `panel/requested`, `panel/visible`, and `panel/settled`: panel lifecycle;
- `dropdown/opened` and `dropdown/settled`: settings-menu lifecycle;
- `coordinator/timeout`: a panel transition that needed the safety timeout;
- `event-loop/delayed`: the QML main thread missed its 50 ms heartbeat by at
  least 80 ms;
- `process/started` and `process/finished`: NetworkManager and Bluetooth
  snapshot commands.

Slow events are also emitted as `Lumina performance` warnings in the
Quickshell log. A delay recorded with active external processes points to
process or D-Bus contention. An event-loop delay with no active process points
instead to QML evaluation, delegate creation, image work, or rendering.

## Clean baseline

Restart Quickshell before comparing results. Hot reload recompiles and
reconstructs parts of the QML scene and is expected to produce event-loop
spikes that do not represent normal interaction.

During the initial investigation, idle panel windows reached the compositor
in 0–2 ms and settled in 0–4 ms. The network and Bluetooth refresh paths were
found to launch three commands concurrently. They now serialize each snapshot,
limiting concurrency within each snapshot to one, and the background
Bluetooth polling interval was increased from 15 to 60 seconds.

## Focused summary

This command shows only slow events, transition timeouts, and process
concurrency:

```bash
qs -p . ipc call performance status \
  | jq '{
      slowEventCount,
      activeProcesses,
      peakConcurrentProcesses,
      noteworthy: [
        .events[]
        | select(
            .durationMs >= 120
            or .phase == "timeout"
            or .category == "event-loop"
        )
      ]
    }'
```
