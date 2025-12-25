-- TelecomUtils.lua
-- Utility functions for the Telecom mod

TelecomUtils = TelecomUtils or {}

-- Get current timestamp in seconds
function TelecomUtils.getTime()
    -- Use game time in hours converted to seconds
    return getGameTime():getWorldAgeHours() * 3600
end

return TelecomUtils
