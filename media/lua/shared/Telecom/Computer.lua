-- Computer.lua
-- Computer device implementation with internet functionality

require "Telecom/TelecomDevice"
require "Telecom/NetworkState"
require "Telecom/TelecomUtils"

Computer = {}
Computer.__index = Computer
setmetatable(Computer, {__index = TelecomDevice})

-- Constructor
function Computer:new(x, y, z, player)
    local computer = TelecomDevice:new(NetworkState.NodeType.COMPUTER, x, y, z, player)
    setmetatable(computer, Computer)
    
    computer.isOn = false
    computer.bootTime = 0
    computer.currentApp = nil
    computer.installedApps = {
        "Browser",
        "Email",
        "Terminal",
        "Settings"
    }
    
    return computer
end

-- Turn computer on/off
function Computer:togglePower()
    if not self.powered then
        return false, "No electrical power"
    end
    
    self.isOn = not self.isOn
    
    if self.isOn then
        self.bootTime = TelecomUtils.getTime()
        return true, "Computer booting up..."
    else
        self.currentApp = nil
        return true, "Computer shutting down..."
    end
end

-- Check if computer is fully booted
function Computer:isBooted()
    if not self.isOn then return false end
    
    local elapsed = TelecomUtils.getTime() - self.bootTime
    return elapsed > 3 -- Boot takes 3 seconds
end

-- Launch an application
function Computer:launchApp(appName)
    if not self:isBooted() then
        return false, "Computer is not ready"
    end
    
    if not self:hasNetworkConnectivity() and appName ~= "Settings" and appName ~= "Terminal" then
        return false, "No network connection required for " .. appName
    end
    
    for _, app in ipairs(self.installedApps) do
        if app == appName then
            self.currentApp = appName
            return true, "Launched " .. appName
        end
    end
    
    return false, "Application not found"
end

-- Browse internet
function Computer:browse(url)
    if not self:hasNetworkConnectivity() then
        return false, "No internet connection"
    end
    
    if self.currentApp ~= "Browser" then
        return false, "Browser not open"
    end
    
    -- Simulate browsing
    local responses = {
        ["news.local"] = "LOCAL NEWS: Survivors report power restored in some areas. Network infrastructure slowly coming back online.",
        ["emergency.gov"] = "EMERGENCY BROADCAST: Find shelter. Avoid infected. Restore utilities when possible.",
        ["survivors.net"] = "SURVIVOR FORUM: Trading post at coordinates (10500, 9800). Bring supplies.",
        ["wiki.knowledge"] = "KNOWLEDGE BASE: Electronics repair guide - Use electronic scrap and circuit boards to repair devices."
    }
    
    return true, responses[url] or "Page not found. Try: news.local, emergency.gov, survivors.net, wiki.knowledge"
end

-- Send email
function Computer:sendEmail(recipient, message)
    if not self:hasNetworkConnectivity() then
        return false, "No internet connection"
    end
    
    if self.currentApp ~= "Email" then
        return false, "Email client not open"
    end
    
    -- Simulate email (could be extended to store messages)
    return true, "Email sent to " .. recipient
end

-- Get computer status
function Computer:getStatus()
    local status = {
        powered = self.powered,
        isOn = self.isOn,
        booted = self:isBooted(),
        hasNetwork = self:hasNetworkConnectivity(),
        currentApp = self.currentApp,
        statusText = self:getStatusString()
    }
    
    return status
end

return Computer
