# Discussions and notifications

Administrators can enable or disable page discussions globally.

When discussions are enabled, readers can add comments to a page. Comments may include an anchor copied from selected page text. Editors can resolve or reopen discussion items.

## Inline comments and suggestions

Select rendered page text and choose **Comment** to start a discussion anchored to that passage. Kumbuka highlights the matching text and places the thread in a side panel so feedback stays next to the content it refers to.

For uniquely mapped plain text, switch the composer to **Suggest change**. A suggestion stores the exact current Markdown range plus the proposed replacement. Editors can apply a still-current suggestion directly from the thread; Kumbuka creates a normal new page revision rather than editing revision history in place. If the page changed and the stored source range is no longer current, the suggestion cannot be applied blindly.

![Inline discussion showing a proposed Markdown replacement](../assets/screenshots/inline-suggestion.png)

## Replies, quotes, and mentions

Each discussion comment has a stable permalink and can be used as the target of a reply. **Reply** opens the composer with the parent comment attached as context. Replies to replies keep their exact parent relationship, while the page displays replies with only one visual indentation level so long conversations do not become progressively narrower.

**Quote** creates the same reply relationship and also copies a short excerpt from the selected comment into the reply context. The relationship is stored independently from the quoted text, so editing or displaying the excerpt does not determine which comment the reply belongs to.

Type `@` in the discussion composer to search Kumbuka users and insert an `@username` mention. The discussion composer uses the same mention-completion behavior as the page editor.

## Notifications

Kumbuka has a lightweight per-user notification inbox in the top bar. The bell shows the unread count and the newest notifications. Opening an item marks it read before Kumbuka redirects to the notification's stored local destination; **Mark all read** clears the unread state for the complete inbox. The notification API and read/open responses are private and non-cacheable.

Replying to another user's comment creates a notification that links directly to the new comment. Kumbuka does not notify the author when they reply to their own comment.

Mention processing creates notification items for distinct `@username` references in page content and comments. Kumbuka ignores mentions of the acting user and usernames that do not resolve to an account. Notification destinations are restricted to local application paths, so an inbox item cannot redirect the browser to an external site.

The page view keeps discussion state separate from immutable page revision history: comments and replies do not rewrite Markdown revisions.
