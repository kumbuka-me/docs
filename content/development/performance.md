# Performance diagnostics

Kumbuka includes opt-in browser performance diagnostics for investigating pages that feel slow to load or become interactive. The diagnostics are disabled by default and can be enabled for the current browser from the developer console; no deployment setting is required.

The browser profiler combines Navigation Timing, Paint Timing, resource timings, Kumbuka frontend initialization measurements, long-task observations when supported by the browser, and opt-in backend `Server-Timing` values.

## Enable diagnostics

Open the browser developer tools on Kumbuka and run:

```js
kumbuka.perf.enable();
location.reload();
```

Reload after enabling. The reload captures the complete navigation and sends the profiler cookie early enough for the server to include backend timing information in the response.

After the page has finished loading, run:

```js
kumbuka.perf.report();
```

`report()` prints grouped tables in the console and also returns the report object, so it can be assigned to a variable for further inspection:

```js
const report = kumbuka.perf.report();
```

Enabling diagnostics persists in the current browser until explicitly disabled, so it remains active across page navigations and reloads.

## Console API

| Command                  | Purpose                                                                                                                     |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| `kumbuka.perf.enable()`  | Enable browser measurements and opt the current browser into backend `Server-Timing`.                                       |
| `kumbuka.perf.disable()` | Disable measurements, remove the persisted browser setting, and stop requesting backend timing data.                        |
| `kumbuka.perf.status()`  | Return whether diagnostics are enabled and whether the current navigation contains Kumbuka `Server-Timing` data.            |
| `kumbuka.perf.report()`  | Print the current performance report and return it as a JavaScript object.                                                  |
| `kumbuka.perf.clear()`   | Clear Kumbuka initialization measurements plus collected long-task and largest-contentful-paint state for the current page. |

For example:

```js
kumbuka.perf.status();
// { enabled: true, serverTiming: true }
```

If `enabled` is `true` but `serverTiming` is `false`, reload the page once. Backend timings are available only for requests that started after diagnostics were enabled.

`clear()` does not remove browser-owned navigation or resource entries. Those are replaced naturally by a new navigation.

## Reading the report

The **Navigation** section includes DNS, connection, TLS, request-to-first-byte, response download, DOM interactive, `DOMContentLoaded`, load, first contentful paint, and largest contentful paint when the browser exposes them.

The **Kumbuka initialization** section lists instrumented frontend initialization steps with their duration and start time, sorted slowest first. This helps distinguish slow JavaScript initialization from a slow server response.

The **Resources** section lists resource timing information such as scripts, stylesheets, images, and application requests. The console table shows the 25 slowest resources; the object returned by `report()` contains the complete collected resource list.

The **Long tasks** section contains main-thread tasks reported by browsers that implement the Long Tasks API. An empty section does not necessarily mean that no expensive JavaScript ran; browser support for this API varies.

The navigation and resource rows can also include `Server-Timing` values returned by Kumbuka. For the main navigation, the `kumbuka` metric is the overall timed server request. Additional render-stage metrics are included when that request records them, and `plugin_wasm` is included when plugin WASM execution occurred.

## Diagnosing a slow page

A useful workflow is:

```js
kumbuka.perf.enable();
location.reload();
```

After the page settles:

```js
kumbuka.perf.report();
```

Use the report to narrow down where the delay happens:

- a large **Request → first byte** value points toward server-side request processing, rendering, database work, or plugins;
- a large **Response download** value points toward response size or network transfer;
- a slow **Kumbuka initialization** entry points toward a frontend initialization step;
- a slow **Resource** entry identifies an individual asset or request worth inspecting in the Network panel;
- a **Long task** indicates JavaScript that occupied the browser main thread for a significant period;
- late first or largest contentful paint can indicate that visible content or a large page element is not becoming paintable early enough.

The browser's Network and Performance panels remain useful alongside this summary when a specific request, layout, paint, or JavaScript stack needs deeper inspection.

## Disable diagnostics

When profiling is finished, run:

```js
kumbuka.perf.disable();
```

A reload is useful when you want to verify normal behavior with a completely new request after profiling:

```js
kumbuka.perf.disable();
location.reload();
```

Diagnostics are deliberately opt-in. Normal requests do not collect the render trace used for the detailed `Server-Timing` response.

## Server log timings

`KUMBUKA__DEBUG_RENDER_TIMINGS=true` is a separate deployment-level diagnostic. It writes detailed render timing information to the server logs and does not require the browser console profiler.

Use the console profiler when you want to correlate browser loading, frontend initialization, resources, and one browser's server request. Use `KUMBUKA__DEBUG_RENDER_TIMINGS` when server-side log output is more appropriate. Both are intended for temporary troubleshooting rather than permanent production diagnostics.
