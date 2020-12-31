-- osloader.lua - load conventional OSes from disk --

if not fcons then
  error("This BIOS is a part of FCONS and requires\nthe FCONS EEPROM to be loaded first", 0)
end

local fsl = component.list("filesystem")
local fs
repeat
  fs = fsl()
until fs ~= computer.tmpAddress()

if not fs.exists("/init.lua") then
  error("no init.lua found on filesystem "..fs.address, 0)
end

fcons.term.write("loading /init.lua...")
local cx, cy = fcons.term.cursor()
local handle = fs.open("/init.lua", "r")
local data = ""
local stages = {"/","-","\\","|"}
local s = 1
repeat
  local chunk = fs.read(handle, 16)
  fcons.term.cursor(cx, cy)
  fcons.term.write(stages[s])
  s = s+1
  if s > 4 then s = 1 end
  data = data .. (chunk or "")
until not chunk
fs.close(handle)

function computer.getBootAddress()
  return fs.address
end
assert(load(data, "=init.lua", "bt", _G))()
