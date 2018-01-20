local key = {}

key.apps = {}
local configFolder = "hotkey"
local configExtension = "cfg"
local configCommon = "all"
local initSection = "init"
local disabledConfigPrefix = "_"

-- Custom map for avoiding trouble with different keyboard layouts
key.map = hs.keycodes.map
-- key.map = { "s", "d", "f", "h", "g", "z", "x", "c", "v", "`", "b", "q", "w", "e", "r", "y", "t", "1", "2", "3", "4", "6", "5", "=", "9", "7", "-", "8", "0", "]", "o", "u", "[", "i", "p", "return", "l", "j", "'", "k", ";", "\\", ",", "/", "n", "m", ".", "tab", "space", "`", "delete", nil, "escape", "rightcmd", "cmd", "shift", "capslock", "alt", "ctrl", "rightshift", "rightalt", "rightctrl", "fn", "f17", "pad.", nil, "pad*", nil, "pad+", nil, "padclear", nil, nil, nil, "pad/", "padenter", nil, "pad-", "f18", "f19", "pad=", "pad0", "pad1", "pad2", "pad3", "pad4", "pad5", "pad6", "pad7", "f20", "pad8", "pad9", "yen", "underscore", "pad,", "f5", "f6", "f7", "f3", "f8", "f9", "eisu", "f11", "kana", "f13", "f16", "f14", [0] = "a", [109] = "f10", [111] = "f12", [113] = "f15", [114] = "help", [115] = "home", [116] = "pageup", [117] = "forwarddelete", [118] = "f4", [119] = "end", [120] = "f2", [121] = "pagedown", [122] = "f1", [123] = "left", [124] = "right", [125] = "down", [126] = "up", [""] = 104, ["'"] = 39, [","] = 43, ["-"] = 27, ["."] = 47, ["/"] = 44, ["0"] = 29, ["1"] = 18, ["2"] = 19, ["3"] = 20, ["4"] = 21, ["5"] = 23, ["6"] = 22, ["7"] = 26, ["8"] = 28, ["9"] = 25, [";"] = 41, ["="] = 24, ["["] = 33, ["\\"] = 42, ["]"] = 30, ["`"] = 10, a = 0, alt = 58, b = 11, c = 8, capslock = 57, cmd = 55, ctrl = 59, d = 2, delete = 51, down = 125, e = 14, eisu = 102, end = 119, escape = 53, f = 3, f1 = 122, f10 = 109, f11 = 103, f12 = 111, f13 = 105, f14 = 107, f15 = 113, f16 = 106, f17 = 64, f18 = 79, f19 = 80, f2 = 120, f20 = 90, f3 = 99, f4 = 118, f5 = 96, f6 = 97, f7 = 98, f8 = 100, f9 = 101, fn = 63, forwarddelete = 117, g = 5, h = 4, help = 114, home = 115, i = 34, j = 38, k = 40, kana = 104, l = 37, left = 123, m = 46, n = 45, o = 31, p = 35, ["pad*"] = 67, ["pad+"] = 69, ["pad,"] = 95, ["pad-"] = 78, ["pad."] = 65, ["pad/"] = 75, pad0 = 82, pad1 = 83, pad2 = 84, pad3 = 85, pad4 = 86, pad5 = 87, pad6 = 88, pad7 = 89, pad8 = 91, pad9 = 92, ["pad="] = 81, padclear = 71, padenter = 76, pagedown = 121, pageup = 116, q = 12, r = 15, ["return"] = 36, right = 124, rightalt = 61, rightcmd = 54, rightctrl = 62, rightshift = 60, s = 1, shift = 56, space = 49, t = 17, tab = 48, u = 32, underscore = 94, up = 126, v = 9, w = 13, x = 7, y = 16, yen = 93, z = 6 }

-- log.d(hs.keycodes.currentLayout().." - "..hsi(hs.keycodes.map[1]))
-- local keyboardLayout = hs.keycodes.currentLayout()
-- hs.keycodes.setLayout("English")
-- hs.timer.usleep(500000)
-- keyMap = hs.keycodes.map
-- log.d(hs.keycodes.currentLayout().." - "..hsi(hs.keycodes.map[1]))
-- hs.keycodes.setLayout(keyboardLayout)
-- keyboardLayout = nil

-- Notify hotkeyed app switching by message
key.appNotify = function(appName, message)
  -- log.d(appName.." "..message)
  -- if appName:match(".*illustrator.*") then log.d(appName.." "..message) end
  return
end

-- Bind a key
key.bind = function(hotkey, code)
  local mods, keys = key.parse(hotkey)
  return hs.hotkey.bind(mods, keys, function() load(code)() end)
end

-- Init application hotkey module
key.init = function(names)
  local module = {}
  module.names = names
  module.keys = hs.hotkey.modal.new()

  module.activate = function()
    if module.keys then
      module.keys:enter()
    end
  end

  module.deactivate = function()
    if module.keys then
      module.keys:exit()
    end
  end

  module.keys.entered = function()
    key.appNotify(module.names[1], "entered")
  end

  module.keys.exited = function()
    key.appNotify(module.names[1], "exited")
  end

  return module
end

-- Check application menu item for presence
key.isMenu = function(line)
  local menu = {}
  for item in line:gmatch("([^/]+)") do
    table.insert(menu, item)
  end
  return hs.application.frontmostApplication():findMenuItem(menu)
end

-- Click menu
key.menu = function(line, isRegex)
  if isRegex then
    return hs.application.frontmostApplication():selectMenuItem(line, true)
  else
    local menu = {}
    for item in line:gsub("//", "|__|"):gmatch("([^/]+)") do
      item = item:gsub("%|__%|", "/")
      table.insert(menu, item)
    end
    return hs.application.frontmostApplication():selectMenuItem(menu)
  end
end

-- Return character's keycode
key.code = function(char)
  return type(char) == "number" and char or key.map[char:lower()]
end

-- Convert hotkey from my notation to hammerspoon
key.parse = function(hotkey)
  local mods = {}
  local keys

  if hotkey:match("^[^-]+$") or hotkey == "-" then -- Check for solo keys (without modifiers) or solo "minus" char
    keys = hotkey
  elseif hotkey:match("^([^-]+%-)") then -- Check for hotkey sequence
    for modifier in hotkey:gmatch("([^-]+)%-") do
      table.insert(mods, modifier:lower())
    end
    if hotkey:match("%-%-$") then -- Check for minus char
      keys = "-"
    else
      keys = hotkey:match("%-([^-]+)$")
    end
  else
    log.e("error in key: "..hotkey)
  end

  if keys:match("^\\%d+$") then -- Check for keycode
    keys = tonumber(keys:match("^\\(%d+)$"))
  else
    keys = key.code(keys)
  end

  return mods, keys
end

-- Tap a key
key.tap = function(hotkey)
  hs.eventtap.keyStroke(key.parse(hotkey))
end

key.text = function(text)
  hs.eventtap.keyStrokes(text)
end

-- Load simple config file
key.loadConfig = function(file)
  -- Parsing config for chunks
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

  if #item ~= 0 then -- Add last item
    table.insert(items, item)
  end

  -- Parsing chunks
  local names
  local mods
  local keys
  local code
  local module

  for _, item in ipairs(items) do
    names = {}
    if _ == 1 then -- Parsing app names
      for __, line in ipairs(item) do
        if __ ~= 1 then
          line = trim(line)
          if not line:match("^%-%-") then
            table.insert(names, line)
          end
        end
      end
      module = key.init(names)
    else -- Parsing key/code
      keys = nil
      mods = nil
      code = nil
      for __, line in ipairs(item) do
        line = trim(line)
        if __ == 1 then
          lineNumber = line
        elseif __ == 2 then
          if line:match("^%-%-") then -- Break loop on commented hotkey
            break
          else -- Parsing hotkey
            if line == initSection then -- Check for init section
              keys = line
            else
              mods, keys = key.parse(line)
            --  errorResult, errorMessage = pcall(function() mods, keys = key.parse(line) end)
            --  if not errorResult then log.e("Erro r near line "..lineNumber.." we have error:"..errorMessage) end
            end
          end
        else -- Concatenate code lines
          code = code and code ..";\n"..line or line
        end
      end
      if code then
        local _code = code
        local _mods = mods
        local _keys = keys
        if _keys == initSection then -- Run init section's code
          load(_code)()
        else -- or bind code to hotkey
          module.keys:bind(hs.inspect(_mods), _keys, function() load(_code)() end)
        end
      end
    end
  end
  return module
end

-- Watch applications switch and enable their hotkeys
key.watch = function()
  if os.execute("test -d '"..configFolder.."'") then -- Check for hotkey folder presence

    local app
    local appWatcher

    -- Load lua/cfg application configs
    for app in hs.fs.dir(configFolder) do
      local fileName, fileType = app:match("^(.+)%.([^%.]+)$")
      if fileType == "lua" then
        if fileName:sub(1, 1) ~= disabledConfigPrefix and fileName ~= "init" then -- Ignore disabled modules
          key.apps[fileName] = require(configFolder.."/"..fileName)
        end
      elseif fileType == configExtension then -- Load simple configs
        if fileName:sub(1, 1) ~= "_" then
          key.apps[fileName] = key.loadConfig(configFolder.."/"..app)
        end
      end
    end

    -- Activate common application hotkeys
    if key.apps[configCommon] then
       key.apps[configCommon]:activate()
    end

    -- Define application switch watcher and hotkeys activator
    appWatcher = function(appName, eventType, appObject) -- Prepare app watcher
      for _, app in pairs(key.apps) do
        for _, name in ipairs(app.names) do
          if appName and appName:lower():match("^"..name:lower().."$") then
            if eventType == hs.application.watcher.activated then
              app:activate()
            elseif eventType == hs.application.watcher.deactivated then
              app:deactivate()
            end
          end
        end
      end
    end

    aw = hs.application.watcher.new(appWatcher):start()

    appWatcher(hs.application.frontmostApplication():name(), hs.application.watcher.activated, hs.application.frontmostApplication())
  end
end

return key

