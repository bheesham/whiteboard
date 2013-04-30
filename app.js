// Generated by CoffeeScript 1.6.2
(function() {
  var Blobs, Sequelize, io, io_events, sqlize;

  io = require("socket.io").listen(5666, {
    "log level": 1,
    "browser client minification": true,
    "browser client etag": true,
    "browser client gzip": true
  });

  Sequelize = require("sequelize");

  sqlize = new Sequelize("whiteboard", "whiteboard", "whiteboard", {
    define: {
      underscored: true,
      charset: "utf8",
      timestamps: false,
      logging: false,
      pool: {
        maxConnections: 5,
        maxIdleTime: 30
      }
    }
  });

  Blobs = sqlize.define('blobs', {
    x: Sequelize.INTEGER,
    y: Sequelize.INTEGER,
    room_guid: Sequelize.STRING
  });

  Blobs.sync().success(function() {
    return io_events();
  });

  io_events = function() {
    return io.sockets.on("connection", function(socket) {
      socket.on("join", function(data) {
        socket.join(data.room_guid);
        return Blobs.findAll({
          where: {
            room_guid: data.room_guid
          }
        }).success(function(blobs) {
          var blob, _i, _len, _results;

          if (blobs != null) {
            _results = [];
            for (_i = 0, _len = blobs.length; _i < _len; _i++) {
              blob = blobs[_i];
              _results.push(io.sockets["in"](data.room_guid).emit("draw", blob.values));
            }
            return _results;
          }
        });
      });
      socket.on("draw", function(data) {
        return Blobs.create({
          x: data.x,
          y: data.y,
          room_guid: data.room_guid
        }).success(function(blob) {
          return io.sockets["in"](data.room_guid).emit("draw", {
            x: data.x,
            y: data.y
          });
        });
      });
      return socket.on("erase", function(data) {
        return console.log("A");
      });
    });
  };

}).call(this);
