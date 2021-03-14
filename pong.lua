-- pong-ish

local w, h = fcons.term.size()

local paddle1, paddle2 = h // 2, h // 2
local bx, by = 10, 10

local sprites = {
  paddle = fcons.sprite(1, 5),
  background = fcons.sprite(w, h)
}

fcons.setSprite(sprites.paddle)
fcons.term.bg(0xFFFFFF)
fcons.term.size() -- update term size
fcons.term.clear()
fcons.setSprite(0)
fcons.term.size()

local function redraw()
  fcons.drawSprite(sprites.background, 1, 1)
  fcons.drawSprite(sprites.paddle, 1, paddle1)
  fcons.drawSprite(sprites.paddle, w, paddle2)
  fcons.term.fg(0xFFFFFF)
  fcons.term.cursor(bx, by)
  fcons.term.write("o")
end

fcons.term.write("Press Q to quit.\n\nPress any key to begin.\n\n_")

while true do
  redraw()
  computer.pullSignal()
end
