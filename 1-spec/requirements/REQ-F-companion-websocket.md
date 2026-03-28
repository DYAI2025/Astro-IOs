# REQ-F-companion-websocket: AI Companion WebSocket Connection

**Type**: Functional
**Status**: Draft
**Priority**: Must-have
**Source story**: [US-converse-with-companion](../user-stories/US-converse-with-companion.md)

## Description

Each AI companion connects via WebSocket to ElevenLabs Conversational AI with the user's natal chart as system context.

## Acceptance Criteria

- [ ] WebSocket connects to wss://api.elevenlabs.io/v1/convai/conversation?agent_id=...
- [ ] conversation_initiation_client_data sends full chart context (Western + BaZi + WuXing)
- [ ] Text messages sent via user_message type, responses received as agent_response
- [ ] Fallback: local preset responses when WebSocket fails
- [ ] Levi agent_id: agent_1801kje0zqc8e4b89swbt7wekawv
- [ ] Eve agent_id: agent_9101kmntjynwfz6t2ep687a6qb09
