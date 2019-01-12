const express    = require('express');
const db         = require('./lib/db');
const bodyParser = require('body-parser');
const ItemParser = require('./lib/item_parser');

let app = express();

// Configure express to use body-parser as middleware. This allows us
// to handle POST params
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.post('/api/add_item', (req, res) => {
  let itemString = req.body.item_string;

  // Ensure an item string is being passed
  if (!itemString) {
    res.send({ error: 'You must pass in a item_string to parse.'});
    return;
  }

  // Run the item through our item parser to convert it to a more
  // useable format
  parsedItem = new ItemParser(itemString);

  res.send({ item: parsedItem.item });
})

db.connect();
app.listen(3000);