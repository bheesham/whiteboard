Canvas.prototype.draw_blob = (x, y) ->
  this.fillStyle("#000000")
  this.fillCircle(x, y, 5);

# If we have a hash, turn it into a whiteboard
console.log(window.location.hash)
if window.location.hash? and window.location.hash.length > 0
  $(".whiteboard-container").css("display", "block")

  # Set up the connection stuff
  room_guid = window.location.hash.substr(1)
  socket = io.connect("http://127.0.0.1/")

  socket.on("debug", (data) ->
    console.log(data)
  )

  # Receive a GUID
  socket.emit("join", 
    room_guid: room_guid
  )

  socket.on("draw", (data) ->
    canvas.draw_blob(data.x, data.y)
  )

  # Set up the canvas now
  # Resize so that the canvas is the maximum possible size
  $(".whiteboard-container").css("height", $(document).height() - $(".header").height() + "px")
  $(".whiteboard-container").css("width", $(document).width() + "px")
  
  canvas = new Canvas('whiteboard', 0, () ->
    this.clear()
  )

  mouseX = mouseY = 0

  mouse_dragging = false
  canvas.onMouseDown = (x, y, button) ->
    mouse_dragging = [true, button]
  canvas.onMouseUp = (x, y, button) ->
    mouse_dragging = false
  canvas.onMouseMove = (x, y) ->
    mouseX = x
    mouseY = y

  mouse_drag = window.setInterval((position) ->
    if mouse_dragging? and mouse_dragging[0]
      console.log(room_guid)
      if mouse_dragging[1] == 1
        socket.emit("draw",
          room_guid: room_guid
          x: mouseX
          y: mouseY - $(".header").height()
        )
      else if mouse_dragging[1] == 3
        socket.emit("erase",
          room_guid: room_guid
          x: mouseX
          y: mouseY - $(".header").height()
        )
      else
        return
  , 1, mouse_dragging)

  ###
  canvas.onMouseDown = (x, y, button) ->
    if button == 1
      socket.emit("draw",
        room_guid: room_guid
        x: x
        y: y - $(".header").height()
      )
    else if button == 3
      socket.emit("erase",
        room_guid: room_guid
        x: x
        y: y - $(".header").height()
      )
    else
      return
    ###
else
  $(".content-container").css("display", "block")
  $("#create-new-room").click(()->
    window.location.hash = uuid.v4()
    window.location.reload(true)
  )