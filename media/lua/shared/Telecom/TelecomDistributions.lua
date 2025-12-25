-- TelecomDistributions.lua
-- Spawn distributions for telecom items

require "Items/Distributions"
require "Items/ProceduralDistributions"
require "Vehicles/VehicleDistributions"

-- Add to existing loot tables
table.insert(ProceduralDistributions.list["ElectronicStoreComputers"].items, "Base.Computer")
table.insert(ProceduralDistributions.list["ElectronicStoreComputers"].items, 4)
table.insert(ProceduralDistributions.list["ElectronicStoreComputers"].items, "Base.Laptop")
table.insert(ProceduralDistributions.list["ElectronicStoreComputers"].items, 6)

table.insert(ProceduralDistributions.list["ElectronicStoreMisc"].items, "Base.WifiRouter")
table.insert(ProceduralDistributions.list["ElectronicStoreMisc"].items, 8)
table.insert(ProceduralDistributions.list["ElectronicStoreMisc"].items, "Base.CableModem")
table.insert(ProceduralDistributions.list["ElectronicStoreMisc"].items, 6)
table.insert(ProceduralDistributions.list["ElectronicStoreMisc"].items, "Base.NetworkSwitch")
table.insert(ProceduralDistributions.list["ElectronicStoreMisc"].items, 4)
table.insert(ProceduralDistributions.list["ElectronicStoreMisc"].items, "Base.EthernetCable")
table.insert(ProceduralDistributions.list["ElectronicStoreMisc"].items, 10)

-- Office spawns
if ProceduralDistributions.list["OfficeDesk"] then
    table.insert(ProceduralDistributions.list["OfficeDesk"].items, "Base.Computer")
    table.insert(ProceduralDistributions.list["OfficeDesk"].items, 2)
    table.insert(ProceduralDistributions.list["OfficeDesk"].items, "Base.CellPhone")
    table.insert(ProceduralDistributions.list["OfficeDesk"].items, 4)
end

-- Bedroom spawns for phones
if ProceduralDistributions.list["BedroomDresser"] then
    table.insert(ProceduralDistributions.list["BedroomDresser"].items, "Base.CellPhone")
    table.insert(ProceduralDistributions.list["BedroomDresser"].items, 3)
    table.insert(ProceduralDistributions.list["BedroomDresser"].items, "Base.Smartphone")
    table.insert(ProceduralDistributions.list["BedroomDresser"].items, 2)
end

-- Living room spawns
if ProceduralDistributions.list["LivingRoomShelf"] then
    table.insert(ProceduralDistributions.list["LivingRoomShelf"].items, "Base.WifiRouter")
    table.insert(ProceduralDistributions.list["LivingRoomShelf"].items, 4)
end

-- Store room / warehouse spawns
if ProceduralDistributions.list["StoreShelfElectronics"] then
    table.insert(ProceduralDistributions.list["StoreShelfElectronics"].items, "Base.Laptop")
    table.insert(ProceduralDistributions.list["StoreShelfElectronics"].items, 4)
    table.insert(ProceduralDistributions.list["StoreShelfElectronics"].items, "Base.Smartphone")
    table.insert(ProceduralDistributions.list["StoreShelfElectronics"].items, 6)
    table.insert(ProceduralDistributions.list["StoreShelfElectronics"].items, "Base.WifiRouter")
    table.insert(ProceduralDistributions.list["StoreShelfElectronics"].items, 5)
end

-- Warehouse/server room spawns
if ProceduralDistributions.list["WarehouseMetalShelf"] then
    table.insert(ProceduralDistributions.list["WarehouseMetalShelf"].items, "Base.ServerRack")
    table.insert(ProceduralDistributions.list["WarehouseMetalShelf"].items, 1)
    table.insert(ProceduralDistributions.list["WarehouseMetalShelf"].items, "Base.NetworkSwitch")
    table.insert(ProceduralDistributions.list["WarehouseMetalShelf"].items, 3)
end

-- Zombie inventory spawns
table.insert(Distributions.Outfit_Business.items, "Base.CellPhone")
table.insert(Distributions.Outfit_Business.items, 5)
table.insert(Distributions.Outfit_Business.items, "Base.Smartphone")
table.insert(Distributions.Outfit_Business.items, 3)

table.insert(Distributions.Outfit_Young.items, "Base.Smartphone")
table.insert(Distributions.Outfit_Young.items, 8)

-- Vehicle glove boxes
if VehicleDistributions.GloveBox then
    table.insert(VehicleDistributions.GloveBox.items, "Base.CellPhone")
    table.insert(VehicleDistributions.GloveBox.items, 4)
    table.insert(VehicleDistributions.GloveBox.items, "Base.PhoneCable")
    table.insert(VehicleDistributions.GloveBox.items, 2)
end
