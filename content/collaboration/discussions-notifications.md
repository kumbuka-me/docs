# Discussions and notifications

Administrators can enable or disable page discussions globally. When enabled, readers can comment on pages, and editors can resolve or reopen discussion items.

## Inline comments and suggestions

Select rendered page text and choose **Comment** to start a discussion anchored to that passage. Kumbuka highlights the matching text and opens the thread beside the page.

For plain text that maps cleanly to the Markdown source, choose **Suggest change** to propose replacement text. An editor can apply the suggestion while the referenced source is still current. Applying it creates a normal new page revision. If the page has changed underneath the suggestion, it must be reviewed again instead of being applied blindly.

![Inline discussion showing a proposed Markdown replacement](../assets/screenshots/inline-suggestion.png)

## Replies, quotes, and mentions

Every discussion comment has a permalink. **Reply** keeps the parent comment as context, while **Quote** also includes a short excerpt from it.

Type `@` in the discussion composer to search users and insert an `@username` mention.

## Notifications

The notification bell shows unread items and recent activity. Opening a notification marks it read and takes the user to the related page or comment. **Mark all read** clears the unread state for the inbox.

Replies notify the author of the parent comment, except when users reply to themselves. Mentions in pages and comments notify referenced users; self-mentions and unknown usernames are ignored.

Page discussions are separate from page revision history: comments and replies do not create or rewrite Markdown revisions.
