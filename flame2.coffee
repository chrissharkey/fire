WIDTH      = 550      # Width of the canvas
HEIGHT     = 320      # Height of the canvas
COOL_RATE  = 0.073    # Rate at which to cool the fire, higher = faster cooling
PRECISION  = 5000     # Higher this number the more rich the fire will appear
SPEED      = 50       # The delay in ms between each frame (lower = faster, but more impact on CPU)
RANDOMNESS = 100      # Number of random pixels to add on the bottom row

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

canvas = document.getElementById 'canvas'
context = canvas.getContext '2d'
canvas.width = WIDTH
canvas.height = HEIGHT

imageData = context.getImageData 0, 0, WIDTH, HEIGHT
data = imageData.data
buf = [[]]
emit = [[]]
mouseDown = false

drawFire = (x, y) ->
  for yy in [y..(y+3)]
    for xx in [(x-3)..(x+3)]
      emit[HEIGHT-yy] ||= []
      emit[HEIGHT-yy][xx] = PRECISION*0.9

canvas.addEventListener 'mousemove', ((e)-> drawFire(e.x, e.y) if mouseDown), false
canvas.addEventListener 'mousedown', (-> mouseDown = true) , false
canvas.addEventListener 'mouseup'  , (-> mouseDown = false), false

setInterval =>

  for n in [0..RANDOMNESS]
    buf[0][Math.round(Math.random()*(WIDTH-1))] = Math.round(Math.random()*PRECISION)+PRECISION*0.15

  for x in [0..WIDTH-1]
    for y in [1..HEIGHT-1]
      buf[y] ||= []

      buf[y][x] = ((buf[y-1][x-1] || 0) +
                   (buf[y-1][x]   || 0) +
                   (buf[y-1][x+1] || 0) +
                   (buf[y-2]?[x]  || 0)) / (4 + COOL_RATE)

      if emit[y]?[x] 
        buf[y][x] = emit[y][x] 
        emit[y][x] -= PRECISION*0.004
        emit[y][x] = null if emit[y][x] <= 0

      col = Math.round(buf[y][x] / PRECISION * 255) & 0xff
      index = ((HEIGHT-y) * WIDTH + x) * 4
      data[index]   = palette[col][0] 
      data[++index] = palette[col][1]
      data[++index] = palette[col][2]
      data[++index] = 255

  context.putImageData imageData, 0, 0

, SPEED