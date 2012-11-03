
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS topics;
DROP TABLE IF EXISTS invites;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS shares;

CREATE TABLE users
(
  id int unsigned NOT NULL auto_increment,
  created_at datetime NOT NULL,
  username varchar(20) NOT NULL UNIQUE,
  password varchar(40) NOT NULL,
  email varchar(100) NOT NULL,
  url varchar(100) default '',
  photourl varchar(255) default '',
  location varchar(255) default '',
  im_protocol int default 0,
  im_username varchar(50) default '',
  secret_word varchar(50) default '',
  disable_images boolean default false NOT NULL,
  disable_unread_messages boolean default false NOT NULL,
  topics_count int default 0,
  posts_count int default 0,
  invited_by_id int default NULL,
  disabled boolean default false NOT NULL,
  PRIMARY KEY(id),
  INDEX (username,password)
);

CREATE TABLE activities
(
  id int unsigned NOT NULL auto_increment,
  user_id int unsigned NOT NULL, -- fk: users.id
  updated_at datetime NOT NULL,
  PRIMARY KEY(id),
  UNIQUE (user_id),
  INDEX (user_id),
  INDEX (updated_at),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE topics
(
  id int unsigned NOT NULL auto_increment,
  title varchar(100) NOT NULL,
  user_id int unsigned NOT NULL, -- fk: users.id
  last_post_time datetime NULL,
  last_post_username varchar(20) NOT NULL,
  last_post_userid int unsigned NOT NULL, -- fk: users.id
  PRIMARY KEY(id),
  INDEX (title), -- TODO: will this be used in search?
  INDEX (user_id),
  INDEX (last_post_time),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (last_post_userid) REFERENCES users(id)
) type=MyISAM;

CREATE TABLE posts
(
  id int unsigned NOT NULL auto_increment,
  created_at datetime NOT NULL,
  content text NOT NULL,
  topic_id int unsigned NOT NULL, -- fk: threads.id
  user_id int unsigned NOT NULL, -- fk: users.id
  PRIMARY KEY(id),
  INDEX (created_at),
  INDEX (content(100)), -- TODO: will this be used in search?
  INDEX (topic_id),
  INDEX (user_id),
  FOREIGN KEY (topic_id) REFERENCES topics(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
) type=MyISAM;

CREATE TABLE invites
(
  id int unsigned NOT NULL auto_increment,
  updated_at datetime NOT NULL,
  user_id int unsigned NOT NULL, -- fk: users.id
  email varchar(100) default NULL,
  invitekey varchar(255) default NULL,
  accepted boolean default false,
  PRIMARY KEY(id),
  INDEX (user_id),
  INDEX (invitekey),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE messages
(
  id int unsigned NOT NULL auto_increment,
  created_at datetime NOT NULL,
  sender_id int unsigned NOT NULL, -- fk: users.id
  recipient_id int unsigned NOT NULL, -- fk: users.id
  subject varchar(100) NOT NULL,
  content text NOT NULL,
  sender_delete boolean default false,
  recipient_delete boolean default false,
  recipient_viewed boolean default false,
  reply_to_id int unsigned default NULL, -- fk: messages.id
  PRIMARY KEY (id),
  INDEX (sender_id),
  INDEX (recipient_id),
  INDEX (sender_delete),
  INDEX (recipient_delete),
  INDEX (recipient_viewed),
  FOREIGN KEY (sender_id) REFERENCES users(id),
  FOREIGN KEY (recipient_id) REFERENCES users(id),
  FOREIGN KEY (reply_to_id) REFERENCES messages(id)
);

CREATE TABLE sessions
(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  updated_at datetime NOT NULL,
  sessid  CHAR(32),
  data    TEXT,
  PRIMARY KEY(id),
  INDEX(sessid)
);

CREATE TABLE shares
(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL,
  user_id int unsigned NOT NULL, -- fk: users.id
  author varchar(255) NOT NULL,
  title varchar(255) NOT NULL,
  url varchar(255) NOT NULL,
  expired boolean default false,
  PRIMARY KEY (id),
  INDEX (created_at),
  INDEX (user_id),
  INDEX (author),
  INDEX (title),
  INDEX (expired),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
