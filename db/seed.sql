
INSERT INTO users(created_at,username,password,email) VALUES (now(),'admin',sha('--password--'),'admin@example.com');
