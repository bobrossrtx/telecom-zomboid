-- PhoneUI.lua
-- Phone interface UI

require "ISUI/ISPanel"
require "ISUI/ISLabel"
require "ISUI/ISButton"
require "ISUI/ISTextEntryBox"
require "Telecom/Phone"

PhoneUI = ISPanel:derive("PhoneUI")

-- Constructor
function PhoneUI:new(x, y, width, height, phone)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    
    o.phone = phone
    o.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.95}
    o.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    o.moveWithMouse = true
    
    o.currentView = "home"
    o.callNumber = ""
    o.textNumber = ""
    o.textMessage = ""
    
    return o
end

-- Initialize UI
function PhoneUI:initialise()
    ISPanel.initialise(self)
    
    -- Title bar with phone info
    self.titleBar = ISPanel:new(0, 0, self.width, 30)
    self.titleBar:initialise()
    self.titleBar.backgroundColor = {r=0.15, g=0.15, b=0.15, a=1}
    self:addChild(self.titleBar)
    
    local status = self.phone:getStatus()
    local titleText = string.format("Phone | Battery: %d%% | %s", 
        math.floor(status.battery), 
        status.hasSignal and "Signal" or "No Signal")
    
    self.titleLabel = ISLabel:new(5, 5, 20, titleText, 1, 1, 1, 1, UIFont.Small, true)
    self.titleLabel:initialise()
    self.titleBar:addChild(self.titleLabel)
    
    -- Close button
    self.closeButton = ISButton:new(self.width - 25, 2, 20, 25, "X", self, PhoneUI.close)
    self.closeButton:initialise()
    self.closeButton.backgroundColor = {r=0.8, g=0.2, b=0.2, a=1}
    self.titleBar:addChild(self.closeButton)
    
    self:createHomeView()
end

-- Create home view
function PhoneUI:createHomeView()
    self.currentView = "home"
    
    -- Phone number display
    local status = self.phone:getStatus()
    local numberLabel = ISLabel:new(10, 40, 20, "Number: " .. status.phoneNumber, 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(numberLabel)
    
    -- Menu buttons
    local buttonY = 70
    local buttons = {
        {name = "Call", func = PhoneUI.showCallView},
        {name = "Messages", func = PhoneUI.showMessagesView},
        {name = "Contacts", func = PhoneUI.showContactsView},
        {name = "Settings", func = PhoneUI.showSettingsView}
    }
    
    for _, btnData in ipairs(buttons) do
        local btn = ISButton:new(10, buttonY, self.width - 20, 35, btnData.name, self, btnData.func)
        btn:initialise()
        self:addChild(btn)
        buttonY = buttonY + 40
    end
end

-- Show call view
function PhoneUI:showCallView()
    self:removeChildren()
    self:initialise()
    self.currentView = "call"
    
    -- Number input
    local numLabel = ISLabel:new(10, 45, 20, "Phone Number:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(numLabel)
    
    self.numberEntry = ISTextEntryBox:new("", 10, 70, self.width - 20, 25)
    self.numberEntry:initialise()
    self:addChild(self.numberEntry)
    
    -- Call button
    local callButton = ISButton:new(10, 105, self.width - 20, 35, "Make Call", self, PhoneUI.makeCall)
    callButton:initialise()
    self:addChild(callButton)
    
    -- Result display
    self.callResult = ISLabel:new(10, 150, 20, "", 1, 1, 0, 1, UIFont.Small, true)
    self:addChild(self.callResult)
    
    -- Back button
    local backButton = ISButton:new(10, self.height - 45, self.width - 20, 35, "Back", self, PhoneUI.backToHome)
    backButton:initialise()
    self:addChild(backButton)
end

-- Make call
function PhoneUI:makeCall()
    local number = self.numberEntry:getText()
    if number == "" then
        self.callResult:setName("Please enter a phone number")
        return
    end
    
    local success, response = self.phone:makeCall(number)
    
    if success then
        self.callResult:setName("Call to " .. number .. ":\n" .. response)
    else
        self.callResult:setName("Error: " .. response)
    end
end

-- Show messages view
function PhoneUI:showMessagesView()
    self:removeChildren()
    self:initialise()
    self.currentView = "messages"
    
    local y = 45
    
    -- Send message button
    local sendButton = ISButton:new(10, y, self.width - 20, 30, "Send New Message", self, PhoneUI.showSendMessageView)
    sendButton:initialise()
    self:addChild(sendButton)
    y = y + 35
    
    -- Display messages
    local messagesLabel = ISLabel:new(10, y, 20, "Recent Messages:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(messagesLabel)
    y = y + 25
    
    local messages = self.phone.messages
    if #messages == 0 then
        local noMsgLabel = ISLabel:new(10, y, 20, "No messages", 0.7, 0.7, 0.7, 1, UIFont.Small, true)
        self:addChild(noMsgLabel)
    else
        -- Show last 5 messages
        for i = math.max(1, #messages - 4), #messages do
            local msg = messages[i]
            local msgText = string.format("%s %s: %s",
                msg.outgoing and "To" or "From",
                self.phone:getContactName(msg.number),
                msg.text:sub(1, 30))
            
            local msgLabel = ISLabel:new(10, y, 20, msgText, 1, 1, 1, 1, UIFont.Small, true)
            self:addChild(msgLabel)
            y = y + 20
        end
    end
    
    -- Back button
    local backButton = ISButton:new(10, self.height - 45, self.width - 20, 35, "Back", self, PhoneUI.backToHome)
    backButton:initialise()
    self:addChild(backButton)
end

-- Show send message view
function PhoneUI:showSendMessageView()
    self:removeChildren()
    self:initialise()
    self.currentView = "sendmessage"
    
    -- Number input
    local numLabel = ISLabel:new(10, 45, 20, "To:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(numLabel)
    
    self.textNumberEntry = ISTextEntryBox:new("", 40, 40, self.width - 50, 25)
    self.textNumberEntry:initialise()
    self:addChild(self.textNumberEntry)
    
    -- Message input
    local msgLabel = ISLabel:new(10, 75, 20, "Message:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(msgLabel)
    
    self.textMessageEntry = ISTextEntryBox:new("", 10, 100, self.width - 20, 80)
    self.textMessageEntry:initialise()
    self.textMessageEntry:setMultipleLine(true)
    self:addChild(self.textMessageEntry)
    
    -- Send button
    local sendButton = ISButton:new(10, 190, self.width - 20, 35, "Send", self, PhoneUI.sendText)
    sendButton:initialise()
    self:addChild(sendButton)
    
    -- Back button
    local backButton = ISButton:new(10, self.height - 45, self.width - 20, 35, "Back", self, PhoneUI.showMessagesView)
    backButton:initialise()
    self:addChild(backButton)
end

-- Send text
function PhoneUI:sendText()
    local number = self.textNumberEntry:getText()
    local message = self.textMessageEntry:getText()
    
    if number == "" or message == "" then
        return
    end
    
    local success, result = self.phone:sendText(number, message)
    
    if success then
        self.textNumberEntry:setText("")
        self.textMessageEntry:setText("")
        self:showMessagesView()
    end
end

-- Show contacts view
function PhoneUI:showContactsView()
    self:removeChildren()
    self:initialise()
    self.currentView = "contacts"
    
    local y = 45
    local contactsLabel = ISLabel:new(10, y, 20, "Contacts:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(contactsLabel)
    y = y + 25
    
    local hasContacts = false
    for number, name in pairs(self.phone.contacts) do
        hasContacts = true
        local contactLabel = ISLabel:new(10, y, 20, name .. ": " .. number, 1, 1, 1, 1, UIFont.Small, true)
        self:addChild(contactLabel)
        y = y + 20
    end
    
    if not hasContacts then
        local noContactLabel = ISLabel:new(10, y, 20, "No contacts", 0.7, 0.7, 0.7, 1, UIFont.Small, true)
        self:addChild(noContactLabel)
    end
    
    -- Back button
    local backButton = ISButton:new(10, self.height - 45, self.width - 20, 35, "Back", self, PhoneUI.backToHome)
    backButton:initialise()
    self:addChild(backButton)
end

-- Show settings view
function PhoneUI:showSettingsView()
    self:removeChildren()
    self:initialise()
    self.currentView = "settings"
    
    local status = self.phone:getStatus()
    local settingsText = string.format(
        "Phone Settings:\n\nBattery: %d%%\nSignal: %s\nPower: %s\nNumber: %s",
        math.floor(status.battery),
        status.hasSignal and "Connected" or "No Signal",
        status.isOn and "On" or "Off",
        status.phoneNumber
    )
    
    local settingsLabel = ISLabel:new(10, 45, 20, settingsText, 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(settingsLabel)
    
    -- Back button
    local backButton = ISButton:new(10, self.height - 45, self.width - 20, 35, "Back", self, PhoneUI.backToHome)
    backButton:initialise()
    self:addChild(backButton)
end

-- Back to home
function PhoneUI:backToHome()
    self:removeChildren()
    self:initialise()
end

-- Close UI
function PhoneUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- Update
function PhoneUI:update()
    ISPanel.update(self)
    
    if self.titleLabel then
        local status = self.phone:getStatus()
        local titleText = string.format("Phone | Battery: %d%% | %s", 
            math.floor(status.battery), 
            status.hasSignal and "Signal" or "No Signal")
        self.titleLabel:setName(titleText)
    end
end

return PhoneUI
