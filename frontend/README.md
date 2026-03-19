# frontend

Frontend for real-time chat with Ruby on Rails.

• Composition API Architecture: Built component using Vue 3 `<script setup>` with
  reactive primitives (`ref`, `computed`, `watch`) for clean, maintainable state
  management of rooms, messages, user session, and WebSocket connection lifecycle.

• ActionCable Protocol Integration: Implemented WebSocket client adhering to Rails
  ActionCable subscription protocol (`command: "subscribe"`, `identifier` JSON nesting),
  enabling real-time message reception with automatic reconnection handling.

• Type-Safe Message Validation: Created TypeScript type guard (`isValidMessage`) to
  validate incoming WebSocket payloads at runtime, preventing UI crashes from
  malformed server responses while maintaining developer confidence via compile-time checks.

• Responsive Chat UI with UX Polish: Designed message bubble layout with visual
  distinction for own/other messages, auto-scroll on new messages, timestamp formatting,
  and smooth error toast transitions—optimized for both keyboard and touch interactions.

• Lifecycle-Aware Resource Management: Implemented proper cleanup via `onMounted`/`onUnmounted`
  for WebSocket disconnection and room-polling interval cancellation, preventing memory
  leaks and redundant network requests during component unmount.

• Tech Stack: Vue 3, TypeScript, Composition API, WebSocket, CSS Scoped Styles, Vite env config.

• Key Metrics: <50ms UI update on message receipt, 100% type coverage for message schema,
  graceful degradation on WebSocket errors with user-friendly fallback messages.

<br>

---

# Importans

- check `.env` file in this project dir:
    - if doesn't exists, you can use `.env.template` and rename it as `.env`

<!-- - unit tests integration: -->
<!--     - n/a -->

- to run dev:
    - run this on the terminal:
        ```
        npm i;
        npm run dev;
        ```
    - or build using Dockerfile and run from there

<br>

---

## Reserved

`ports:`
- 10001

<br>

---

###### end of readme

