--key = require "init"

local M = key.init{"TextEdit"}

--hs.inspect(hs.eventtap.event.properties)

local file = "hotkey/textedit.txt"
local initSection = "init"


-- Parsing config for chunks
local preloadConfig = function(file)
  local item = {}
  local items = {}
  local prevLineWasEmpty
  local lineNumber = 1

  for line in io.lines(file) do
    if line ~= "" then -- Add line to item
      if #item == 0 then
        table.insert(item, lineNumber)
      end
      table.insert(item, line)
      prevLineWasEmpty = false
    else -- Add chunk to array
      if not prevLineWasEmpty then -- Check for several empty lines
        table.insert(items, item)
        item = {}
        prevLineWasEmpty = true
      end
    end
    lineNumber = lineNumber + 1
  end

  if #item ~= 0 then -- Add last chunk
    table.insert(items, item)
  end

  return items
end

-- Parsing chunks
local loadConfig = function(file)
  local currentKey
  local keyCode
  local initChunk
  local appKeys = {names = {}, keys = {}}

  for chunkNum, chunk in ipairs(preloadConfig(file)) do
    if chunkNum == 1 then -- Parsing app names
      for lineNum, line in ipairs(chunk) do
        if lineNum ~= 1 then
          line = trim(line)
          if not line:match("^%-%-") then
            table.insert(appKeys.names, line)
          end
        end
      end
    else -- Parsing key/desc/code/line
      currentKey = appKeys.keys
      for lineNum, line in ipairs(chunk) do
        line = trim(line)
        if lineNum == 1 then -- Get file's line number
          fileLineNumber = line
        elseif lineNum == 2 then -- Get key combo
          initChunk = line == initSection -- Check for init section
          line = line.." "
          for keys in line:gmatch("(.-) +") do
            keyCode = initChunk and keys or key.map[keys]
            currentKey[keyCode] = currentKey[keyCode] or {}
            currentKey = currentKey[keyCode]
          end
        elseif lineNum == 3 then -- Get description
          currentKey._ = currentKey._ or {}
          if initChunk then
            currentKey._.action = line
          else
            currentKey._.description = currentKey._.description and currentKey._.description.."\n"..line or line
          end
        else -- Get code lines
          currentKey._.action = currentKey._.action and currentKey._.action..";\n"..line or line
        end
      end
      currentKey._.line = currentKey._.line and currentKey._.line..", "..fileLineNumber or fileLineNumber
    end
  end
  if appKeys.keys.init then -- Run init section
    load(appKeys.keys.init._.action)()
  end
  return appKeys
end

M.blah = loadConfig(file)
print(insp(M.blah.keys))

events = hs.eventtap.event.types
props = hs.eventtap.event.properties

local currentCombo
local keyCode
local keyLastPressed
local keyReleaseTime

M.keyEvent = hs.eventtap.new({events.keyDown, events.keyUp}, function(ev)

  keysIgnored = {
    [53] = "escape"
  }
  keyCode = ev:getKeyCode()

  if ev:getType() == events.keyDown then
    if ev:getProperty(props.keyboardEventAutorepeat) == 1 then
      msg = "help on "..key.map[keyCode]
    else
      msg = "press  "..key.map[keyCode]
    end
  end

  --  msg = msg..ev:getKeyCode()
  if ev:getType() == events.keyUp then
    msg = "release "..key.map[keyCode]
  end

  log.d(msg..ev:getKeyCode())
  --log.d(hs.timer.secondsSinceEpoch())

  return true

end)

M.activate = function() M.keyEvent:start() end
M.deactivate = function() M.keyEvent:stop() end

return M
