-- TelecomContextMenu.lua
-- Context menu integration for telecom devices

require "Telecom/Computer"
require "Telecom/Phone"
require "Telecom/ComputerUI"
require "Telecom/PhoneUI"

TelecomContextMenu = TelecomContextMenu or {}
TelecomContextMenu.devices = {}

-- Register a device at a world location
function TelecomContextMenu.registerDevice(x, y, z, deviceType)
    local key = x .. "_" .. y .. "_" .. z
    
    if not TelecomContextMenu.devices[key] then
        local player = getPlayer()
        
        if deviceType == "computer" then
            TelecomContextMenu.devices[key] = Computer:new(x, y, z, player)
        elseif deviceType == "phone" then
            TelecomContextMenu.devices[key] = Phone:new(x, y, z, player)
        end
    end
    
    return TelecomContextMenu.devices[key]
end

-- Get device at location
function TelecomContextMenu.getDevice(x, y, z)
    local key = x .. "_" .. y .. "_" .. z
    return TelecomContextMenu.devices[key]
end

-- Use computer (context menu action)
function TelecomContextMenu.useComputer(worldobjects, player)
    local square = nil
    
    for i = 1, worldobjects:size() do
        local obj = worldobjects:get(i-1)
        square = obj:getSquare()
        break
    end
    
    if not square then return end
    
    local x = square:getX()
    local y = square:getY()
    local z = square:getZ()
    
    -- Register or get existing computer
    local computer = TelecomContextMenu.registerDevice(x, y, z, "computer")
    
    if not computer then return end
    
    -- Toggle computer power first
    local success, message = computer:togglePower()
    
    if success and computer.isOn then
        -- Open computer UI
        local ui = ComputerUI:new(100, 100, 450, 400, computer)
        ui:initialise()
        ui:addToUIManager()
    end
end

-- Use phone (context menu action)
function TelecomContextMenu.usePhone(worldobjects, player)
    local square = nil
    
    for i = 1, worldobjects:size() do
        local obj = worldobjects:get(i-1)
        square = obj:getSquare()
        break
    end
    
    if not square then return end
    
    local x = square:getX()
    local y = square:getY()
    local z = square:getZ()
    
    -- Register or get existing phone
    local phone = TelecomContextMenu.registerDevice(x, y, z, "phone")
    
    if not phone then return end
    
    -- Open phone UI
    local ui = PhoneUI:new(100, 100, 320, 450, phone)
    ui:initialise()
    ui:addToUIManager()
end

-- Use router (context menu action)
function TelecomContextMenu.useRouter(worldobjects, player)
    local square = nil
    
    for i = 1, worldobjects:size() do
        local obj = worldobjects:get(i-1)
        square = obj:getSquare()
        break
    end
    
    if not square then return end
    
    local x = square:getX()
    local y = square:getY()
    local z = square:getZ()
    
    -- Register router
    local router = TelecomContextMenu.registerDevice(x, y, z, "router")
    
    if router then
        player:Say("Router is " .. (router.powered and "online" or "offline"))
    end
end

-- Add context menu options
function TelecomContextMenu.createMenu(player, context, worldobjects, test)
    if test then return true end
    
    -- Check for telecom devices in world objects
    for i = 1, worldobjects:size() do
        local obj = worldobjects:get(i-1)
        local sprite = obj:getSprite()
        
        if sprite then
            local spriteName = sprite:getName()
            
            -- Check for computer sprites
            if spriteName and (
                spriteName:contains("computer") or 
                spriteName:contains("Computer") or
                spriteName:contains("electronics_01_16") or
                spriteName:contains("electronics_01_17")
            ) then
                context:addOption("Use Computer", worldobjects, TelecomContextMenu.useComputer, player)
            end
            
            -- Check for phone sprites
            if spriteName and (
                spriteName:contains("telephone") or
                spriteName:contains("phone") or
                spriteName:contains("Phone")
            ) then
                context:addOption("Use Phone", worldobjects, TelecomContextMenu.usePhone, player)
            end
            
            -- Check for router/modem sprites
            if spriteName and (
                spriteName:contains("router") or
                spriteName:contains("modem") or
                spriteName:contains("Router")
            ) then
                context:addOption("Check Router", worldobjects, TelecomContextMenu.useRouter, player)
            end
        end
    end
end

-- Update all devices periodically
function TelecomContextMenu.updateDevices()
    for key, device in pairs(TelecomContextMenu.devices) do
        if device.update then
            device:update()
        end
    end
end

-- Event hooks
Events.OnFillWorldObjectContextMenu.Add(TelecomContextMenu.createMenu)
Events.EveryOneMinute.Add(TelecomContextMenu.updateDevices)

return TelecomContextMenu
