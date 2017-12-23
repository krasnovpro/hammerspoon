local tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp }, function(event)

  --[[
    If the right command button is pressed, we want to remap ESDF to up, left,
    down, right. We also want to retain the other modifiers, which includes
    keeping the command modifier if the left command button is also pressed.

    Hammerspoon by default does not allow us to check if the left or right
    modifier is pressed so we need to check the raw event flags property, which
    does contain this information.

    While we can modify the event and replace the keycodes for esdf with those
    of the arrow keys we do not have fine grained control over the modifiers
    because we cannot modify the actual flags but only toggle modifiers as a
    "whole". This means that when we remove the command modifier from the event,
    we also lose the detailed information on other modfiers (left or right
    shift, for example) which might be present. This might cause incompatibility
    issues with your specific setup if it depends on that information.

    KeyCodes for e, s, d, f: 14, 1, 2, 3
    KeyCodes for up, left, down, right: 126, 123, 125, 124
    Command bitmask: 0x100000 (bit 21)
    Cmd Left: 0x8 (bit 4)
    Cmd Right: 0x16 (bit 5)
  ]]--

  local flags = event:getRawEventData().CGEventData.flags

  local cmd = flags & 0x100000 > 0
  local cmdLeft = cmd and flags & 0x8 > 0
  local cmdRight = cmd and flags & 0x10 > 0

  local keyCode = event:getKeyCode()

  -- if right command && (e, s, d or f)
  if (cmdRight and (keyCode == 14 or keyCode == 1 or keyCode == 2 or keyCode == 3)) then

    if (not cmdLeft) then
      -- strip command modifier
      -- this also (presumably) loses the detailed information on the other
      -- modifiers
      local flags = event:getFlags()
      flags["cmd"] = false
      event:setFlags(flags)
    end

    -- remap esdf to arrows
    if (keyCode == 14) then event:setKeyCode(126) end -- up
    if (keyCode == 1) then event:setKeyCode(123) end -- left
    if (keyCode == 2) then event:setKeyCode(125) end -- down
    if (keyCode == 3) then event:setKeyCode(124) end -- right

  end

  return false
end):start()
