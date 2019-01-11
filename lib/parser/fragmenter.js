class Fragment {
  constructor(fragmentString) {
    this.rows = fragmentString.split("\n");
    this.rows = this.rows.filter((row) => row.length);
    this.itemInfo = {}

    this._findEasyAttributes();
  }

  // @private

  _findEasyAttributes() {
    let regexp = RegExp(/^[a-zA-Z1-9 ]*: .*$/);

    this.rows.forEach((row) => {
      // Check if this is an easy attribute to find, if not return
      // false so we can check the next line
      if (!regexp.test(row)) { return false; }

      let rowData    = row.split(': ');
      let attributes = {}

      // Add the key and value we found to our attributes object
      attributes[rowData[0]] = rowData[1]

      // .. and merge that object in to our itemInfo
      this.itemInfo = Object.assign(this.itemInfo, attributes);
    });
  }
}

module.exports = {
  findItemInfo: (fragmentString) => {
    let fragment = new Fragment(fragmentString);

    return fragment.itemInfo;
  }
}