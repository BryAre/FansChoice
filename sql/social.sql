DROP DATABASE IF EXISTS twizzle;
CREATE DATABASE twizzle;
USE twizzle;

DROP TABLE IF EXISTS users;
CREATE TABLE users(
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    -- Even though we will use an arbitrary numeric id, we will still have unique user names.
    name VARCHAR(16) UNIQUE NOT NULL,
    -- Display names are not constrained to be unique, but we do require a user to have one.
    displayname VARCHAR(32) NOT NULL,
    -- Defaults to when the record is inserted.
    joined DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Big brain idea: start the user ids at a nice big number so it looks like we have lots of users.
ALTER TABLE users AUTO_INCREMENT=11957;

DROP TABLE IF EXISTS twizzles;
CREATE TABLE twizzles(
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    -- Even though `user_id` is a foriegn key, it can still be NULL without the NOT NULL constraint.
    user_id INTEGER NOT NULL,
    content VARCHAR(256) NOT NULL,
    posted DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- If `deleted` is NULL then the post has not been deleted.
    -- Alternatively, we could have used a boolean value.
    -- You should *not* just delete the data!
    deleted DATETIME,
    FOREIGN KEY(user_id) REFERENCES users(id)
);

ALTER TABLE twizzles AUTO_INCREMENT=20112;

DROP TABLE IF EXISTS social_graph;
CREATE TABLE social_graph(
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    source INTEGER NOT NULL,
    target INTEGER NOT NULL,
    is_following BOOLEAN NOT NULL,
    updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(source) REFERENCES users(id),
    FOREIGN KEY(target) REFERENCES users(id),
    UNIQUE KEY(source, target, updated)
);

-- A tutorial for user-defined functions is available at:
-- https://www.mysqltutorial.org/mysql-stored-function/

-- This function is well defined, since both `users.id` and `users.name` are unique.
-- We use the function so that we can use the value of `users.name` in our scripts,
-- instead of having a bunch of numbers everywhere.
DELIMITER $$
CREATE FUNCTION get_user_id_from_name(user_name VARCHAR(16))
RETURNS INTEGER
DETERMINISTIC
BEGIN
    RETURN (SELECT id FROM users WHERE name=user_name);
END $$

CREATE FUNCTION get_user_name_from_id(user_id INTEGER)
RETURNS VARCHAR(16)
DETERMINISTIC
BEGIN
    RETURN (SELECT name FROM users WHERE id=user_id);
END $$

CREATE PROCEDURE FollowUser(IN source INTEGER, IN target INTEGER)
BEGIN
    INSERT INTO social_graph (source, target, is_following) VALUES (source, target, true);
END $$

CREATE PROCEDURE UnfollowUser(IN source INTEGER, IN target INTEGER)
BEGIN
    INSERT INTO social_graph (source, target, is_following) VALUES (source, target, false);
END $$

DELIMITER ;

CREATE VIEW most_recent_graph_events AS
    SELECT id, source, target, MAX(updated) OVER (PARTITION BY source, target) AS most_recent
        FROM social_graph;

CREATE VIEW follows AS
    SELECT G.source, G.target, G.is_following, R.most_recent as updated
        FROM most_recent_graph_events R
        JOIN social_graph G ON R.id = G.id AND R.most_recent = G.updated
        WHERE G.is_following = TRUE;

 -- notice we use `IS NULL` instead of `= NULL`.
CREATE VIEW stream AS
    SELECT twizzle_id, stream_id, name, displayname, content, posted FROM
        ((SELECT twizzles.id as twizzle_id, users.id AS stream_id, user_id, name, displayname, content, posted
            FROM twizzles
            JOIN users ON twizzles.user_id = users.id
            WHERE deleted IS NULL)
        UNION
        (SELECT twizzles.id AS twizzle_id, source AS stream_id, target as user_id, name, displayname, content, posted
            FROM twizzles
            JOIN follows ON twizzles.user_id = target
            JOIN users ON target = users.id
            WHERE deleted IS NULL)) T;

-- Insert test data.

INSERT INTO users VALUES (NULL, 'Bernardo', 'Bernie', '2016-01-01 01:01:01');
INSERT INTO users VALUES (NULL, 'Francisco', 'Fran', '2017-02-02 02:02:02');
INSERT INTO users VALUES (NULL, 'Horatio', 'Harry', '2018-02-02 02:03:03');

-- Hamlet: ACT 1, SCENE 1: Elsinore. A platform before the castle.
-- Note that single quotes are escaped by placing two in a row.
INSERT INTO twizzles(user_id, content, posted)
       VALUES (get_user_id_from_name('Bernardo'), 'Who''s there?', DATE_ADD(NOW(), INTERVAL 1 second));
INSERT INTO twizzles(user_id, content, posted)
       VALUES (get_user_id_from_name('Francisco'), 'Nay, answer me: stand, and unfold yourself.', DATE_ADD(NOW(), INTERVAL 2 second));
INSERT INTO twizzles(user_id, content, posted)
       VALUES (get_user_id_from_name('Bernardo'), 'Long live the king!', DATE_ADD(NOW(), INTERVAL 3 second));
INSERT INTO twizzles(user_id, content, posted)
       VALUES (get_user_id_from_name('Francisco'), 'Bernardo?', DATE_ADD(NOW(), INTERVAL 4 second));
INSERT INTO twizzles(user_id, content, posted)
       VALUES (get_user_id_from_name('Bernardo'), 'He.', DATE_ADD(NOW(), INTERVAL 5 second));
INSERT INTO twizzles(user_id, content, posted)
       VALUES (get_user_id_from_name('Francisco'), 'You come most carefully upon your hour.', DATE_ADD(NOW(), INTERVAL 6 second));
INSERT INTO twizzles(user_id, content, posted)
       VALUES (get_user_id_from_name('Bernardo'), '''Tis now struck twelve; get thee to bed, Francisco.', DATE_ADD(NOW(), INTERVAL 7 second));
INSERT INTO twizzles(user_id, content, posted)
       VALUES (get_user_id_from_name('Francisco'), 'For this relief much thanks: ''tis bitter cold, And I am sick at heart.', DATE_ADD(NOW(), INTERVAL 8 second));
INSERT INTO twizzles(user_id, content, posted)
       VALUES (get_user_id_from_name('Bernardo'), 'Have you had quiet guard?', DATE_ADD(NOW(), INTERVAL 9 second));
INSERT INTO twizzles(user_id, content, posted)
       VALUES (get_user_id_from_name('Francisco'), 'Not a mouse stirring.', DATE_ADD(NOW(), INTERVAL 10 second));
INSERT INTO twizzles(user_id, content, posted)
       VALUES (get_user_id_from_name('Bernardo'), 'Well, good night.  If you do meet Horatio and Marcellus, The rivals of my watch, bid them make haste.', DATE_ADD(NOW(), INTERVAL 11 second));
INSERT INTO twizzles(user_id, content, posted)
       VALUES (get_user_id_from_name('Francisco'), 'I think I hear them. Stand, ho! Who''s there?', DATE_ADD(NOW(), INTERVAL 12 second));
INSERT INTO twizzles(user_id, content, posted)
       VALUES (get_user_id_from_name('Horatio'), 'Friends to this ground.', DATE_ADD(NOW(), INTERVAL 13 second));

CALL FollowUser(get_user_id_from_name('Bernardo'), get_user_id_from_name('Francisco'));
CALL FollowUser(get_user_id_from_name('Bernardo'), get_user_id_from_name('Horatio'));
CALL FollowUser(get_user_id_from_name('Francisco'), get_user_id_from_name('Bernardo'));
CALL FollowUser(get_user_id_from_name('Francisco'), get_user_id_from_name('Horatio'));
CALL FollowUser(get_user_id_from_name('Horatio'), get_user_id_from_name('Bernardo'));
CALL FollowUser(get_user_id_from_name('Horatio'), get_user_id_from_name('Francisco'));

