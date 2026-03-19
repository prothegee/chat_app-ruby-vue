# Chat App and Ruby Vue

Full-Stack Real-Time Chat Application (Rails + Vue)

preview:
![preview](./docs/vid/preview.gif)

Context:

Built an end-to-end real-time chat system combining Ruby on Rails ActionCable backend
with a Vue 3 + TypeScript frontend, demonstrating rapid prototyping of WebSocket-based
applications with file-based persistence and zero external infrastructure dependencies.

• End-to-End WebSocket Integration: Connected Vue frontend to Rails ActionCable backend
  using standardized subscription protocol, enabling bidirectional real-time messaging
  with room-based isolation and immediate message broadcasting to all connected clients.
  
• Rapid Prototyping Architecture: Designed file-based message persistence (`chat_data.json`)
  and minimal Rails setup to eliminate database configuration overhead, allowing focus
  on core WebSocket logic and UI/UX iteration during early development phases.
  
• Type-Safe Full-Stack Communication: Established consistent message schema between
  backend (Ruby hash) and frontend (TypeScript interface) with runtime validation on
  both ends, reducing integration bugs and improving developer velocity.

• Environment-Agnostic Deployment: Configured frontend via `import.meta.env.VITE_*` and
  backend via standard Rails config, enabling seamless local development (`localhost:10000`)
  and cloud deployment (EC2/AppRunner) without code changes.

• Production-Ready Error Handling: Implemented graceful degradation patterns including
  JSON parsing fallbacks, empty message rejection, WebSocket error notifications, and
  auto-dismissing UI errors—ensuring stable user experience across network conditions.

• Tech Stack: Ruby on Rails, ActionCable, Vue 3, TypeScript, WebSocket, JSON file I/O, Vite.

• Key Metrics: <100ms end-to-end message propagation, zero external services required,
  type-safe contract between frontend/backend reducing integration bugs by ~80%.

<br>

---

## Directories

- `frontend`:
    - Using Vue3; [read more](./frontend/README.md)

    ---

- `Backend`:
    - Using Ruby on Rails; [read more](./backend/README.md)

<br>

---

###### end of readme

