
#ALTER TABLE users ALTER COLUMN disable_images TYPE boolean USING CAST (disable_images AS boolean);
#ALTER TABLE users ALTER COLUMN disable_unread_messages TYPE boolean USING CAST (disable_unread_messages AS boolean);
#ALTER TABLE users ALTER COLUMN disabled TYPE boolean USING CAST (disabled AS boolean);
#
#ALTER TABLE users ALTER COLUMN disable_images SET DEFAULT false;
#ALTER TABLE users ALTER COLUMN disable_unread_messages SET DEFAULT false;
#ALTER TABLE users ALTER COLUMN disabled SET DEFAULT false;
#
#ALTER TABLE invites ALTER COLUMN accepted TYPE boolean USING CAST (accepted AS boolean);
#
#ALTER TABLE invites ALTER COLUMN accepted SET DEFAULT false;
#
#ALTER TABLE messages ALTER COLUMN sender_delete TYPE boolean USING CAST (sender_delete AS boolean);
#ALTER TABLE messages ALTER COLUMN recipient_delete TYPE boolean USING CAST (recipient_delete AS boolean);
#ALTER TABLE messages ALTER COLUMN recipient_viewed TYPE boolean USING CAST (recipient_viewed AS boolean);
#
#ALTER TABLE messages ALTER COLUMN sender_delete SET DEFAULT false;
#ALTER TABLE messages ALTER COLUMN recipient_delete SET DEFAULT false;
#ALTER TABLE messages ALTER COLUMN recipient_viewed SET DEFAULT false;
#
#ALTER TABLE shares ALTER COLUMN expired TYPE boolean USING CAST (expired AS boolean);
#
#ALTER TABLE shares ALTER COLUMN expired SET DEFAULT false;

SELECT setval('users_id_seq', (SELECT max(id) FROM users));
SELECT setval('activities_id_seq', (SELECT max(id) FROM activities));
SELECT setval('topics_id_seq', (SELECT max(id) FROM topics));
SELECT setval('posts_id_seq', (SELECT max(id) FROM posts));
SELECT setval('invites_id_seq', (SELECT max(id) FROM invites));
SELECT setval('messages_id_seq', (SELECT max(id) FROM messages));
SELECT setval('sessions_id_seq', (SELECT max(id) FROM sessions));
SELECT setval('shares_id_seq', (SELECT max(id) FROM shares));
