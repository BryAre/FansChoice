DROP DATABASE IF EXISTS FansChoice;
CREATE DATABASE fanschoice;
USE fanschoice;

DROP TABLE IF EXISTS artist;
CREATE TABLE artist(
    id INTEGER Primary Key,
    name VARCHAR(128) Not NUll,
    genre VARCHAR(128),
    DOB VARCHAR(10),
    nationality VARCHAR(128)
);

DROP TABLE IF EXISTS album;
CREATE TABLE album(
    albumid INTEGER,
    artistid INTEGER,
    name VARCHAR(256) Not NUll,
    releaseDate VARCHAR(10) Not Null,
    genre VARCHAR(128),
    reveiwCount INTEGER,
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
    releaseDate VARCHAR(256) Not Null,
    genre VARCHAR(128),
    reveiwCount INTEGER,
    recordLabel VARCHAR(128),
    Foreign Key (artistId) references artist(id)
        ON DELETE Set NUll
);

DROP TABLE IF EXISTS user;
Create Table user(
    id INTEGER Primary Key,
    userName VARCHAR (256) Not NUll Unique,
    dateJoined DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reveiwCount INTEGER,
    email VARCHAR(256)
);


DROP TABLE IF EXISTS reveiw;
Create Table reveiw(
    userID INTEGER,
    albumID INTEGER references album(albumid),
    singleID INTEGER references single(singleid),
    posted DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    content VARCHAR(256),
    score INTEGER ,
    BrokenRecord Boolean,
    Foreign Key (userID) references user(id)
        ON DELETE Set NUll
);

DROP TABLE IF EXISTS picture;
Create Table picture(
    pictureID INTEGER,
    size VARCHAR(128),
    caption VARCHAR(128),
    url VARCHAR(256)
);

-- Artist Insertions
INSERT INTO artist VALUES(00001,'Lil Uzi Vert', 'Rap', '07-31-1994', 'American' );
INSERT INTO artist VALUES(00002,'The Weeknd', 'R&B', '02-16-1990', 'Canadian' );
INSERT INTO artist VALUES(00003,'Drake', 'Rap', '10-24-1986', 'Canadian' );
INSERT INTO artist VALUES(00004,'Jhene Aiko', 'R&B', '03-16-1988', 'American' );
INSERT INTO artist VALUES(00005,'Tame Impala', 'Rock', Null, 'American');
Insert INTO artist Values(00006,'The Beatles', 'Rock', Null, 'British');
INSERT INTO artist VALUES(00007,'Rihanna', 'Pop', '02-20-1988', 'Barbadian');
INSERT INTO artist VALUES(00008,'Dua Lipa', 'Pop', '08-22-1995', 'British');
INSERT INTO artist VALUES(00009,'J Balvin', 'Reggaeton', '05-07-1985', 'Colombian' );
INSERT INTO artist VALUES(00010,'Bad Bunny', 'Reggaeton', '03-10-1994', 'Puerto Rican');
INSERT INTO artist VALUES(00011,'Doja Cat', 'Rap', '10-21-1995', 'American');
INSERT INTO artist VALUES(00012,'Shania Twain', 'Country', '08-28-1965', 'Canadian');
INSERT INTO artist VALUES(00013,'Luke Combs', 'Country', '03-02-1990', 'American');
INSERT INTO artist VALUES(00014,'Beyonce', 'R&B', '09-04-1981', 'American');
INSERT INTO artist VALUES(00015,'Adele', 'Pop', '05-05-1988', 'British');
-- Album Insertions 
INSERT INTO album VALUES(00020,00001,'Eternal Atake','03-06-2020','Rap',0,18,'Atlantic');
INSERT INTO album VALUES(00021,00002,'After Hours', '03-20-2020','R&B', 0,17,'XO');
INSERT INTO album VALUES(00022,00003,'Views','04-29-2016','Rap',0 ,20,'Young Money');
INSERT INTO album VALUES(00023,00004,'Chilombo', '03-06-2020','R&B',0 ,20,'Def Jam');
INSERT INTO album VALUES(00024,00005,'The Slow Rush','02-14-2020','Rock',0,12,'Modular' );
Insert INTO album Values(00025,00006,'Abbey Road', '09-26-1969','Rock',0,11,'Apple' );
INSERT INTO album VALUES(00026,00007,'Anti','01-28-2016','Pop',0,16 ,'Roc Nation' );
INSERT INTO album VALUES(00027,00008,'Future Nostalgia', '03-27-2020','Pop',0,14,'Warner' );
INSERT INTO album VALUES(00028,00009,'Colores','03-19-2020','Reggaeton',0,10,'Universal Latin');
INSERT INTO album VALUES(00029,00010,'YHLQMDLG','02-28-2020','Reggaeton',0,20,'Rimas');
INSERT INTO album VALUES(00030,00011,'Hot Pink','10-07-2019','Rap', 0,12,'Kemosabe' );
INSERT INTO album VALUES(00031,00012,'Now','09-29-2017', 'Country',0,16,'Nercury Nashville');
INSERT INTO album VALUES(00032,00013,'The Prequel','07-07-2019', 'Country',0,5,'Columbia');
INSERT INTO album VALUES(00033,00014,'4','06-24-2011', 'R&B',0,14,'Parkwood');
INSERT INTO album VALUES(00034,00015,'25','11-20-2015', 'Pop',0,14,'XL');
-- Single Insertions
INSERT INTO single VALUES(00040,00001,'That Way','03-01-2020','Rap',0,'Atlantic');
INSERT INTO single VALUES(00041,00002,'Heartless','11-27-2019','R&B',0,'XO');
INSERT INTO single VALUES(00042,00003,'Toosie Slide','04-03-2020','Rap',0,'OVO');
INSERT INTO single VALUES(00043,00008,'Dont Start Now','11-01-2019','Pop',0,'Warner');
INSERT INTO single VALUES(00044,00010,'La Dificil','02-29-2020','Reggaeton',0,'Rimas');
INSERT INTO single VALUES(00045,00011,'Say So','01-28-2020','Rap',0,'Kemosabe');
INSERT INTO single VALUES(00046,00013,'Does to Me','02-10-2020','Country',0,'Colombia');
INSERT INTO single VALUES(00047,00002,'Blinding Lights','11-29-2019','R&B',0,'XO');
INSERT INTO single VALUES(00048,00005,'It Might Be Time','11-29-2019','Rock',0,'Modular');
INSERT INTO single VALUES(00049,00001,'Futsul Shuffle 2020','12-13-2019','Rap',0,'Atlantic');
-- user insertions
INSERT INTO user VALUES(00100,'ali123','2018-02-06 01:41:12',0,'aliproahmed@gmail.com');
INSERT INTO user VALUES(00101,'bryan123','2019-06-07 11:03:01',0,'bryanalverez23@gmail.com');
INSERT INTO user VALUES(00102,'md123','2020-03-03 03:02:05',0,'mrahman23@gmail.com');
INSERT INTO user VALUES(00103,'rickwtm72','2017-01-02 04:03:02',0,'jerrysucksballs@gmail.com');
-- review insertions 
INSERT INTO reveiw VALUES(00103,00020,Null,'2020-03-27 02:02:01','Handsdown Uzis best album!!',9,false);
INSERT INTO reveiw VALUES(00103,00021,Null,'2020-03-29 05:25:13','Amazing album!! Reminds me of the Old Weeknd!',10,false);
INSERT INTO reveiw VALUES(00102,00028,Null,'2020-03-22 06:29:29','Solid Album. Like the Concept!',7,false);
INSERT INTO reveiw VALUES(00102,00022,Null,'2020-03-24 09:13:38','Couldve been better! Some of the beats sound repetitive',6,false);
INSERT INTO reveiw VALUES(00101,Null,00042,'2020-04-09 01:30:27','Nice Song to Dance to. Its a good song before the album releases.',7,false);
INSERT INTO reveiw VALUES(00101,Null,00045,'2020-02-04 02:35:16','Lyrics are kinda basic. Was expecting more!',5,true);
INSERT INTO reveiw VALUES(00100,Null,00046,'2020-04-03 07:16:23','Not Really Enjoyable. The song seems poorly produced.',4,true);
INSERT INTO reveiw VALUES(00100,Null,00043,'2020-03-04 09:45:04','Decent Song. Beat sounds good, but vocals could be better.',6,false);