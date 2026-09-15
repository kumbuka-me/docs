# Browser modules

A `browser-module` adds client-side rendering while keeping plugin JavaScript isolated from Kumbuka's page DOM, credentials, and application APIs.

## Manifest

A browser module declares JavaScript and optional CSS under the package `assets/` directory and requires `browser:render`:

```yaml
modules:
  - type: browser-module
    id: diagrams
    javascript: diagram.js
    css: diagram.css
permissions:
  - browser:render
```

## Runtime contract

The entry script is a classic script that defines:

```js
globalThis.kumbukaPlugin = {
  async render(root, { source, theme }) {
    // Render inside this plugin frame.
  },
};
```

The module runs in its own opaque sandbox frame. It receives the block source plus a `light` or `dark` theme and can modify only its frame DOM. It cannot return arbitrary HTML for insertion into Kumbuka's document and there is no general browser-to-host capability bridge.

Resolve auxiliary package scripts relative to `document.currentScript.src` captured while the entry script runs.

## Fallback content

A server-side renderer can emit a sanitized wrapper identifying the plugin and module plus a direct `pre` child as fallback. For HTML browser inputs, use a `div` with `data-kumbuka-input="html"` and a direct `div data-kumbuka-fallback` child.

Kumbuka sanitizes the complete HTML before the browser module receives it. Bounded same-origin raster images can be transferred as data URLs; unsupported or unavailable resources leave the native fallback visible.

Trusted link forwarding is restricted to HTTP(S) URLs already present in the original fallback and requires browser user activation. Theme variables and packaged styles are filtered to the allowed presentation surface.
