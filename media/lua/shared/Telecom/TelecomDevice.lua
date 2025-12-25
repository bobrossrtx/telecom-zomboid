-- TelecomDevice.lua
-- Base class for all telecommunication devices

require "Telecom/NetworkState"
require "Telecom/TelecomUtils"

TelecomDevice = {}
TelecomDevice.__index = TelecomDevice

-- Constructor
function TelecomDevice:new(deviceType, x, y, z, player)
    local device = {
        type = deviceType,
        x = x or 0,
        y = y or 0,
        z = z or 0,
        powered = false,
        networkId = nil,
        player = player,
        lastCheck = 0
    }
    
    setmetatable(device, TelecomDevice)
    
    -- Register with network if server
    if isServer() or not isClient() then
        device.networkId = NetworkState.registerNode(x, y, z, deviceType, player and player:getUsername() or "unknown")
    end
    
    return device
end

-- Check if device has power
function TelecomDevice:hasPower()
    local square = getCell():getGridSquare(self.x, self.y, self.z)
    if not square then return false end
    
    -- Check if building has power
    local building = square:getBuilding()
    if building then
        return building:hasElectricity()
    end
    
    return false
end

-- Update device state
function TelecomDevice:update()
    local currentTime = TelecomUtils.getTime()
    
    -- Only check power every few seconds
    if currentTime - self.lastCheck < 5 then
        return
    end
    
    self.lastCheck = currentTime
    local hasPower = self:hasPower()
    
    if hasPower ~= self.powered then
        self.powered = hasPower
        self:onPowerChange(hasPower)
    end
end

-- Called when power state changes
function TelecomDevice:onPowerChange(powered)
    if isServer() or not isClient() then
        if self.networkId then
            if powered then
                NetworkState.activateNode(self.networkId)
            else
                NetworkState.deactivateNode(self.networkId)
            end
        end
    end
end

-- Check if device has network connectivity
function TelecomDevice:hasNetworkConnectivity()
    if not self.powered then return false end
    
    if isServer() or not isClient() then
        if self.networkId then
            return NetworkState.hasConnectivity(self.networkId)
        end
    end
    
    return false
end

-- Get device status string
function TelecomDevice:getStatusString()
    if not self.powered then
        return "No Power"
    end
    
    if not self:hasNetworkConnectivity() then
        return "No Network Connection"
    end
    
    return "Connected"
end

-- Destroy device
function TelecomDevice:destroy()
    if isServer() or not isClient() then
        if self.networkId then
            NetworkState.unregisterNode(self.networkId)
        end
    end
end

-- Connect to another device
function TelecomDevice:connectTo(otherDevice)
    if isServer() or not isClient() then
        if self.networkId and otherDevice.networkId then
            return NetworkState.connectNodes(self.networkId, otherDevice.networkId)
        end
    end
    return false
end

return TelecomDevice
