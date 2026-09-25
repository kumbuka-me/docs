# Webhooks

Administrators can configure outgoing HTTP webhooks under **Administration → Webhooks**. Each webhook has a name, an HTTP(S) endpoint, an enabled flag, a JSON payload template, optional request headers, retry settings, and an event allow-list.

## Payload templates

Payloads use Go template syntax and must render to valid JSON. Use the `json` helper when inserting values into JSON strings or fields.

The template context includes:

```text
.Input.Event
.Payload.ActorID
.Payload.ObjectType
.Payload.ObjectKey
.Payload.Detail
.Payload.Data
.Payload.OccurredAt
.Payload.URL
.Payload.Actor.ID
.Payload.Actor.Mention
.Payload.Actor.DisplayName
.Payload.Actor.Email
.Payload.Actor.Enabled
.Payload.Recipient.ID
.Payload.Recipient.Mention
.Payload.Recipient.DisplayName
.Payload.Recipient.Email
.Payload.Recipient.Enabled
.Receiver
.Title
```

For example:

```gotemplate
{
  "text": {{ print .Input.Event ": " .Payload.Detail | json }},
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": {{ print "*Page:* " .Payload.ObjectKey "\n*URL:* " .Payload.URL | json }}
      }
    }
  ]
}
```

`Payload.URL` is populated for page events when `KUMBUKA__PUBLIC_URL` is configured. **Send test** renders the configured template with a `webhook.test` event.

`Payload.Actor` and `Payload.Recipient` are available only when **Include user details** is enabled for that webhook. They expose the stable ID, canonical mention, display name, email, and enabled state. Some events have no actor or recipient, so templates should use those objects only for matching events. Contact details are resolved during delivery and are not added to the generic event shared with other webhooks.

`notification.created` uses `Payload.Data` for structured notification data and sets `Payload.Recipient` to the target user when user details are enabled. A trusted receiver can then choose whether and how to forward the notification. Kumbuka does not select email, Slack, Teams, or other external channels.

## Request headers

Webhooks can send application-level request headers such as `Authorization` or `X-API-Key`. Headers containing credentials can be marked sensitive; configure `KUMBUKA__ENCRYPTION_KEY` so Kumbuka can encrypt those values at rest.

`Host`, `Content-Length`, and `Content-Type` cannot be configured manually. Kumbuka sends JSON requests and includes `X-Kumbuka-Event` unless it is overridden.

## Retries

Retries are disabled by default. When enabled, Kumbuka retries network and timeout failures, HTTP `408`, HTTP `429`, and HTTP `5xx` responses.

The retry count is the number of attempts after the initial request. Backoff grows from the configured initial delay up to the configured maximum, optional jitter can vary the delay, and `Retry-After` is honored as a minimum wait when provided by the receiver.

## Delivery behavior

Page changes, reviews, revision restores, comments, imports, and bulk operations can emit webhook events. Delivery happens after the primary Kumbuka operation succeeds, so an unavailable webhook endpoint does not roll back the page change.

Recent deliveries show the final HTTP status or error and the number of attempts. Each delivery attempt has a five-second timeout.
