--key = require "init"

local M = key.init{"Figma"}

local _et = hs.eventtap
local _types = _et.event.types 
local mouseScroll = _types.scrollWheel
local midButtonDown = _types.middleMouseDown
local midButtonUp = _types.middleMouseUp
local leftButtonDown = _types.leftMouseDown
local leftButtonUp = _types.leftMouseUp
local midMouseDrag = _types.middleMouseDragged
local oldPosition = {}
local newPosition = {}
local scrollState = _et.event.properties.scrollWheelEventDeltaAxis1
local eventTap = _et.event
local space = hs.keycodes.map.space
local press = true
local release = false

M.zoom = _et.new({mouseScroll}, function(e)
  return true, {eventTap.newScrollEvent({0, e:getProperty(scrollState)}, {"cmd"})}
end)

M.activate = function() 
  M.zoom:start() 
end

M.deactivate = function() 
  M.zoom:stop() 
end

return M
