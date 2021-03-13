-- pong-ish

local w, h = fcons.term.size()

local paddle1, paddle2 = h // 2, h // 2

local sprites = {
  paddle = fcons.sprite(1, 5),
  background = fcons.sprite(w, h)
}

gpu.setActiveBuffer(sprites.paddle)
gpu.setBackground(0xFFFFFF)
gpu.fill(1, 1, 1, 5, " ")

local function redraw()
  fcons.drawSprite(sprites.background, 1, 1)
  fcons.drawSprite(sprites.paddle, 1, paddle1)
  fcons.drawSprite(sprites.paddle, w, paddle2)
  gpu.set(bx, by, "o")
end
