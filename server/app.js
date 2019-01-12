const express    = require('express');
const database   = require('./lib/db');
const bodyParser = require('body-parser');
const router     = require('./lib/router');

let app = express();

// Configure express to use body-parser as middleware. This allows us
// to handle POST params
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

router.buildRoutes(app);
database.connect();

app.listen(3000, () => { console.log('Server is now running.'); });
