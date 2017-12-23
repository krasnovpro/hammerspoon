--key = require "init"

local M = key.init{"Sketch"}

local mouseScroll = hs.eventtap.event.types.scrollWheel
local midButtonDown = hs.eventtap.event.types.middleMouseDown
local midButtonUp = hs.eventtap.event.types.middleMouseUp
local leftButtonDown = hs.eventtap.event.types.leftMouseDown
local leftButtonUp = hs.eventtap.event.types.leftMouseUp
local midMouseDrag = hs.eventtap.event.types.middleMouseDragged
local oldPosition = {}
local newPosition = {}
local scrollState = hs.eventtap.event.properties.scrollWheelEventDeltaAxis1
local eventTap = hs.eventtap.event
local space = hs.keycodes.map.space
local press = true
local release = false

M.zoom = hs.eventtap.new({mouseScroll}, function(e)
  return true, {eventTap.newScrollEvent({0, (-1 * e:getProperty(scrollState))}, {"cmd"})}
end)

M.pan = hs.eventtap.new({midButtonDown, midButtonUp, midMouseDrag}, function(e)
  if e:getButtonState(2) then
    oldPosition = hs.mouse.getAbsolutePosition()
    tprint(oldPosition)
    mMove = eventTap.newMouseEvent(leftButtonDown, oldPosition)
    mMove:post()
    -- return true, {eventTap.newMouseEvent(leftButtonDown, oldPosition)}
    return false
  else 
    newPosition.x = oldPosition.x + e:getProperty(eventTap.properties.mouseEventDeltaX)
    newPosition.y = oldPosition.y + e:getProperty(eventTap.properties.mouseEventDeltaY)
    tprint(newPosition)
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
