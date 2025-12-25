-- ComputerUI.lua
-- Computer interface UI

require "ISUI/ISPanel"
require "Telecom/Computer"

ComputerUI = ISPanel:derive("ComputerUI")

-- Constructor
function ComputerUI:new(x, y, width, height, computer)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    
    o.computer = computer
    o.backgroundColor = {r=0, g=0, b=0, a=0.9}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.moveWithMouse = true
    
    o.currentView = "desktop"
    o.browserUrl = ""
    o.browserContent = ""
    o.emailRecipient = ""
    o.emailMessage = ""
    
    return o
end

-- Initialize UI
function ComputerUI:initialise()
    ISPanel.initialise(self)
    
    -- Title bar
    self.titleBar = ISPanel:new(0, 0, self.width, 25)
    self.titleBar:initialise()
    self.titleBar.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1}
    self:addChild(self.titleBar)
    
    -- Close button
    self.closeButton = ISButton:new(self.width - 25, 2, 20, 20, "X", self, ComputerUI.close)
    self.closeButton:initialise()
    self.closeButton.backgroundColor = {r=0.8, g=0.2, b=0.2, a=1}
    self.titleBar:addChild(self.closeButton)
    
    self:createDesktopView()
end

-- Create desktop view
function ComputerUI:createDesktopView()
    -- Status label
    self.statusLabel = ISLabel:new(10, 30, 20, "Status: " .. self.computer:getStatusString(), 1, 1, 1, 1, UIFont.Medium, true)
    self.statusLabel:initialise()
    self:addChild(self.statusLabel)
    
    -- App buttons
    local y = 60
    for i, appName in ipairs(self.computer.installedApps) do
        local button = ISButton:new(10, y, 200, 30, appName, self, ComputerUI.launchApp)
        button:initialise()
        button.internal = appName
        self:addChild(button)
        y = y + 35
    end
end

-- Launch app
function ComputerUI:launchApp(button)
    local success, message = self.computer:launchApp(button.internal)
    
    if success then
        self:removeChildren()
        self:initialise()
        
        if button.internal == "Browser" then
            self:createBrowserView()
        elseif button.internal == "Email" then
            self:createEmailView()
        elseif button.internal == "Terminal" then
            self:createTerminalView()
        elseif button.internal == "Settings" then
            self:createSettingsView()
        end
    end
end

-- Create browser view
function ComputerUI:createBrowserView()
    self.currentView = "browser"
    
    -- URL input
    local urlLabel = ISLabel:new(10, 60, 20, "URL:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(urlLabel)
    
    self.urlEntry = ISTextEntryBox:new("", 50, 55, 300, 25)
    self.urlEntry:initialise()
    self:addChild(self.urlEntry)
    
    -- Go button
    local goButton = ISButton:new(360, 55, 60, 25, "Go", self, ComputerUI.browseUrl)
    goButton:initialise()
    self:addChild(goButton)
    
    -- Content area
    self.contentLabel = ISLabel:new(10, 90, 20, "", 1, 1, 1, 1, UIFont.Small, true)
    self.contentLabel:initialise()
    self:addChild(self.contentLabel)
    
    -- Back button
    local backButton = ISButton:new(10, self.height - 40, 100, 30, "Back", self, ComputerUI.backToDesktop)
    backButton:initialise()
    self:addChild(backButton)
end

-- Browse URL
function ComputerUI:browseUrl()
    local url = self.urlEntry:getText()
    local success, content = self.computer:browse(url)
    
    if success then
        self.contentLabel:setName(content)
    else
        self.contentLabel:setName("Error: " .. content)
    end
end

-- Create email view
function ComputerUI:createEmailView()
    self.currentView = "email"
    
    -- Recipient
    local toLabel = ISLabel:new(10, 60, 20, "To:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(toLabel)
    
    self.recipientEntry = ISTextEntryBox:new("", 50, 55, 300, 25)
    self.recipientEntry:initialise()
    self:addChild(self.recipientEntry)
    
    -- Message
    local msgLabel = ISLabel:new(10, 90, 20, "Message:", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(msgLabel)
    
    self.messageEntry = ISTextEntryBox:new("", 80, 85, 340, 100)
    self.messageEntry:initialise()
    self.messageEntry:setMultipleLine(true)
    self:addChild(self.messageEntry)
    
    -- Send button
    local sendButton = ISButton:new(10, 195, 100, 30, "Send", self, ComputerUI.sendEmail)
    sendButton:initialise()
    self:addChild(sendButton)
    
    -- Back button
    local backButton = ISButton:new(120, 195, 100, 30, "Back", self, ComputerUI.backToDesktop)
    backButton:initialise()
    self:addChild(backButton)
end

-- Send email
function ComputerUI:sendEmail()
    local recipient = self.recipientEntry:getText()
    local message = self.messageEntry:getText()
    
    local success, result = self.computer:sendEmail(recipient, message)
    
    if success then
        self.recipientEntry:setText("")
        self.messageEntry:setText("")
    end
end

-- Create terminal view
function ComputerUI:createTerminalView()
    self.currentView = "terminal"
    
    local termLabel = ISLabel:new(10, 60, 20, "> Terminal Ready\n> Type 'help' for commands", 0, 1, 0, 1, UIFont.Small, true)
    self:addChild(termLabel)
    
    -- Back button
    local backButton = ISButton:new(10, self.height - 40, 100, 30, "Back", self, ComputerUI.backToDesktop)
    backButton:initialise()
    self:addChild(backButton)
end

-- Create settings view
function ComputerUI:createSettingsView()
    self.currentView = "settings"
    
    local status = self.computer:getStatus()
    local info = string.format(
        "Computer Status:\n\nPower: %s\nNetwork: %s\nCurrent App: %s",
        status.powered and "ON" or "OFF",
        status.hasNetwork and "Connected" or "Disconnected",
        status.currentApp or "None"
    )
    
    local settingsLabel = ISLabel:new(10, 60, 20, info, 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(settingsLabel)
    
    -- Back button
    local backButton = ISButton:new(10, self.height - 40, 100, 30, "Back", self, ComputerUI.backToDesktop)
    backButton:initialise()
    self:addChild(backButton)
end

-- Back to desktop
function ComputerUI:backToDesktop()
    self.computer.currentApp = nil
    self:removeChildren()
    self:initialise()
end

-- Close UI
function ComputerUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- Update
function ComputerUI:update()
    ISPanel.update(self)
    
    if self.statusLabel then
        self.statusLabel:setName("Status: " .. self.computer:getStatusString())
    end
end

return ComputerUI
