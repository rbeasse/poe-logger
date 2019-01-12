const express = require('express');
const fs      = require('fs');

module.exports = {
  buildRoutes(app) {
    const router  = express.Router();

    // Dynamically read each of our routes apply them to the
    // router
    fs.readdirSync('./routes').forEach((file) => {
      require(`../routes/${file}`)(router);
    });

    app.use('/', router);
  }
};