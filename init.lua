-- hammerspoon | olegkrasnov@gmail.com

-- ---------
-- Functions
-- ---------
insp = hs.inspect.inspect

trim = function(string)
  return type(string) == "string" and string:match("^%s*(.-)%s*$") or string
end

say = function(msg, duration, font, size) -- Styled alert
  local style = {
    fillColor = {black = 1, alpha = .4},
    strokeColor = {black = 1, alpha = 0},
    textSize = 20,
    radius = 15,
    textFont = font or hs.alert.defaultStyle.textFont,
    textSize = size or hs.alert.defaultStyle.textSize,
  }
  hs.alert.show(" "..msg.." ", style, hs.screen.primaryScreen(), duration or .6)
end

-- ----
-- Init
-- ----
package.path = os.getenv("HOME").."/.luarocks/share/lua/5.3/?.lua;"..os.getenv("HOME").."/.luarocks/share/lua/5.3/?/init.lua;"..package.path
package.cpath = os.getenv("HOME").."/.luarocks/lib/lua/5.3/?.so;"..package.cpath

hs.ipc.cliInstall()
hs.console.clearConsole()
log = hs.logger.new('⌘', 'debug')
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", hs.reload):start()
say("\xEF\x81\x90", nil, "Wingdings 3", 50) -- Message on reload

-- -------
-- Hotkeys
-- -------

-- hotkey: lshift/rshift - switch en/ru keyboard layout
local keyLayout = {
  showPopUp = false,
  leftLayout = "English",
  rightLayout = "Russian",
}

keyLayout.eventwatcher1 = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
  local flags = e:getFlags()
  -- Detect first solo shift-press = set press flag, unset ignore flag
  if flags.shift and not (flags.alt or flags.cmd or flags.ctrl or flags.fn) then
    keyLayout.WasPressed = true
    keyLayout.ShouldBeIgnored = false
    return false
  end
  -- Detect combined shift-press = set ignore flag
  if flags.shift and (flags.alt or flags.cmd or flags.ctrl or flags.fn) and keyLayout.WasPressed then
    keyLayout.ShouldBeIgnored = true
    return false
  end
  -- Detect solo shift-release and switch layout according left or right shift
  if not flags.shift then
    if keyLayout.WasPressed and not keyLayout.ShouldBeIgnored then
      local keyCode = e:getKeyCode()
      if keyCode == 0x38 then
        hs.keycodes.setLayout(keyLayout.leftLayout)
        if keyLayout.showPopUp then
          say("En", 0.3)
        end
      elseif keyCode == 0x3C then
        hs.keycodes.setLayout(keyLayout.rightLayout)
        if keyLayout.showPopUp then
          say("Ru", 0.3)
        end
      end
    end
    -- Unset flags
    keyLayout.WasPressed = false
    keyLayout.ShouldBeIgnored = false
  end
  return false
end):start()

keyLayout.eventwatcher2 = hs.eventtap.new({ "all", hs.eventtap.event.types.flagsChanged }, function(e)
  local flags = e:getFlags()
  if flags.shift and keyLayout.WasPressed then
    keyLayout.ShouldBeIgnored = true
  end
  return false
end):start()

-- hotkey: cmd-alt-del - lock desktop
hs.hotkey.bind({ "cmd", "alt" }, "forwarddelete", nil, function() hs.caffeinate.startScreensaver() end)

-- applications hotkey module
key = require "hotkey" key:watch()