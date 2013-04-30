io = require("socket.io").listen(5666)
Sequelize = require("sequelize")

sqlize = new Sequelize("whiteboard", "whiteboard", "whiteboard", 
  define:
    underscored: true
    charset: "utf8"
    timestamps: true
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
        if not blobs?
          console.log("Room " + data.room_guid + " not exist.")
        else
          for blob in blobs
            console.log("Served blobs from room " + data.room_guid)
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
      console.log("A")
    )

  )