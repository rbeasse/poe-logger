const mssql  = require('mssql');
const config = require('../config/database.json');

// Starts our initial database connection
function connect() {
  mssql.connect(config);
}

// Make a request to the database and send the passed in query
//
// @param {string} queryString - The MSSQL query you would like ran on the database
// @param {function} callback - Action to perform after the query has been completed
function query(queryString, callback) {
  const request = new mssql.Request();

  request.query(queryString, (err, result) => {
    callback(result);
  });
}

module.exports = {
  connect,
  query
}