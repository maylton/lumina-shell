# Performance diagnostics

Lumina records a small in-memory trace for panel, dropdown, event-loop, and
external-process latency. The trace keeps the most recent 512 events and does
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

Panel handoffs can also be reproduced without pointer automation. Replace
`DP-1` with the output being tested:

```bash
qs -p . ipc call performance togglePanel bluetooth DP-1
qs -p . ipc call performance closePanel bluetooth DP-1
qs -p . ipc call performance coordinatorStatus | jq
```

The supported panel identifiers include `bluetooth`, `network`, `dashboard`,
and `launcher`. These calls use the same coordinator path as their bar
widgets.

Dashboard and Settings controls can be inspected and exercised through the
same runtime components:

```bash
qs -p . ipc call settings openCategory appearance DP-1
qs -p . ipc call control performanceStatus DP-1 | jq
qs -p . ipc call control performanceDropdown DP-1 0
qs -p . ipc call control performanceSettingsSlider DP-1 0 0.5
qs -p . ipc call control performanceDashboardSlider DP-1 0 0.5
qs -p . ipc call control performancePopup DP-1 0
qs -p . ipc call control performanceDialog DP-1
```

Slider calls use a normalized value from `0` to `1` and change the real
setting or service. Capture the original value from `performanceStatus` and
restore it after a diagnostic pulse.

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

A second stress pass covered 20 isolated open/close cycles for Bluetooth,
network, dashboard, and launcher, 40 rapid cross-panel handoffs, and 80
double-toggle races. It found and fixed two stale-intent cases in the panel
coordinator, deferred network and Bluetooth refreshes until after the opening
frame, and prevented the dashboard's internal page transition from running
while its window is still opening. The optimized isolated run had p95 settle
times of 1 ms for Bluetooth, 2 ms for network, 31 ms for dashboard, and 2 ms
for launcher, with no event-loop delays or transition timeouts.

The dashboard and Settings pass covered both pages, all 12 Settings
categories, nine dropdown controls, 12 available Settings sliders, the
dashboard output and microphone sliders, three add-widget popups, and the
bar-widget settings dialog. Normal animations record their expected and total
durations separately; `durationMs` for transitions, sliders, and animated
popups is the overrun beyond the configured motion budget.

The optimized run measured p95 opening times of 30 ms for the dashboard and
16 ms for Settings. Dashboard/Settings page transitions had no overrun; the
largest category-transition overrun was 7 ms. Dropdowns completed in
170–175 ms with no overrun, including 45 rapid double-toggle races. Dock icon
size was the only slider to stall the QML thread: keeping the transparent
layer-shell window at a stable maximum height reduced its p95 from 257 ms to
111 ms and removed all event-loop delays. Dashboard audio sliders, Settings
popups, and the widget-settings dialog completed without overruns.

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
