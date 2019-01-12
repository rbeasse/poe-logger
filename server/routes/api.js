const ItemParser = require('../lib/item_parser');

module.exports = (router) => {
  router.post('/api/add_item', function(req, res) {
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
  });
}
