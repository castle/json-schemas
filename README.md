# Castle API JSON Schemas

## Requests to `/track` and `/authenticate`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "http://api.castle.io/schemas/v0.1/request_event.json",
  "title": "Castle Event Context",
  "description": "Event information sent to Castle's /track or /authenticate endpoints",
  "type": "object",
  "properties": {
    "sent_at": {
      "description": "ISO 8601 timestamp for event creation",
      "type": "string",
      "pattern": "^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(.[0-9]{3})(Z)?$"
    },
    "event": {
      "oneOf": [
        { "$ref": "#/definitions/user_id_events" },
        { "$ref": "#/definitions/anonymous_events" },
        { "$ref": "#/definitions/command_events" }
      ]
    },
    "user_id": {
      "description": "A unique user identifier",
      "type": "string"
    },
    "user_traits": {
      "description": "Known traits of the identified user",
      "type": "object",
      "properties": {
        "email": {
          "description": "The identified user's email address",
          "type": "string",
          "pattern": "^\\S+@\\S+.[a-zA-Z]\\S+$"
        },
        "registered_at": {
          "description": "The timestamp of the user's account creation. Useful for determining newly registered accounts",
          "type": "string"
        }
      }
    },
    "properties": {
      "description": "Optional event properties to be stored in the Castle environment",
      "type": "object"
    },
    "context": {
      "description": "Event context properties",
      "type": "object",
      "properties": {
        "client_id": {
          "description": "The Castle mobile SDK or c.js fingerprint value. unavailable, set to boolean false",
          "type": ["boolean", "string"],
          "default": null
        },
        "ip": {
          "description": "The IPv4 or IPv6 address of the originating request. Must be a valid, public IP",
          "type": "string",
          "oneOf": [
            {
              "pattern": "^(?!(10\\.|172\\.(1[6-9]|2[0-9]|3[01])\\.|192\\.168\\.).*)(?!255\\.255\\.255\\.255)(25[0-5]|2[0-4][0-9]|[1][0-9][0-9]|[1-9][0-9]|[1-9])(\\.(25[0-5]|2[0-4][0-9]|[1][0-9][0-9]|[1-9][0-9]|[0-9])){3}$"
            },
            {
              "pattern": "^([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4}$"
            }
          ]
        },
        "user_agent": {
          "description": "The User-Agent of the originating request",
          "type": "string"
        },
        "headers": {
          "description": "The Headers object of the originating request. Optional, but highly recommended",
          "type": "object"
        }
      },
      "required": ["client_id", "ip", "user_agent"]
    },
    "device_token": {
      "description": "The device token, if available/applicable",
      "type": "string",
      "pattern": "^\\S+$"
    }
  },
  "required": ["event", "context"],
  "allOf": [
    {
      "if": {
        "properties": { "event": { "$ref": "#/definitions/user_id_events" } }
      },
      "then": {
        "required": ["user_id"]
      }
    },
    {
      "if": {
        "properties": { "event": { "$ref": "#/definitions/command_events" } }
      },
      "then": {
        "required": ["device_token"]
      }
    }
  ],
  "definitions": {
    "user_id_events": {
      "description": "Event names where user_id is required",
      "type": "string",
      "enum": [
        "$login.succeeded",
        "$logout.succeeded",
        "$profile_update.succeeded",
        "$profile_update.failed",
        "$registration.succeeded",
        "$registration.failed",
        "$password_reset.succeeded",
        "$password_reset.failed",
        "$password_reset_request.succeeded",
        "$password_reset_request.failed",
        "$incident.mitigated",
        "$challenge.requested",
        "$challenge.succeeded",
        "$challenge.failed",
        "$transaction.attempted",
        "$session.extended"
      ]
    },
    "anonymous_events": {
      "description": "Event names that do not require user_id",
      "type": "string",
      "enum": ["$login.failed"]
    },
    "command_events": {
      "description": "Event names for responding to incident reviews",
      "type": "string",
      "enum": ["$review.resolved", "$review.escalated"]
    }
  }
}
```