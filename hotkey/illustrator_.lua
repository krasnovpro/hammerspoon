--key = require "init"

local M = key.init{"Adobe Illustrator.+"}

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
  return true, {eventTap.newScrollEvent({0, e:getProperty(scrollState)}, {"alt"})}
end)

M.pan = _et.new({midButtonDown, midButtonUp, midMouseDrag}, function(e)
  if e:getButtonState(2) then
    oldPosition = hs.mouse.getAbsolutePosition()
    -- tprint(oldPosition)
    mMove = eventTap.newMouseEvent(leftButtonDown, oldPosition)
    mMove:post()
    -- return true, {eventTap.newMouseEvent(leftButtonDown, oldPosition)}
    return false
  else 
    newPosition.x = oldPosition.x + e:getProperty(eventTap.properties.mouseEventDeltaX)
    newPosition.y = oldPosition.y + e:getProperty(eventTap.properties.mouseEventDeltaY)
    -- tprint(newPosition)
    return true, {eventTap.newMouseEvent(leftButtonUp, newPosition)}
  end
end)

M.activate = function() 
  M.zoom:start() 
  -- M.pan:start() 
end

M.deactivate = function() 
  M.zoom:stop() 
  -- M.pan:stop() 
end

return M
