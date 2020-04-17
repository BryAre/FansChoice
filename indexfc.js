const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const hb = require('express-handlebars');
const app = express();
const mysql = require('mysql');

const port = 3000;
const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'inser_your_password',
    database: 'fanschoice',
    multipleStatements: true,
    connectionLimit: 5
});
app.use(express.static('static'));
app.use(session({
    secret: 'csc336',
    resave: true,
    saveUninitialized: true
}));

app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.urlencoded());
app.engine('handlebars', hb({ defaultLayout: 'main' }));
app.set('view engine', 'handlebars');

const query_userName = 'SELECT userName FROM user ORDER BY userName;';
const query_stream = 'SELECT * FROM stream WHERE stream_id = SELECT id FROM user WHERE userName=(?)ORDER BY posted DESC;';
const query_create_user = 'INSERT INTO user (userName, email) VALUES (?, ?);';
const query_user_id_from_name = 'SELECT id FROM user WHERE userName = ?;';

function checkAuth(req, res, next) {
    if (!req.session.userID) {
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
    req.connection.query(query_userName, (error, results, fields) => {
        if (error) {
            console.error('Error executing `query_userName`.', error);
            res.render('error', { error });
        } else {
            // We pass the list of users to the `login` template to populate the drop down.
           // console.debug(results); // this is to check in results are actually being pulled
            res.render('login', { results });
            console.debug(results);
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
                req.session.userID = result[0].id;
                req.session.userName = req.body.user;
                res.redirect(`/user/${req.session.userName}`);
            } else {
                console.debug(result[0]);
                console.error('Error logging in, unexpected result set.');
            }
        }
    });
});


app.get('/songs', debuglog, db, function (req, res) {
    res.render('songs');

});

app.post('/songs', debuglog, db, function (req, res) {

    res.redirect('/songs');

});

app.get('/stream', debuglog, db, function (req, res) {
    res.render('stream');

});

app.post('/stream', debuglog, db, function (req, res) {

    res.redirect('/stream');

});

app.get('/profile', debuglog, db, function (req, res) {
    res.render('profile');

});

app.post('/profile', debuglog, db, function (req, res) {

    res.redirect('/profile');

});

app.post('/logout', debuglog, function (req, res) {
    delete req.session.userName;
    res.redirect('/login'); // navigate back to login page
});


app.post('/api/user', debuglog, db, function (req, res) {
    if (!req.body) {
        res.redirect(500, '/login?error=unknown');
    }
    req.connection.query(query_create_user, [req.body.user_name, req.body.display_name], (error, result, fields) => { // works properly
        if (error) {
            res.redirect(500, '/login?error=unknown');
            return;
        }
        res.redirect(302, '/');
    });
});

app.get('/error', debuglog, db, function (req, res) {
    res.render('error', { error: req.query.type === 'preview' ? 'Cannot preview.' : 'Unknown error.' });
});

app.listen(3000);
