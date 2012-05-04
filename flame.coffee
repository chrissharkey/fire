WIDTH = 500
HEIGHT = 256
sd = []
window.sd = sd

palCol = (intensity) ->
  r = Math.min(intensity, 85) * 3
  intensity = Math.max(intensity-85, 0)
  g = Math.min(intensity, 85) * 3
  intensity = Math.max(intensity-85, 0)
  b = Math.min(intensity, 85) * 3
  [r,g,b]

palette = 
  for n in [0..255] 
    palCol n

class FlameApp
  main: ->
    @createCanvas()
    @imageData = @context.getImageData(0, 0, WIDTH, HEIGHT)
    @buf = new ArrayBuffer(@imageData.data.length)
    @buf8 = new Uint8ClampedArray(@buf)
    @data = new Uint32Array(@buf)
    @runLoop()

  runLoop: ->
    setTimeout =>
      # Clear the Canvas
      @clearCanvas()
    
      sc = sd.slice 0

      sc[0] ||= []
      for n in [0..255]
        sc[0][Math.round(Math.random()*(WIDTH-1))] = Math.round(Math.random()*5000)+500 # 2500 + 2500
 
      # Redraw game entities
      for x in [0..WIDTH-1]
        for y in [1..HEIGHT-1]
          sc[y] ||= []
          sc[y][x] = ((sc[y-1]?[x-1] || 0) +
                      (sc[y-1]?[x]   || 0) +
                      (sc[y-1]?[x+1] || 0) +
                      (sc[y-2]?[x]   || 0)) / 4.073
          col = Math.round(sc[y][x] / 5000 * 255)
          col = 0 if col < 1
          col = 254 if col > 254
          myy = y+1
          @data[(HEIGHT - myy) * WIDTH + x] = 
            (255 << 24) |                  # alpha
            (palette[col][2]   << 16) |    # blue
            (palette[col][1]   <<  8) |    # green
            palette[col][0]                # red

      sd = sc.slice 0

      @imageData.data.set(@buf8)
      @context.putImageData @imageData, 0, 0

      # Run again unless we have been killed
      @runLoop() unless @terminateRunLoop
    , 30

  # Creates an overlay for the sceen and a canvas to draw the game on
  createCanvas: ->
    @canvas = document.getElementById 'canvas'
    @context = @canvas.getContext '2d'
    @canvas.width = WIDTH
    @canvas.height = HEIGHT

  clearCanvas: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

window.flame = new FlameApp
window.flame.main()