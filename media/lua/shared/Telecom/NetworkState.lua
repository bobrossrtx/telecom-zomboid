-- NetworkState.lua
-- Manages the global state of the telecommunications network

require "Telecom/TelecomUtils"

NetworkState = NetworkState or {}

-- Initialize network state
NetworkState.nodes = NetworkState.nodes or {}
NetworkState.activeConnections = NetworkState.activeConnections or 0
NetworkState.globalNetworkActive = NetworkState.globalNetworkActive or false
NetworkState.powerGrids = NetworkState.powerGrids or {}

-- Network node types
NetworkState.NodeType = {
    ROUTER = "router",
    MODEM = "modem",
    SERVER = "server",
    COMPUTER = "computer",
    PHONE = "phone"
}

-- Register a network node at a location
function NetworkState.registerNode(x, y, z, nodeType, playerId)
    -- Only register on server or single-player
    if isClient() and not isServer() then return nil end
    
    local nodeId = x .. "_" .. y .. "_" .. z
    
    NetworkState.nodes[nodeId] = {
        x = x,
        y = y,
        z = z,
        type = nodeType,
        active = false,
        owner = playerId,
        connectedNodes = {},
        lastUpdate = TelecomUtils.getTime()
    }
    
    return nodeId
end

-- Remove a network node
function NetworkState.unregisterNode(nodeId)
    -- Only unregister on server or single-player
    if isClient() and not isServer() then return end
    
    if NetworkState.nodes[nodeId] then
        -- Disconnect from all connected nodes
        for connectedId, _ in pairs(NetworkState.nodes[nodeId].connectedNodes) do
            if NetworkState.nodes[connectedId] then
                NetworkState.nodes[connectedId].connectedNodes[nodeId] = nil
            end
        end
        
        NetworkState.nodes[nodeId] = nil
        NetworkState.updateNetworkState()
    end
end

-- Activate a node (when powered)
function NetworkState.activateNode(nodeId)
    -- Only activate on server or single-player
    if isClient() and not isServer() then return false end
    
    if NetworkState.nodes[nodeId] then
        NetworkState.nodes[nodeId].active = true
        NetworkState.nodes[nodeId].lastUpdate = TelecomUtils.getTime()
        NetworkState.updateNetworkState()
        return true
    end
    return false
end

-- Deactivate a node (power loss)
function NetworkState.deactivateNode(nodeId)
    -- Only deactivate on server or single-player
    if isClient() and not isServer() then return false end
    
    if NetworkState.nodes[nodeId] then
        NetworkState.nodes[nodeId].active = false
        NetworkState.nodes[nodeId].lastUpdate = TelecomUtils.getTime()
        NetworkState.updateNetworkState()
        return true
    end
    return false
end

-- Check if a node has network connectivity
function NetworkState.hasConnectivity(nodeId)
    if not NetworkState.nodes[nodeId] or not NetworkState.nodes[nodeId].active then
        return false
    end
    
    -- Check if connected to an active router or modem
    for connectedId, _ in pairs(NetworkState.nodes[nodeId].connectedNodes) do
        local connectedNode = NetworkState.nodes[connectedId]
        if connectedNode and connectedNode.active then
            if connectedNode.type == NetworkState.NodeType.ROUTER or 
               connectedNode.type == NetworkState.NodeType.MODEM then
                return true
            end
        end
    end
    
    return false
end

-- Connect two nodes
function NetworkState.connectNodes(nodeId1, nodeId2)
    -- Only connect on server or single-player
    if isClient() and not isServer() then return false end
    
    if NetworkState.nodes[nodeId1] and NetworkState.nodes[nodeId2] then
        NetworkState.nodes[nodeId1].connectedNodes[nodeId2] = true
        NetworkState.nodes[nodeId2].connectedNodes[nodeId1] = true
        NetworkState.updateNetworkState()
        return true
    end
    return false
end

-- Update global network state
function NetworkState.updateNetworkState()
    -- Only update on server or single-player
    if isClient() and not isServer() then return end
    
    local activeNodes = 0
    local activeRouters = 0
    
    for nodeId, node in pairs(NetworkState.nodes) do
        if node.active then
            activeNodes = activeNodes + 1
            if node.type == NetworkState.NodeType.ROUTER or 
               node.type == NetworkState.NodeType.MODEM then
                activeRouters = activeRouters + 1
            end
        end
    end
    
    NetworkState.activeConnections = activeNodes
    NetworkState.globalNetworkActive = activeRouters > 0
end

-- Get network status for a location
function NetworkState.getNetworkStatus(x, y, z)
    local nodeId = x .. "_" .. y .. "_" .. z
    
    if NetworkState.nodes[nodeId] then
        return {
            exists = true,
            active = NetworkState.nodes[nodeId].active,
            hasConnectivity = NetworkState.hasConnectivity(nodeId),
            type = NetworkState.nodes[nodeId].type
        }
    end
    
    return {
        exists = false,
        active = false,
        hasConnectivity = false,
        type = nil
    }
end

-- Save network state (for persistence)
function NetworkState.save()
    -- Only save on server or single-player
    if isClient() and not isServer() then return end
    
    ModData.add("TelecomNetwork", NetworkState)
end

-- Load network state (on server start)
function NetworkState.load()
    -- Only load on server or single-player
    if isClient() and not isServer() then return end
    
    local data = ModData.get("TelecomNetwork")
    if data then
        NetworkState.nodes = data.nodes or {}
        NetworkState.activeConnections = data.activeConnections or 0
        NetworkState.globalNetworkActive = data.globalNetworkActive or false
        NetworkState.powerGrids = data.powerGrids or {}
    end
end

-- Initialize on server start
Events.OnServerStarted.Add(function()
    NetworkState.load()
end)

-- Save periodically
Events.EveryTenMinutes.Add(function()
    NetworkState.save()
end)

-- Save on shutdown
Events.OnServerShutdown.Add(function()
    NetworkState.save()
end)
