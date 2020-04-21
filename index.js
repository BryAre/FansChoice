const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const hb = require('express-handlebars');
const app = express();
const mysql = require('mysql');

//connecting database
const port = 3000;
const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'topline99',
    database: 'fanschoice',
    multipleStatements: true,
    connectionLimit: 4
});
// The server will serve static content (javascript, css, images, etc.) out of the `static` directory.
app.use(express.static('static'));
app.use(session({ secret: 'csc336' })); //You already know where we got our layout from
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.urlencoded());
app.engine('handlebars', hb({ defaultLayout: 'main' }));
app.set('view engine', 'handlebars');
//query list
const query_users = 'SELECT userName FROM user ORDER BY userName;';

//query to get the latest review of both songs and albums and order it it from most recent to least
const query_stream = '((SELECT allreviews.name, allreviews.content, allreviews.posted, album.name AS music FROM album, reviewAlbum, allreviews WHERE album.albumid = reviewalbum.albumID AND reviewAlbum.name = allreviews.name AND reviewAlbum.posted = allreviews.posted) UNION (SELECT allreviews.name, allreviews.content, allreviews.posted, single.name AS music FROM single, reviewsingle, allreviews WHERE single.singleid = reviewsingle.singleID AND reviewSingle.name = allreviews.name AND reviewSingle.posted = allreviews.posted)) ORDER BY posted DESC';

//All queries here are self explanatory
const query_create_user = 'INSERT INTO user (userName, email) VALUES (?, ?);';
const query_user_id_from_name = 'SELECT id FROM user WHERE userName = ?;';
const query_emails = 'SELECT email FROM user ORDER BY email;';
const query_artist = 'SELECT name from artist;'
const query_url = 'SELECT url from artist WHERE name = ?;'
const query_artist_name = 'SELECT name from artist WHERE name = ?;'
const query_post_revA = 'INSERT INTO reviewAlbum (name, content, albumID) VALUES (?, ?, ?);'; 
const query_post_revS = 'INSERT INTO reviewSingle (name, content, singleID) VALUES (?, ?, ?);';
const query_albums = 'select album.name from artist,album where album.artistid =artist.id and artist.name = ?;';
const query_albums_name = 'select * from album where album.name = ?;';
const query_singles_name = 'select * from single where single.name = ?;';
const query_song = 'SELECT single.name FROM artist,single WHERE single.artistid = artist.id and artist.name= ?;';
const query_topsingles = 'select name from sumlikessingle ORDER BY TOTAL DESC;';
const query_topalbums = 'select name from sumlikesalbum ORDER BY TOTAL DESC;';


const query_liked_album = 'UPDATE reviewAlbum SET liked = true WHERE albumID = ? AND name = ?;';
const query_disliked_album = 'UPDATE reviewAlbum SET liked = false WHERE albumID = ? AND name = ?;';
const query_liked_single = 'UPDATE reviewSingle SET liked = true WHERE singleID = ? AND name = ?;';

//checks to see if user is logged in
function checkAuth(req, res, next) {
    if (!req.session.user_id) {
        res.redirect(302, '/login');
    } else {
        next();
    }
}

//logs requests
function debuglog(req, res, next) {
    console.debug(`${req.method} -- ${req.path} (params: ${JSON.stringify(req.params)}) [body: ${JSON.stringify(req.body)}]`);
    next();
}

//database connection from inside a route
function db(req, res, next) {
    pool.getConnection((error, connection) => {
        try {
            if (error) {
                console.error('Error connecting to the database.', error);
                res.render('error', { error });
            } else {
                req.connection = connection;
                next();
            }
        } finally {
            connection.release();
        }
    });
}

//function to allow multiple queries to be connected
function query_chain(connection, queries) {
    return Promise.all(queries.map(([query, params]) => new Promise((resolve, reject) => {
        connection.query(query, params, (error, result) => {
            if (error) {
                console.error(`Error executing query: '${query}'.`);
                reject(error);
            } else {
                console.log(query, params, result);
                resolve(result);
            }
        });
    })));
}

//GET request to get users informations
app.get('/login', debuglog, db, function (req, res) {
    // The `query_users` variable holds a query which returns a list of all of the site's users.
    req.connection.query(query_users, (error, results, fields) => {
        if (error) {
            console.error('Error executing `query_users`.', error);
            res.render('error', { error });
        } else {
            // We pass the list of users to the `login` template to populate the drop down.
            res.render('login', { results });
        }
    });
});

//POST request for user logging in
app.post('/login', debuglog, db, function (req, res) {
    req.connection.query(query_user_id_from_name, [req.body.user], (error, result) => {
        if (error) {
            console.error('Error logging in.', error);
            res.render('error', { error });
        } else {
            if (result.length && result[0].id) {
                req.session.user_id = result[0].id;
                req.session.user_name = req.body.user;
                res.redirect(`/user/${req.session.user_name}`); //redirects to user's homepage

            } else { //error handling
                console.error('Error logging in, unexpected result set.');
            }
        }
    });
});

// for top songs

app.get('/songs', debuglog, db, function (req, res) {
    // The `query_topsingles` variable holds a query which returns a list of all of the site's top songs.
    req.connection.query(query_topsingles, (error, singlenames, fields) => {
        if (error) {
            console.error('Error executing `query_users`.', error);
            res.render('error', { error });
        } else {
            console.log(singlenames);
            res.render('songs', { singlenames });
        }
    });
});

app.post('/songs', debuglog, db, function (req, res) {

    res.redirect('/songs');

});

// for top albums
app.get('/albums', debuglog, db, function (req, res) {
    // The `query_topsingles` variable holds a query which returns a list of all of the site's top albums.
    req.connection.query(query_topalbums, (error, albumnames, fields) => {
        if (error) {
            console.error('Error executing `query_users`.', error);
            res.render('error', { error });
        } else {
            res.render('albums', { albumnames });
        }
    });
});


app.post('/albums', debuglog, db, function (req, res) {
    res.redirect('/albums');
});

//Gets reviews of all songs and albums to update "latest reviews"
app.get('/stream', debuglog, db, function (req, res) {
    //console.log(req.params.name, req.session.user_name, req.params.name === req.session.user_name);
    query_chain(req.connection, [
        [query_stream, [req.params.name]],

    ]).then(([reviewAlbum]) => {
        let result = {
            reviewAlbum,
            stream_name: req.params.name,
            user_name: req.session.user_name
        };
        res.render('stream', result); //renders the stream.handlebars with the query information stored in the result list.
    }).catch((error) => {
        console.log(error);
        res.render('error', { error });
    });
});

app.post('/stream', debuglog, db, function (req, res) {

    res.redirect('/stream');

});


//logging out button causes the post request to send out and delete the session
app.post('/logout', debuglog, function (req, res) {
    delete req.session.user_id;
    res.redirect('/login');
});

// '/' just redirects back to the users homepage with his username showing in the url.
app.get('/', debuglog, db, checkAuth, function (req, res) {
    res.redirect(`/user/${req.session.user_name}`);
});

//nothing different from /stream
app.get('/user/:name', debuglog, db, function (req, res) { //** ******
    //console.log(req.params.name, req.session.user_name, req.params.name === req.session.user_name);
    query_chain(req.connection, [
        [query_stream, [req.params.name]],

    ]).then(([reviewAlbum]) => {
        let result = {
            reviewAlbum,
            stream_name: req.params.name,
            user_name: req.session.user_name
        };
        res.render('stream', result);
    }).catch((error) => {
        console.log(error);
        res.render('error', { error });
    });
});

//search page where you can choose an artist and get information about them
app.get('/search', debuglog, db, function (req, res) {
    query_chain(req.connection, [
        [query_artist, [req.params.name]], //populates drop down with artist names
        [query_albums, [req.params.name]], //not used yet
        [query_song, [req.params.name]], //not used yet

    ]).then(([artist, album, song]) => {
        let result = {
            artist, //the results of the queries are mapped in the respective order
            album,
            song,
        };
        res.render('search', result);
    }).catch((error) => {
        console.log(error);
        res.render('error', { error });
    });
});

app.post('/search', debuglog, db, function (req, res) {
    res.redirect('/search');
});

//Sends out artist selection information to rerender the page with new information
app.post('/search/artist', debuglog, db, function (req, res) {
    if (!req.body) {
        res.redirect(500, '/search?error=unknown');
    }
    console.log(req.body.artist_name); //this is the artist name pulled from the drop down menu
    query_chain(req.connection, [
        [query_artist, [req.body.artist_name]], 
        [query_artist_name, [req.body.artist_name]], //uses selected value to retrieve name
        [query_albums, [req.body.artist_name]], //uses selected value to retrieve albums for artist
        [query_song, [req.body.artist_name]], //uses selected value to retrieve songs for selected artist
        [query_url, [req.body.artist_name]] //uses selected value to retrieve artist picture
    ]).then(([artist, artists, album, song, url]) => {
        let result = {
            artist,
            artists,
            album,
            song,
            url,
        };
        res.render('search', result);
    }).catch((error) => {
        console.log(error);
        res.render('error', { error });
    });
});

//New page to review song or album of the selected artist
app.get('/reviewAlbum', debuglog, db, function (req, res) {
    res.render('reviewAlbum');

});

//Artist review button results
app.post('/search/artist/reviewAlbum', debuglog, db, function (req, res) {
    if (!req.body) {
        res.redirect(500, '/search?error=unknown');
    }
    console.log(req.body.album_name);
    query_chain(req.connection, [
        [query_albums_name, [req.body.album_name]],
    ]).then(([reviewAlbum]) => {
        let result = {
            reviewAlbum,
        };
        res.render('reviewAlbum', result); 
    }).catch((error) => {
        console.log(error);
        res.render('error', { error });
    });
});

// Single version of above!!!
app.post('/search/artist/reviewSingle', debuglog, db, function (req, res) {
    if (!req.body) {
        res.redirect(500, '/search?error=unknown');
    }
    query_chain(req.connection, [
        [query_singles_name, [req.body.single_name]],
    ]).then(([reviewSingle]) => {
        let result = {
            reviewSingle,
        };
        res.render('reviewSingle', result);
    }).catch((error) => {
        console.log(error);
        res.render('error', { error });
    });
});

//Used to create a new users
app.post('/api/user', debuglog, db, function (req, res) {
    if (!req.body) {
        res.redirect(500, '/login?error=unknown');
    }

    req.connection.query(query_create_user, [req.body.user_name, req.body.display_name], (error, result, fields) => { // works
        if (error) {
            res.redirect(500, '/login?error=unknown');
            return;
        }
        res.redirect(302, '/');
    });
});
//used for posting an album review
app.post('/post_ar', debuglog, db, checkAuth, function (req, res) { // use this for review page
    req.connection.query(query_post_revA, [req.session.user_name, req.body.review, req.body.album_id], (error, stream, fields) => {
        if (error) {
            res.render('error', { error });
        } else {
            res.redirect(302, '/likepage');
        }
    });
});

//same as above but used for single review
app.post('/post_as', debuglog, db, checkAuth, function (req, res) { // use this for review page
    req.connection.query(query_post_revS, [req.session.user_name, req.body.review, req.body.single_id], (error, stream, fields) => {
        if (error) {
            res.render('error', { error });
        } else {
            res.redirect(302, '/likepageSingles');
        }
    });
});

//Like pages for albums after a review is posted
app.get('/likepage', debuglog, db, function (req, res) {
    res.render('likepage');

});
//Inserts the value of the review, who posted it, and what album it was posted about
app.post('/likepage', debuglog, db, checkAuth, function (req, res) { // use this for review page
    req.connection.query(query_post_revA, [req.session.user_name, req.body.review, req.body.album_id], (error, stream, fields) => {
        if (error) {
            res.render('error', { error });
        } else {
            res.redirect(302, '/likepage');
        }
    });
});

//Like pages for singles after a review is posted
app.get('/likepageSingles', debuglog, db, function (req, res) {
    res.render('likepageSingles');

});

//Inserts the value of the review, who posted it, and what single it was posted about
app.post('/likepageSingles', debuglog, db, checkAuth, function (req, res) { // use this for review page
    req.connection.query(query_post_revS, [req.session.user_name, req.body.review, req.body.single_id], (error, stream, fields) => {
        if (error) {
            res.render('error', { error });
        } else {
            res.redirect(302, '/likepageSingles');
        }
    });
});

//Used for button to like an album
app.post('/liked', debuglog, function (req, res) {

    res.redirect('/stream');
});

//Used for button to like a single
app.post('/likedSingle', debuglog, function (req, res) {

    res.redirect('/stream');

});

//error handling aka the "why does my code hate me" page
app.get('/error', debuglog, db, function (req, res) {
    res.render('error', { error: req.query.type === 'preview' ? 'Cannot preview.' : 'Unknown error.' });
});

app.listen(3000);
