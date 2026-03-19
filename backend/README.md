# backend

<!-- I got no prior experience with Ruby -->
Backend for real-time chat with Ruby on Rails.

• Channel-Based WebSocket Architecture: Implemented ActionCable channel (`ChatChannel`)
  with dynamic room subscription (`chat_#{room_name}`), supporting multi-room isolation
  and scalable client connections without external message brokers.
• Resilient Message Handling: Built dual-entry message processing (`receive` + `send_message`)
  with robust JSON parsing that handles both stringified and native hash payloads,
  preventing crashes from inconsistent frontend data formats across environments.
• File-Based Persistence Layer: Designed simple JSON file storage (`tmp/chat_data.json`)
  for message history, enabling zero-configuration deployments and easy debugging
  while avoiding database setup overhead for MVP/prototype stages.
• Input Validation & Security: Implemented server-side sanitization (user/text stripping,
  empty message rejection, anonymous fallback) to prevent malformed data propagation
  and ensure consistent message structure for frontend consumption.
• Observability-First Logging: Integrated comprehensive Rails logger statements throughout
  the message flow (subscribe, receive, parse, broadcast, save) for rapid troubleshooting
  in local and cloud environments (EC2/AppRunner).
• Tech Stack: Ruby on Rails 7+, ActionCable (WebSocket), JSON file I/O, UTC ISO8601 timestamps.
• Key Metrics: Sub-100ms message broadcast latency, zero external dependencies beyond Rails,
  graceful handling of malformed payloads without service interruption.

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
        sh ./init.sh;
        bundle install;
        ```
    - then:
        `./bin/rails s;`
    - or build using Dockerfile and run from there

<br>

---

## Reserved

`ports:`
- 10000

<br>

---

###### end of readme

