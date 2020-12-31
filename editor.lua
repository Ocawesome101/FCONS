-- very basic FCONS editor --
-- this could be considered an extremely stripped down ed-like --

local buffer = {}

local commands = {
  i = function(ln)
    ln = tonumber(ln) or 0
    while true do
      ln = ln + 1
      local inp = fcons.term.read()
      if inp == "." then break end
      if #buffer == 0 or #buffer <= ln then
        table.insert(buffer, inp or "")
      else
        table.insert(buffer, ln, inp or "")
      end
    end
  end,
  d = function(l1, l2)
    l1, l2 = tonumber(l1), tonumber(l2)
    l2=l2 or 1
    if not l1 then
      error("expected (number[, number])", 0)
    end
    for i = l1, l1 + l2, 1 do
      table.remove(buffer, l1)
    end
  end,
  l = function()
    fcons.env.load()
    if fcons.env.loaded then
      local ln = ""
      buffer = {}
      for char in fcons.env.program:gmatch(".") do
        if char == "\n" then
          table.insert(buffer, ln)
          ln = ""
        else
          ln = ln .. char
        end
      end
      if #ln > 0 then
        table.insert(buffer, ln)
      end
    end
  end,
  s = function()
    component.proxy(component.list("eeprom", true)()).set(table.concat(buffer, "\n"))
  end,
  p = function()
    fcons.term.write(table.concat(buffer, "\n"))
  end
}

local function split(s)
  local w = {}
  for wd in s:gmatch("[^ ]+") do
    w[#w+1] = wd
  end
  return w
end

fcons.term.clear()
fcons.term.cursor(1,1)
fcons.term.write("*** FCONS Editor ***\n")
fcons.term.write("\ni=insert;d=delete;l=load;s=save;p=print;q=quit\n")
while true do
  fcons.term.write("\n* ")
  local cmd = fcons.term.read()
  local words = split(cmd)
  if commands[words[1]] then
    local ok, err = pcall(commands[words[1]], table.unpack(words, 2))
    if not ok and err then
      fcons.term.write("ERR: "..tostring(err).."\n")
    end
  elseif words[1] == "q" then
    break
  else
    fcons.term.write("?")
  end
end
fcons.term.clear()
fcons.term.cursor(1,1)
