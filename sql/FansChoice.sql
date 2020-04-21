DROP DATABASE IF EXISTS FansChoice;
CREATE DATABASE fanschoice;
USE fanschoice;

DROP TABLE IF EXISTS artist;
CREATE TABLE artist(
    id INTEGER Primary Key,
    name VARCHAR(128) Not NUll,
    genre VARCHAR(128),
    DOB VARCHAR(10),
    nationality VARCHAR(128),
    url VARCHAR (256)
);

DROP TABLE IF EXISTS album;
CREATE TABLE album(
    albumid INTEGER,
    artistid INTEGER,
    name VARCHAR(256) Not NUll,
    url VARCHAR(256),
    releaseDate VARCHAR(10) Not Null,
    genre VARCHAR(128),
    trackCount INTEGER,
    recordLabel VARCHAR(128),
    Foreign Key (artistId) references artist(id)
        ON DELETE SET NUll
);

DROP TABLE IF EXISTS single;
CREATE TABLE single(
    singleid INTEGER,
    artistId INTEGER,
    name VARCHAR(256) Not NUll,
    url VARCHAR(256),
    releaseDate VARCHAR(256) Not Null,
    genre VARCHAR(128),
    recordLabel VARCHAR(128),
    Foreign Key (artistId) references artist(id)
        ON DELETE Set NUll
);

DROP TABLE IF EXISTS user;
Create Table user(
    id INTEGER Unique Primary Key AUTO_INCREMENT, -- automatically sets user
    userName VARCHAR (128) NOT NULL Unique,
    dateJoined DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    email VARCHAR(256)
);
ALTER TABLE user AUTO_INCREMENT=1200;


DROP TABLE IF EXISTS reviewAlbum;
Create Table reviewAlbum(
    RA_ID INTEGER Primary Key AUTO_INCREMENT,
    name VARCHAR (128) references user(userName),
    albumID INTEGER references album(albumid),
    posted DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    content VARCHAR(256),
    deleted DATETIME,
    liked Boolean,
    Foreign Key (name) references user(userName)
);
ALTER TABLE reviewAlbum AUTO_INCREMENT=10100;


DROP TABLE IF EXISTS reviewSingle ;
Create Table reviewSingle(
    RA_IS INTEGER Primary Key AUTO_INCREMENT,
    name VARCHAR(128),
    singleID INTEGER references single(singleid),
    posted DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    content VARCHAR(256),
    deleted DATETIME,
    liked Boolean,
    Foreign Key (name) references user(userName)
);
ALTER TABLE reviewSingle AUTO_INCREMENT=10010;

-- Function that used for posting reviews
DELIMITER $$
CREATE FUNCTION get_user_id_from_name(un VARCHAR(128))
RETURNS INTEGER
DETERMINISTIC
BEGIN
    RETURN (SELECT id FROM user WHERE userName=un);
END $$


-- Artist Insertions
INSERT INTO artist VALUES(00001,'Lil Uzi Vert', 'Rap', '07-31-1994', 'American', 'https://townsquare.media/site/812/files/2020/03/lil-uzi-vert-best-songs.jpg?w=980&q=75');
INSERT INTO artist VALUES(00002,'The Weeknd', 'R&B', '02-16-1990', 'Canadian', 'https://pbs.twimg.com/media/EUYIwiwUUAEvrT3.jpg');
INSERT INTO artist VALUES(00003,'Drake', 'Rap', '10-24-1986', 'Canadian', 'https://www.rap-up.com/app/uploads/2020/04/drake-atl.jpg');
INSERT INTO artist VALUES(00004,'Jhene Aiko', 'R&B', '03-16-1988', 'American','https://urbanislandz.com/wp-content/uploads/2019/04/Jhene-Aiko.jpg' );
INSERT INTO artist VALUES(00005,'Tame Impala', 'Rock', Null, 'American','https://www.nme.com/wp-content/uploads/2016/12/2015TameImpala-pg-13280515-1-630x420.jpg');
Insert INTO artist Values(00006,'The Beatles', 'Rock', Null, 'British','https://www.nme.com/wp-content/uploads/2019/04/GettyImages-451898937_BEATLES_2000.jpg');
INSERT INTO artist VALUES(00007,'Rihanna', 'Pop', '02-20-1988', 'Barbadian','https://i.insider.com/5e73d8a3c4854067901764f7?width=1100&format=jpeg&auto=webp');
INSERT INTO artist VALUES(00008,'Dua Lipa', 'Pop', '08-22-1995', 'British','https://metro.co.uk/wp-content/uploads/2017/10/pri_56758289.jpg?quality=90&strip=all');
INSERT INTO artist VALUES(00009,'J Balvin', 'Reggaeton', '05-07-1985', 'Colombian','https://specials-images.forbesimg.com/imageserve/5e850757ff6c160006cdb210/960x0.jpg?fit=scale' );
INSERT INTO artist VALUES(00010,'Bad Bunny', 'Reggaeton', '03-10-1994', 'Puerto Rican','https://cdn3.pitchfork.com/longform/976/badbunnyheader.jpg');
INSERT INTO artist VALUES(00011,'Doja Cat', 'Rap', '10-21-1995', 'American','https://i.ytimg.com/vi/mXnJqYwebF8/maxresdefault.jpg');
INSERT INTO artist VALUES(00012,'Shania Twain', 'Country', '08-28-1965', 'Canadian','https://media.vanityfair.com/photos/5addee6da342ec2552ce87a3/3:2/w_1998,h_1332,c_limit/t-Shania-Twain-Trump.jpg');
INSERT INTO artist VALUES(00013,'Luke Combs', 'Country', '03-02-1990', 'American','https://shawglobalnews.files.wordpress.com/2019/02/luke-combs-5.jpg?quality=70&strip=all');
INSERT INTO artist VALUES(00014,'Beyonce', 'R&B', '09-04-1981', 'American','https://thebeyonceworld.com/wp-content/uploads/2018/09/0011-e1536935210243.jpg');
INSERT INTO artist VALUES(00015,'Adele', 'Pop', '05-05-1988', 'British','https://static.independent.co.uk/s3fs-public/thumbnails/image/2020/02/17/08/adele-0.jpg');
-- Album Insertions 
INSERT INTO album VALUES(00020,00001,'Eternal Atake','https://images.genius.com/73e5eb9c6c73146ec57f8634bb905e01.1000x1000x1.jpg','03-06-2020','Rap',18,'Atlantic');
INSERT INTO album VALUES(00021,00002,'After Hours', 'https://www.rap-up.com/app/uploads/2020/02/the-weeknd-after-hours-1280x720.jpg','03-20-2020','R&B',17,'XO');
INSERT INTO album VALUES(00022,00003,'Views','https://upload.wikimedia.org/wikipedia/en/thumb/a/af/Drake_-_Views_cover.jpg/220px-Drake_-_Views_cover.jpg','04-29-2016','Rap',20,'Young Money');
INSERT INTO album VALUES(00023,00004,'Chilombo','https://consequenceofsound.net/wp-content/uploads/2020/02/Jhene-Aiko-Chilombo-album-cover-artwork.jpg?quality=80','03-06-2020','R&B',20,'Def Jam');
INSERT INTO album VALUES(00024,00005,'The Slow Rush','https://upload.wikimedia.org/wikipedia/en/5/54/Tame_Impala_-_The_Slow_Rush.png','02-14-2020','Rock',12,'Modular');
Insert INTO album Values(00025,00006,'Abbey Road', 'https://vignette.wikia.nocookie.net/beatles/images/e/e9/Beatles_-_abbey_road.jpg/revision/latest?cb=20140524025417','09-26-1969','Rock',11,'Apple' );
INSERT INTO album VALUES(00026,00007,'Anti','https://upload.wikimedia.org/wikipedia/en/3/32/Rihanna_-_Anti.png','01-28-2016','Pop',16 ,'Roc Nation' );
INSERT INTO album VALUES(00027,00008,'Future Nostalgia','https://upload.wikimedia.org/wikipedia/en/f/f5/Dua_Lipa_-_Future_Nostalgia_%28Official_Album_Cover%29.png','03-27-2020','Pop',14,'Warner' );
INSERT INTO album VALUES(00028,00009,'Colores','https://upload.wikimedia.org/wikipedia/en/thumb/1/1a/J_Balvin_-_Colores.png/220px-J_Balvin_-_Colores.png','03-19-2020','Reggaeton',10,'Universal Latin');
INSERT INTO album VALUES(00029,00010,'YHLQMDLG','https://upload.wikimedia.org/wikipedia/en/3/3f/Bad_Bunny_-_Yhlqmdlg.png','02-28-2020','Reggaeton',20,'Rimas');
INSERT INTO album VALUES(00030,00011,'Hot Pink','https://m.media-amazon.com/images/I/71xVNFRJBsL._SS500_.jpg','10-07-2019','Rap', 12,'Kemosabe' );
INSERT INTO album VALUES(00031,00012,'Now','https://express-images.franklymedia.com/6616/sites/1446/2017/06/15085350/Shania-Twain.jpg','09-29-2017', 'Country',16,'Nercury Nashville');
INSERT INTO album VALUES(00032,00013,'The Prequel','https://upload.wikimedia.org/wikipedia/en/thumb/4/40/Luke_Combs_-_The_Prequel.png/220px-Luke_Combs_-_The_Prequel.png','07-07-2019', 'Country',5,'Columbia');
INSERT INTO album VALUES(00033,00014,'4','https://img1.wsimg.com/isteam/ip/cb3ce1fc-5c02-402d-969e-20db76dcd7c3/d5llarv-36e7a563-e679-43e5-b6b3-df8a1bb58639.jpg','06-24-2011', 'R&B',14,'Parkwood');
INSERT INTO album VALUES(00034,00015,'25','https://media.thehypemagazine.com/wp-content/uploads/2016/06/ADELE-25.jpg','11-20-2015', 'Pop',14,'XL');
-- Single Insertions
INSERT INTO single VALUES(00040,00001,'That Way','https://i.ytimg.com/vi/PR-duMh19FY/maxresdefault.jpg','03-01-2020','Rap','Atlantic');
INSERT INTO single VALUES(00041,00002,'Heartless','https://upload.wikimedia.org/wikipedia/en/7/78/The_Weeknd_-_Heartless.png','11-27-2019','R&B','XO');
INSERT INTO single VALUES(00042,00003,'Toosie Slide','https://o2hype.com/wp-content/uploads/2020/04/Drake-Toosie-Slide-300x300.jpg','04-03-2020','Rap','OVO');
INSERT INTO single VALUES(00043,00008,'Dont Start Now','https://i.ytimg.com/vi/htg8v0g_4e4/maxresdefault.jpg','11-01-2019','Pop','Warner');
INSERT INTO single VALUES(00044,00010,'La Dificil','https://assets.vogue.com/photos/5e615f5ce40455000851ede8/16:9/w_1280,c_limit/00_social.jpg','02-29-2020','Reggaeton','Rimas');
INSERT INTO single VALUES(00045,00011,'Say So','https://upload.wikimedia.org/wikipedia/en/d/df/Say_So_-_Doja_Cat.png','01-28-2020','Rap','Kemosabe');
INSERT INTO single VALUES(00046,00013,'Does to Me','https://i.ytimg.com/vi/17fnUqLdm7o/maxresdefault.jpg','02-10-2020','Country','Colombia');
INSERT INTO single VALUES(00047,00002,'Blinding Lights','https://www.rollingstone.com/wp-content/uploads/2020/02/TheWeeknd.jpg','11-29-2019','R&B','XO');
INSERT INTO single VALUES(00048,00005,'It Might Be Time','https://upload.wikimedia.org/wikipedia/en/a/a7/Tame_Impala_-_It_Might_Be_Time.jpg','11-29-2019','Rock','Modular');
INSERT INTO single VALUES(00049,00001,'Futsul Shuffle 2020','https://i.ytimg.com/vi/awtYiVGXiaY/maxresdefault.jpg','12-13-2019','Rap','Atlantic');
-- user insertions
INSERT INTO user (userName, dateJoined,  email)VALUES('ali123','2018-02-06 01:41:12','aliproahmed@gmail.com');
INSERT INTO user (userName, dateJoined,  email)VALUES('bryan123','2019-06-07 11:03:01','bryanalverez23@gmail.com');
INSERT INTO user (userName, dateJoined,  email)VALUES('md123','2020-03-03 03:02:05','mrahman23@gmail.com');
INSERT INTO user (userName, dateJoined,  email)VALUES('rickwtm72','2017-01-02 04:03:02','jerrysucksballs@gmail.com');

-- review album insertions 
INSERT INTO reviewAlbum (name, albumID, posted, content, liked) VALUES('rickwtm72',00020,'2020-03-27 02:02:01','Handsdown Uzis best album!!',true);
INSERT INTO reviewAlbum (name, albumID, posted, content, liked) VALUES('ali123', 00020,'2020-03-28 02:02:01','soooooooooo goooooood',true);
INSERT INTO reviewAlbum (name, albumID, posted, content, liked) VALUES('rickwtm72',00020,'2020-03-30 02:02:01','BABY PLUTOOO!',true);
INSERT INTO reviewAlbum (name, albumID, posted, content, liked) VALUES('rickwtm72',00021,'2020-03-29 05:25:13','Amazing album!! Reminds me of the Old Weeknd!',true);
INSERT INTO reviewAlbum (name, albumID, posted, content, liked) VALUES('bryan123',00028,'2020-03-22 06:29:29','Solid Album. Like the Concept!',true);
INSERT INTO reviewAlbum (name, albumID, posted, content, liked) VALUES('bryan123',00022,'2020-03-24 09:13:38','Couldve been better! Some of the beats sound repetitive',true);

-- -- review single insertions 
INSERT INTO reviewSingle (name, singleID, posted, content, liked) VALUES('ali123',00042,'2020-04-09 01:30:27','Nice Song to Dance to. Its a good song before the album releases.',true);
INSERT INTO reviewSingle (name, singleID, posted, content, liked) VALUES('md123',00042,'2020-04-09 01:30:27','fire afff',true);
INSERT INTO reviewSingle (name, singleID, posted, content, liked) VALUES('ali123',00045,'2020-02-04 02:35:16','Lyrics are kinda basic. Was expecting more!',false);
INSERT INTO reviewSingle (name, singleID, posted, content, liked) VALUES('md123',00046,'2020-04-03 07:16:23','Not Really Enjoyable. The song seems poorly produced.',false);
INSERT INTO reviewSingle (name, singleID, posted, content, liked) VALUES('md123',00043,'2020-03-04 09:45:04','Decent Song. Beat sounds good, but vocals could be better.',false);
INSERT INTO reviewSingle (name, singleID, posted, content, liked) VALUES('md123',00045,'2020-02-04 02:35:16','solid ngl',true);

-- this view contains both albums and single so that we can display the content and user (as well as ordering by posted)
CREATE VIEW allreviews AS
    SELECT name, content, posted FROM
        ((SELECT name, content, posted 
            FROM reviewAlbum
            WHERE deleted is NULL
            )
        UNION
        (SELECT name, content, posted
            FROM reviewSingle
            WHERE deleted IS NULL)) T;
Create VIEW albumlikestotal AS
    select album.albumid,album.name,reviewAlbum.liked from album,reviewAlbum where album.albumid = reviewAlbum.albumID;
    
-- use this table for top albums

CREATE VIEW sumlikesalbum AS 
    select albumid, name, sum(liked) as Total from albumlikestotal GROUP BY name;

Create VIEW singlelikestotal AS
    select single.singleid,single.name,reviewSingle.liked from single,reviewSingle where single.singleid = reviewSingle.singleID;

-- use this table for top singles
CREATE VIEW sumlikessingle AS 
    select singleid, name, sum(liked) as Total from singlelikestotal GROUP BY name;
