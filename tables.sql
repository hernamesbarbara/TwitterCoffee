DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS tweets;
DROP TABLE IF EXISTS relationships;

CREATE TABLE users (
    id SERIAL PRIMARY KEY
    , created_at   TIMESTAMP default CURRENT_TIMESTAMP
    , username     VARCHAR(50) CONSTRAINT proper_email CHECK 
                    (username ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
    , password     VARCHAR(20)
);

CREATE UNIQUE INDEX index_users_on_username ON users (LOWER(username));

CREATE TABLE tweets (
    id SERIAL PRIMARY KEY
    , user_id       INTEGER
    , created_at    TIMESTAMP default CURRENT_TIMESTAMP
    , content       VARCHAR(140)
);

CREATE TABLE relationships (
    id SERIAL PRIMARY KEY
    , created_at    TIMESTAMP default CURRENT_TIMESTAMP
    , follower_id   INTEGER
    , followed_id   INTEGER
);

CREATE INDEX idx_relationships_on_follower_id ON relationships (follower_id);
CREATE INDEX idx_relationships_on_followed_id ON relationships (followed_id);
CREATE UNIQUE INDEX idx_relationships_on_followed_and_follower ON relationships (followed_id,follower_id);