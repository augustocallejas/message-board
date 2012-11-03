
DROP TABLE IF EXISTS shares;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS invites;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS topics;
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS users;

DROP SEQUENCE IF EXISTS users_id_seq;
CREATE SEQUENCE users_id_seq;
CREATE TABLE users
(
  id integer default nextval('users_id_seq') NOT NULL,
  created_at timestamp NOT NULL,
  username varchar(20) NOT NULL UNIQUE,
  password varchar(40) NOT NULL,
  email varchar(100) NOT NULL,
  url varchar(100) default '',
  photourl varchar(255) default '',
  location varchar(255) default '',
  im_protocol smallint default 0,
  im_username varchar(50) default '',
  topics_count int default 0,
  posts_count int default 0,
  invited_by_id int default NULL,
  secret_word varchar(50) default '',
  disable_images int default 0 NOT NULL,
  disable_unread_messages int default 0 NOT NULL,
  disabled int default 0 NOT NULL,
  PRIMARY KEY(id)
);


-- NOTICE:  CREATE TABLE will create implicit sequence "users_id_seq" for serial column "users.id"
-- NOTICE:  CREATE TABLE / PRIMARY KEY will create implicit index "users_pkey" for table "users"
-- NOTICE:  CREATE TABLE / UNIQUE will create implicit index "users_username_key" for table "users"

CREATE INDEX users_1 ON users (username,password);

DROP SEQUENCE IF EXISTS activities_id_seq;
CREATE SEQUENCE activities_id_seq;
CREATE TABLE activities
(
  id integer default nextval('activities_id_seq') NOT NULL,
  user_id int NOT NULL, -- fk: users.id
  updated_at timestamp NOT NULL,
  PRIMARY KEY(id),
  UNIQUE (user_id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- NOTICE:  CREATE TABLE will create implicit sequence "activities_id_seq" for serial column "activities.id"
-- NOTICE:  CREATE TABLE / PRIMARY KEY will create implicit index "activities_pkey" for table "activities"
-- NOTICE:  CREATE TABLE / UNIQUE will create implicit index "activities_user_id_key" for table "activities"

CREATE INDEX activities_1 ON activities (user_id);
CREATE INDEX activities_2 ON activities (updated_at);

DROP SEQUENCE IF EXISTS topics_id_seq;
CREATE SEQUENCE topics_id_seq;
CREATE TABLE topics
(
  id integer default nextval('topics_id_seq') NOT NULL,
  title varchar(100) NOT NULL,
  user_id int NOT NULL, -- fk: users.id
  last_post_time timestamp NULL,
  last_post_username varchar(20) NOT NULL,
  last_post_userid int NOT NULL, -- fk: users.id
  PRIMARY KEY(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (last_post_userid) REFERENCES users(id)
);

-- NOTICE:  CREATE TABLE will create implicit sequence "topics_id_seq" for serial column "topics.id"
-- NOTICE:  CREATE TABLE / PRIMARY KEY will create implicit index "topics_pkey" for table "topics"

CREATE INDEX topics_1 ON topics (title); -- TODO: will this be used in search?
CREATE INDEX topics_2 ON topics (user_id);
CREATE INDEX topics_3 ON topics (last_post_time);

DROP SEQUENCE IF EXISTS posts_id_seq;
CREATE SEQUENCE posts_id_seq;
CREATE TABLE posts
(
  id integer default nextval('posts_id_seq') NOT NULL,
  created_at timestamp NOT NULL,
  content text NOT NULL,
  topic_id int NOT NULL, -- fk: threads.id
  user_id int NOT NULL, -- fk: users.id
  PRIMARY KEY(id),
  FOREIGN KEY (topic_id) REFERENCES topics(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- NOTICE:  CREATE TABLE will create implicit sequence "posts_id_seq" for serial column "posts.id"
-- NOTICE:  CREATE TABLE / PRIMARY KEY will create implicit index "posts_pkey" for table "posts"

CREATE INDEX posts_1 ON posts (created_at);
-- CREATE INDEX posts_2 ON posts (content); -- TODO: will this be used in search?
CREATE INDEX posts_3 ON posts (topic_id);
CREATE INDEX posts_4 ON posts (user_id);

DROP SEQUENCE IF EXISTS invites_id_seq;
CREATE SEQUENCE invites_id_seq;
CREATE TABLE invites
(
  id integer default nextval('invites_id_seq') NOT NULL,
  updated_at timestamp NOT NULL,
  user_id int NOT NULL, -- fk: users.id
  email varchar(100) default NULL,
  invitekey varchar(255) default NULL,
  accepted int default 0,
  PRIMARY KEY(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- NOTICE:  CREATE TABLE will create implicit sequence "invites_id_seq" for serial column "invites.id"
-- NOTICE:  CREATE TABLE / PRIMARY KEY will create implicit index "invites_pkey" for table "invites"

CREATE INDEX invites_1 ON invites (user_id);
CREATE INDEX invites_2 ON invites (invitekey);

DROP SEQUENCE IF EXISTS messages_id_seq;
CREATE SEQUENCE messages_id_seq;
CREATE TABLE messages
(
  id integer default nextval('messages_id_seq') NOT NULL,
  created_at timestamp NOT NULL,
  sender_id int NOT NULL, -- fk: users.id
  recipient_id int NOT NULL, -- fk: users.id
  subject varchar(100) NOT NULL,
  content text NOT NULL,
  sender_delete int default 0,
  recipient_delete int default 0,
  recipient_viewed int default 0,
  reply_to_id int default NULL, -- fk: messages.id
  PRIMARY KEY (id),
  FOREIGN KEY (sender_id) REFERENCES users(id),
  FOREIGN KEY (recipient_id) REFERENCES users(id),
  FOREIGN KEY (reply_to_id) REFERENCES messages(id)
);

-- NOTICE:  CREATE TABLE will create implicit sequence "messages_id_seq" for serial column "messages.id"
-- NOTICE:  CREATE TABLE / PRIMARY KEY will create implicit index "messages_pkey" for table "messages"

CREATE INDEX messages_1 ON messages (sender_id);
CREATE INDEX messages_2 ON messages (recipient_id);
CREATE INDEX messages_3 ON messages (sender_delete);
CREATE INDEX messages_4 ON messages (recipient_delete);
CREATE INDEX messages_5 ON messages (recipient_viewed);

DROP SEQUENCE IF EXISTS sessions_id_seq;
CREATE SEQUENCE sessions_id_seq;
CREATE TABLE sessions
(
  id integer default nextval('sessions_id_seq') NOT NULL,
  updated_at timestamp NOT NULL,
  sessid  CHAR(32),
  data    TEXT,
  PRIMARY KEY(id)
);

-- NOTICE:  CREATE TABLE will create implicit sequence "sessions_id_seq" for serial column "sessions.id"
-- NOTICE:  CREATE TABLE / PRIMARY KEY will create implicit index "sessions_pkey" for table "sessions"

CREATE INDEX sessions_1 ON sessions (sessid);

DROP SEQUENCE IF EXISTS shares_id_seq;
CREATE SEQUENCE shares_id_seq;
CREATE TABLE shares
(
  id integer default nextval('shares_id_seq') NOT NULL,
  created_at timestamp NOT NULL,
  user_id int NOT NULL, -- fk: users.id
  author varchar(255) NOT NULL,
  title varchar(255) NOT NULL,
  url varchar(255) NOT NULL,
  expired int default 0,
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- NOTICE:  CREATE TABLE will create implicit sequence "shares_id_seq" for serial column "shares.id"
-- NOTICE:  CREATE TABLE / PRIMARY KEY will create implicit index "shares_pkey" for table "shares"

CREATE INDEX shares_1 ON shares (created_at);
CREATE INDEX shares_2 ON shares (user_id);
CREATE INDEX shares_3 ON shares (author);
CREATE INDEX shares_4 ON shares (title);
CREATE INDEX shares_5 ON shares (expired);
