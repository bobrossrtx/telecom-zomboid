-- Phone.lua
-- Phone device implementation with call and text functionality

require "Telecom/TelecomDevice"

Phone = {}
Phone.__index = Phone
setmetatable(Phone, {__index = TelecomDevice})

-- Constructor
function Phone:new(x, y, z, player)
    local phone = TelecomDevice:new(NetworkState.NodeType.PHONE, x, y, z, player)
    setmetatable(phone, Phone)
    
    phone.phoneNumber = Phone.generatePhoneNumber()
    phone.battery = 100
    phone.isOn = true
    phone.contacts = {}
    phone.messages = {}
    phone.callHistory = {}
    
    return phone
end

-- Generate random phone number
function Phone.generatePhoneNumber()
    local area = ZombRand(200, 999)
    local prefix = ZombRand(200, 999)
    local line = ZombRand(1000, 9999)
    return string.format("%03d-%03d-%04d", area, prefix, line)
end

-- Make a call
function Phone:makeCall(phoneNumber)
    if not self.isOn then
        return false, "Phone is off"
    end
    
    if self.battery <= 0 then
        return false, "Battery dead"
    end
    
    if not self:hasNetworkConnectivity() then
        return false, "No signal"
    end
    
    -- Drain battery
    self.battery = math.max(0, self.battery - 1)
    
    -- Add to call history
    table.insert(self.callHistory, {
        number = phoneNumber,
        timestamp = getTimestamp(),
        outgoing = true
    })
    
    -- Simulate call responses
    local responses = {
        "Emergency services are currently unavailable.",
        "The number you have dialed is not in service.",
        "All circuits are busy. Please try again later.",
        "You've reached a survivor. We're at the warehouse on 5th street.",
        "This is an automated message. The evacuation point is compromised."
    }
    
    local response = responses[ZombRand(1, #responses + 1)]
    return true, response
end

-- Send text message
function Phone:sendText(phoneNumber, message)
    if not self.isOn then
        return false, "Phone is off"
    end
    
    if self.battery <= 0 then
        return false, "Battery dead"
    end
    
    if not self:hasNetworkConnectivity() then
        return false, "No signal"
    end
    
    -- Drain battery (less than call)
    self.battery = math.max(0, self.battery - 0.5)
    
    -- Store message
    table.insert(self.messages, {
        number = phoneNumber,
        text = message,
        timestamp = getTimestamp(),
        outgoing = true,
        read = true
    })
    
    return true, "Message sent"
end

-- Receive a simulated text (for gameplay)
function Phone:receiveText(fromNumber, message)
    if not self.isOn then return false end
    
    table.insert(self.messages, {
        number = fromNumber,
        text = message,
        timestamp = getTimestamp(),
        outgoing = false,
        read = false
    })
    
    return true
end

-- Add contact
function Phone:addContact(name, number)
    self.contacts[number] = name
    return true
end

-- Get contact name
function Phone:getContactName(number)
    return self.contacts[number] or number
end

-- Charge phone (when connected to power)
function Phone:charge()
    if self.powered then
        self.battery = math.min(100, self.battery + 5)
    end
end

-- Update phone state
function Phone:update()
    TelecomDevice.update(self)
    
    -- Drain battery slowly when on
    if self.isOn and getTimestamp() % 60 == 0 then
        self.battery = math.max(0, self.battery - 0.1)
        
        -- Turn off if battery dead
        if self.battery <= 0 then
            self.isOn = false
        end
    end
    
    -- Charge if powered
    if self.powered then
        self:charge()
    end
end

-- Toggle phone power
function Phone:togglePower()
    if self.battery <= 0 then
        return false, "Battery dead - needs charging"
    end
    
    self.isOn = not self.isOn
    return true, self.isOn and "Phone on" or "Phone off"
end

-- Get phone status
function Phone:getStatus()
    local status = {
        powered = self.powered,
        isOn = self.isOn,
        battery = self.battery,
        hasSignal = self:hasNetworkConnectivity(),
        phoneNumber = self.phoneNumber,
        unreadMessages = 0,
        statusText = self:getStatusString()
    }
    
    -- Count unread messages
    for _, msg in ipairs(self.messages) do
        if not msg.read and not msg.outgoing then
            status.unreadMessages = status.unreadMessages + 1
        end
    end
    
    return status
end

return Phone
