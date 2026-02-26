<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch, computed, type Ref } from 'vue'

const rooms = ref<string[]>([])
const newRoomName = ref('')
const selectedRoom = ref('')
const currentRoom = ref('')
const messages = ref<Array<{ user: string; text: string; timestamp: string | number }>>([])
const newMessage = ref('')
const username = ref('')
const error = ref('')
const ws: Ref<WebSocket | null> = ref(null)
const isJoined = ref(false)

const API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:10000'
const WS_BASE = import.meta.env.VITE_WS_BASE || 'ws://localhost:10000/cable'

let roomRefreshInterval: number | null = null

onMounted(() => {
  fetchRooms()
  roomRefreshInterval = window.setInterval(fetchRooms, 3000)
})

onUnmounted(() => {
  disconnectWebSocket()
  if (roomRefreshInterval) {
    clearInterval(roomRefreshInterval)
  }
})

watch(currentRoom, (newRoom) => {
  if (newRoom) {
    connectWebSocket(newRoom)
  } else {
    disconnectWebSocket()
    isJoined.value = false
  }
})

watch(error, (newError) => {
  if (newError) {
    const timer = setTimeout(() => {
      error.value = ''
    }, 5000)

    onUnmounted(() => clearTimeout(timer))
  }
})

async function fetchRooms() {
  try {
    const res = await fetch(`${API_BASE}/api/v1/chat`)
    rooms.value = await res.json()
  } catch (err: unknown) {
    error.value = 'Failed to load rooms'

    if (err instanceof Error) {
      console.error(err.message)
    }
  }
}

async function createRoom() {
  if (!newRoomName.value.trim()) return
  try {
    const res = await fetch(`${API_BASE}/api/v1/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: newRoomName.value }),
    })
    if (res.ok) {
      // alert('Room created!')
      newRoomName.value = ''
    } else {
      const err = await res.json()
      error.value = err.error || 'Failed to create room'
    }
  } catch (err: unknown) {
    error.value = 'Network error'
    if (err instanceof Error) {
      console.error(err.message)
    }
  }
}

function joinRoom() {
  if (!username.value.trim()) {
    error.value = 'Please enter your name before joining a room'
    return
  }
  if (!selectedRoom.value) {
    error.value = 'Please select a room'
    return
  }

  currentRoom.value = selectedRoom.value
  isJoined.value = true
  loadMessages()
}

async function loadMessages() {
  if (!currentRoom.value) return
  try {
    const res = await fetch(`${API_BASE}/api/v1/chat/${currentRoom.value}/messages`)
    const data = await res.json()
    messages.value = Array.isArray(data) ? data.filter(isValidMessage) : []
  } catch (err: unknown) {
    error.value = 'Failed to load messages'
    messages.value = []
    if (err instanceof Error) {
      console.error(err.message)
    }
  }
}

function connectWebSocket(roomName: string) {
  disconnectWebSocket()

  ws.value = new WebSocket(WS_BASE)

  ws.value.onopen = () => {
    ws.value?.send(
      JSON.stringify({
        command: 'subscribe',
        identifier: JSON.stringify({ channel: 'ChatChannel', room: roomName }),
      }),
    )
  }

  ws.value.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data)
      if (data.type === 'confirm_subscription') return
      if (data.message && isValidMessage(data.message)) {
        messages.value.push(data.message)
        scrollToBottom()
      }
    } catch (e: unknown) {
      console.error('Error parsing WebSocket message:', e)
    }
  }

  ws.value.onerror = (err) => {
    error.value = 'WebSocket connection error'
    if (err instanceof Error) {
      console.error(err.message)
    }
  }

  ws.value.onclose = () => {
    ws.value = null
  }
}

function disconnectWebSocket() {
  if (ws.value) {
    ws.value.close()
    ws.value = null
  }
}

function sendMessage() {
  if (!newMessage.value.trim() || !currentRoom.value || !ws.value) return

  const messageData = {
    user: username.value,
    text: newMessage.value.trim(),
  }

  ws.value.send(
    JSON.stringify({
      command: 'message',
      identifier: JSON.stringify({ channel: 'ChatChannel', room: currentRoom.value }),
      data: JSON.stringify({ action: 'send_message', ...messageData }),
    }),
  )

  newMessage.value = ''
}

function scrollToBottom() {
  setTimeout(() => {
    const container = document.querySelector('.chat-messages')
    if (container) {
      container.scrollTop = container.scrollHeight
    }
  }, 50)
}

function isValidMessage(
  msg: unknown,
): msg is { user: string; text: string; timestamp: string | number } {
  return (
    msg !== null &&
    typeof msg === 'object' &&
    'user' in msg &&
    'text' in msg &&
    'timestamp' in msg &&
    typeof (msg as { user: unknown }).user === 'string' &&
    typeof (msg as { text: unknown }).text === 'string' &&
    (msg as { timestamp: unknown }).timestamp !== undefined
  )
}

const isOwnMessage = computed(() => (msg: { user: string }) => msg?.user === username.value)

function formatTimestamp(ts: string | number | undefined) {
  if (!ts) return '—'
  const d = new Date(ts)
  return isNaN(d.getTime()) ? '—' : d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}
</script>

<template>
  <div class="app-container">
    <h1>Chat App; <i>Ruby x Vue</i></h1>

    <!-- Username Input -->
    <div v-if="!isJoined" class="username-section">
      <input v-model="username" placeholder="Enter your name" class="username-input" />
    </div>

    <!-- Create Room -->
    <div v-if="!isJoined" class="create-room-section">
      <input v-model="newRoomName" placeholder="Room name" class="room-input" />
      <button @click="createRoom" class="btn">Create Room</button>
    </div>

    <!-- Join Room -->
    <div v-if="!isJoined" class="join-room-section">
      <select v-model="selectedRoom" class="room-select">
        <option value="">-- Select a room --</option>
        <option v-for="room in rooms" :key="room" :value="room">{{ room }}</option>
      </select>
      <button @click="joinRoom" :disabled="!selectedRoom" class="btn">Join Room</button>
    </div>

    <!-- Chat UI -->
    <div v-else class="chat-container">
      <div class="chat-header">
        <h2>Room: {{ currentRoom }}</h2>
        <button
          @click="
            () => {
              currentRoom = ''
              username = ''
            }
          "
          class="btn btn-small"
        >
          Leave Room
        </button>
      </div>

      <div class="chat-messages">
        <div
          v-for="(msg, i) in messages"
          :key="i"
          :class="[
            'message',
            { 'own-message': isOwnMessage(msg) },
            { 'other-message': !isOwnMessage(msg) },
          ]"
        >
          <template v-if="isValidMessage(msg)">
            <div class="message-bubble">
              <div class="message-header">
                <div class="message-user">{{ msg.user }}</div>
                <small class="message-timestamp">{{ formatTimestamp(msg.timestamp) }}</small>
              </div>
              <div class="message-text">{{ msg.text }}</div>
            </div>
          </template>
          <div v-else class="invalid-message">[invalid message]</div>
        </div>
      </div>

      <div class="chat-input">
        <input
          v-model="newMessage"
          placeholder="Type a message..."
          @keyup.enter="sendMessage"
          class="message-input"
        />
        <button @click="sendMessage" class="btn send-btn">Send</button>
      </div>
    </div>

    <Transition name="fade">
      <p v-if="error" key="error" class="error">{{ error }}</p>
    </Transition>
  </div>
</template>

<style scoped>
.app-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

.username-section,
.create-room-section,
.join-room-section {
  margin-bottom: 20px;
  display: flex;
  gap: 10px;
  align-items: center;
}

.username-input,
.room-input,
.room-select,
.message-input {
  padding: 8px 12px;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 14px;
}

.room-select {
  flex: 1;
  padding: 8px;
}

.btn {
  padding: 8px 16px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn:hover:not(:disabled) {
  background-color: #0056b3;
}

.btn:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.btn-small {
  padding: 4px 8px;
  font-size: 12px;
}

.chat-container {
  border: 1px solid #ccc;
  border-radius: 8px;
  overflow: hidden;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background-color: #f8f9fa;
  border-bottom: 1px solid #eee;
}

.chat-messages {
  height: 300px;
  overflow-y: auto;
  padding: 10px;
  background-color: #fff;
}

.message {
  display: flex;
  margin-bottom: 8px;
  width: 100%;
}

.message-bubble {
  padding: 8px 12px;
  border-radius: 12px;
  width: 20%;
  max-width: 80%;
  min-width: 20%;
}

.message-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px; /* jarak ke message-text */
}

.message-user {
  font-weight: bold;
  white-space: nowrap;
}

.message-timestamp {
  font-size: 0.75em;
  color: #888;
}

/* Gaya pesan lain */
.other-message .message-bubble {
  margin-right: auto;
  background-color: #f1f1f1;
  color: black; /* pastikan teks terbaca */
}

.own-message .message-bubble {
  margin-left: auto;
  background-color: #007bff;
  color: white;
}

/* Pastikan timestamp tetap putih di own-message */
.own-message .message-timestamp {
  color: rgba(255, 255, 255, 0.8);
}

.message-user {
  font-weight: bold;
  font-size: 12px;
  margin-bottom: 2px;
}

.message-text {
  font-size: 14px;
}

.message-timestamp {
  color: #666;
  font-size: 11px;
  margin-top: 4px;
  display: block;
}

.invalid-message {
  color: #aaa;
  font-size: 0.9em;
}

.chat-input {
  display: flex;
  padding: 10px;
  border-top: 1px solid #eee;
  background-color: #f8f9fa;
}

.message-input {
  flex: 1;
  margin-right: 10px;
}

.send-btn {
  padding: 8px 16px;
}

.error {
  color: red;
  margin-top: 10px;
}

.fade-enter-active,
.fade-leave-active {
  transition:
    opacity 0.3s ease,
    transform 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.fade-enter-to,
.fade-leave-from {
  opacity: 1;
  transform: translateY(0);
}
</style>
