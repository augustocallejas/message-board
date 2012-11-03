
ALTER TABLE users ALTER COLUMN disable_images DROP DEFAULT;
ALTER TABLE users ALTER COLUMN disable_unread_messages DROP DEFAULT;
ALTER TABLE users ALTER COLUMN disabled DROP DEFAULT;

ALTER TABLE users ALTER COLUMN disable_images TYPE integer USING CAST (disable_images AS integer);
ALTER TABLE users ALTER COLUMN disable_unread_messages TYPE integer USING CAST (disable_unread_messages AS integer);
ALTER TABLE users ALTER COLUMN disabled TYPE integer USING CAST (disabled AS integer);

ALTER TABLE invites ALTER COLUMN accepted DROP DEFAULT;

ALTER TABLE invites ALTER COLUMN accepted TYPE integer USING CAST (accepted AS integer);

ALTER TABLE messages ALTER COLUMN sender_delete DROP DEFAULT;
ALTER TABLE messages ALTER COLUMN recipient_delete DROP DEFAULT;
ALTER TABLE messages ALTER COLUMN recipient_viewed DROP DEFAULT;

ALTER TABLE messages ALTER COLUMN sender_delete TYPE integer USING CAST (sender_delete AS integer);
ALTER TABLE messages ALTER COLUMN recipient_delete TYPE integer USING CAST (recipient_delete AS integer);
ALTER TABLE messages ALTER COLUMN recipient_viewed TYPE integer USING CAST (recipient_viewed AS integer);

ALTER TABLE shares ALTER COLUMN expired DROP DEFAULT;

ALTER TABLE shares ALTER COLUMN expired TYPE INTEGER USING CAST (expired AS integer);
