const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const hb = require('express-handlebars');
const app = express();
const mysql = require('mysql');

const port = 3000;
const pool = mysql.createPool({
    host     : 'localhost',
    user     : 'root',
    password : 'password',
    database : 'fanschoice',
    multipleStatements : true,
    connectionLimit : 4
});

app.use(express.static('static'));

app.use(session({ secret: 'csc336' }));

app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.urlencoded());
app.engine('handlebars', hb({defaultLayout: 'main'}));
app.set('view engine', 'handlebars');

const query_users = 'SELECT userName FROM user ORDER BY userName;';
const query_stream = 'SELECT * FROM stream WHERE stream_id = SELECT id FROM user WHERE userName=(?)ORDER BY posted DESC;';
const query_create_user = 'INSERT INTO user (userName, email) VALUES (?, ?);';
const query_user_id_from_name = 'SELECT id FROM user WHERE userName = ?;';

function checkAuth(req, res, next) {
    if (!req.session.user_id) {
        res.redirect(302, '/login');
    } else {
        next();
    }
}

function debuglog(req, res, next) {
    console.debug(`${req.method} -- ${req.path} (params: ${JSON.stringify(req.params)}) [body: ${JSON.stringify(req.body)}]`);
    next();
}

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
            // We are done with the connection, so we release it back to the pool to allow someone else to use it.
            connection.release();
        }
    });
}

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

app.post('/login', debuglog, db, function (req, res) {
    req.connection.query(query_user_id_from_name, [req.body.user], (error, result) => {
        if (error) {
            console.error('Error logging in.', error);
            res.render('error', { error });
        } else {
            if (result.length && result[0].id) {
                req.session.user_id = result[0].id;
                console.debug(result[0] + " HEYYYYYYYYYYYYYYY/n LOOOOK HEEEEEEEEEERRRRRREEEE");
                req.session.user_name = req.body.user;
                res.redirect(`/user/${req.session.user_name}`);

            } else {
                console.error('Error logging in, unexpected result set.');
            }
        }
    });
});

app.post('/logout', debuglog, function (req, res) {
    delete req.session.user_id;
    res.redirect('/login');
});

app.get('/', debuglog, db, checkAuth, function(req, res) {
    res.redirect(`/user/${req.session.user_name}`);
});

app.get('/user/:name', debuglog, db, function(req, res) {
    // Is the user visiting thier own stream?
    let is_own_stream = (req.params.name === req.session.user_name);
    console.log(req.params.name, req.session.user_name, req.params.name === req.session.user_name);
    query_chain(req.connection, [
        [query_stream, [req.params.name]],
        [query_followees, [req.params.name]],
        [query_followers, [req.params.name]]
    ]).then(([stream, followees, followers]) => {
        let is_following = followers.find(e => { return e.name == req.session.user_name }) !== undefined;
        let can_follow = !is_own_stream && !is_following;
        let can_unfollow = is_following;
        let result = {
            stream,
            followees,
            followers,
            can_follow,
            can_unfollow,
            is_own_stream,
            stream_name: req.params.name,
            user_name: req.session.user_name
        };
        res.render('stream', result);
    }).catch((error) => {
        console.log(error);
        res.render('error', { error });
    });
});

app.post('/user/:name/follow', debuglog, db, checkAuth, function(req, res) {
    console.log(req.session.user_id, req.params.name);
    req.connection.query(query_follow, [req.session.user_id, req.params.name], (error, result, fields) => {
        if (error) {
            console.error('Error following user:', error);
            res.redirect(500, '/?error=unknown');
            return;
        }
        res.redirect(302, `/user/${ req.params.name }`);
    });
});

app.post('/user/:name/unfollow', debuglog, db, checkAuth, function(req, res) {
    req.connection.query(query_unfollow, [req.session.user_id, req.params.name], (error, result, fields) => {
        if (error) {
            console.error('Error unfollowing user:', error);
            res.redirect(500, '/?error=unknown');
            return;
        }
        res.redirect(302, `/user/${ req.params.name }`);
    });
});

app.post('/post', debuglog, db, checkAuth, function(req, res) {
    req.connection.query(query_post_twizzle, [req.session.user_id, req.body.twizzle], (error, stream, fields) => {
        if (error) {
            res.render('error', { error });
        } else {
            res.redirect(302, '/');
        }
    });
});

app.post('/api/user', debuglog, db, function(req, res) {
    if (!req.body) {
        res.redirect(500, '/login?error=unknown');
    }

    req.connection.query(query_create_user, [req.body.user_name, req.body.display_name], (error, result, fields) => {
        if (error) {
            res.redirect(500, '/login?error=unknown');
            return;
        }
        res.redirect(302, '/');
    });
});

app.get('/error', debuglog, db, function(req, res) {
    res.render('error', { error: req.query.type === 'preview' ? 'Cannot preview.' : 'Unknown error.' });
});

app.listen(3000);
