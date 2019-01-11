const express = require('express');
const db      = require('./lib/db');
const parser  = require('./lib/parser/parser');

let app = express();

app.get('/', (req, res) => {
  db.query('select Name from dbo.ModifierTypes', (result) => {
    res.send(result)
  });
})

db.connect();
app.listen(3000);