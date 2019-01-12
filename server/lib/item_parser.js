class ItemParser {
  constructor(itemString) {
    this.item      = {};
    this.fragments = itemString.split('--------');

    this._parseFragments();
  }

  // @private

  _parseFragments() {
    this.fragments.forEach((fragment) => {
      let rows = fragment.split("\n").
                          filter((row) => row.length);

      this._parseSimpleAttributes(rows);
    });
  }

  _parseSimpleAttributes(rows) {
    let regexp = RegExp(/^[a-zA-Z1-9 ]*: .*$/);

    rows.forEach((row) => {
      // Check if this is an easy attribute to find, if not return
      // false so we can check the next line
      if (!regexp.test(row)) { return false; }

      let rowData    = row.split(': ');

      // Add the key and value we found to our item
      this.item[rowData[0]] = rowData[1]
    });
  }
}

module.exports = ItemParser;