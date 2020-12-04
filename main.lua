local gpu = component.proxy((component.list("gpu",true)()))
gpu.bind((component.list("screen", true)()))
local term = {colors={blue=0x0000FF,lightblue=0x00CCFF}}
local cx,cy=1,1
local tw,th=gpu.maxResolution()
function term.size(w,h)
  if w and h then
    tw,th=w,h
    gpu.setResolution(w,h)
  else
    return gpu.getResolution()
  end
end
function term.cursor(x,y)
  if x and y then
    cx,cy = x,y
  else
    return cx,cy
  end
end
function term.fg(f)
  if f then
    gpu.setForeground(f)
  else
    return gpu.getForeground()
  end
end
function term.bg(b)
  if b then
    gpu.setBackground(b)
  else
    return gpu.getForeground()
  end
end
function term.clear()
  gpu.fill(1,1,tw,th," ")
end
local function chk()
  if cx<1 then cx=1 end
  if cy<1 then cy=1 end
  if cx>tw then cx=tw end
  if cy>th then gpu.copy(1,1,tw,th,0,-1)gpu.fill(1,th,tw,1," ")cy=th end
end
function term.write(str)
  for c in str:gmatch(".") do
    if c == "\n" then
      cx,cy=1,cy+1
      chk()
    else
      gpu.set(cx,cy,c)
      cx=cx+1
      chk()
    end
  end
end
function term.read(a,b)
  local buf = ""
  local sx, sy = a or cx, b or cy
  local function redraw() -- TODO TODO TODO: handle going offscreen at the bottom
    cx, cy = sx, sy
    term.write(buf .. "_ ")
  end
  while true do
    redraw()
    local sig, _, char, code = computer.pullSignal()
    if sig == "key_down" then
      if char > 31 and char < 127 then
        buf = buf .. string.char(char)
      elseif char == 8 then
        buf = buf:sub(1, -2)
      elseif char == 13 then
        cx, cy = sx, sy
        term.write(buf .. " \n")
        return buf
      end
    end
  end
end
_G.fcons={}
fcons.term=term
fcons.env = setmetatable({},{__index=_G})
fcons.env.fcons = fcons
function fcons.env.load()
  if not component.list("eeprom",true)() then return end
  local data = component.proxy(component.list("eeprom", true)()).get()
  local err
  fcons.env.loaded, err = load(data)
  if not fcons.env.loaded then
    term.write("ERR: " .. tostring(err).."\n")
  end
  fcons.env.program = data
end
function fcons.env.list()
  term.write((fcons.env.program or"").."\n")
end
function fcons.env.run()
  local ok,err = pcall(fcons.env.loaded)
  if not ok and err then
    term.write("ERR: " .. tostring(err) .. "\n")
  end
end
term.fg(term.colors.lightblue)
term.bg(term.colors.blue)
term.clear()
term.write("**** FCONS on ".._VERSION.." ****\n\n")
term.write(string.format("RAM: %d bytes free of %d\n\n",
                            computer.freeMemory(), computer.totalMemory()))
while true do
  term.write("> ")
  local inp = term.read()
  local ok, err = load(inp, "=uinput", "bt", fcons.env)
  if not ok then
    term.write("ERR: "..tostring(err).."\n")
  else
    local ok, err = pcall(ok)
    if not ok then
      term.write("ERR: "..tostring(err).."\n")
    end
  end
end
