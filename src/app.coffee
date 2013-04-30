io = require("socket.io").listen(5666,
  "log level": 1
  "browser client minification": true
  "browser client etag": true
  "browser client gzip": true
)

Sequelize = require("sequelize")

sqlize = new Sequelize("whiteboard", "whiteboard", "whiteboard", 
  define:
    underscored: true
    charset: "utf8"
    timestamps: false
    logging: false
    pool: { maxConnections: 5, maxIdleTime: 30}
)

Blobs = sqlize.define('blobs', 
  x: Sequelize.INTEGER
  y: Sequelize.INTEGER
  room_guid: Sequelize.STRING
)

Blobs.sync().success(() ->
  io_events()
)

io_events = () ->
  io.sockets.on("connection", (socket) ->
    socket.on("join", (data) ->    
      socket.join(data.room_guid)
      # If that room exists, send the blobs
      Blobs.findAll(
        where:
          room_guid: data.room_guid
      ).success((blobs) ->
        if blobs?
          for blob in blobs
            io.sockets.in(data.room_guid).emit("draw", blob.values)
      )
    )

    socket.on("draw", (data) ->
      Blobs.create(
        x: data.x
        y: data.y
        room_guid: data.room_guid
      ).success((blob) ->
        io.sockets.in(data.room_guid).emit("draw",
          x: data.x
          y: data.y
        ) 
      )
    )

    socket.on("erase", (data) ->
      # Erase
    )

  )