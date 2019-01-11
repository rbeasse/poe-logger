const fragmenter = require('./fragmenter');

const SEPERATOR  = '--------';

class Parser {
  constructor(itemString) {
    this.item      = {};
    this.fragments = itemString.split(SEPERATOR);

    this._parseFragments();
  }

  // @private

  _parseFragments() {
    this.fragments.forEach((fragment) => {
      let itemInfo = fragmenter.findItemInfo(fragment);

      // Merge any attributes found by the fragmenter in to our
      // current item
      this.item = Object.assign(this.item, itemInfo);
    });
  }
}

module.exports = {
  parseItem: (itemString) => {
    let parser = new Parser(itemString);

    return parser.item;
  }
}