--[=[
	@class HideAndSeek
]=]

local Players = game:GetService("Players")

local Maid = require("@pkgs/maid")
local UIManager = require("@classes/UIManager")

local HideAndSeek = {}
HideAndSeek.__index = HideAndSeek

export type Fields = {
    _UIManager: UIManager.UIManager,
	_Maid: Maid.Maid,
    _ESP: any
}

export type HideAndSeek = typeof(setmetatable({} :: Fields, HideAndSeek))

function HideAndSeek.new(UIManager: UIManager.UIManager): HideAndSeek
    local self = setmetatable({}, HideAndSeek)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    -- Credits to Kiriot for the ESP lib
    self._ESP = require("@libraries/KiriotESP")
    
    return self
end

function HideAndSeek.Start(self: HideAndSeek)
    local ROLES_DATA = {
        IsHider = {Name = "Hider", Color = Color3.fromRGB(0, 255, 230), Flag = "Hiders"},
        IsHunter = {Name = "Hunter", Color = Color3.fromRGB(251, 0, 0), Flag = "Hunters"}
    }

    local Client = Players.LocalPlayer
    local BoxObjects: {any} = {}

    local function OnPlayerAdded(Player: Player)
        if Player == Client then return end
        
        local PlayerMaid: Maid.Maid = Maid.new()
        self._Maid:GiveTask(PlayerMaid)

        local CharacterMaid: Maid.Maid = Maid.new()
        PlayerMaid:GiveTask(CharacterMaid)
        
        local function OnCharacterAdded(Character: Model)
            CharacterMaid:DoCleaning()
            local RootPart = Character:WaitForChild("HumanoidRootPart")
            
            local function OnRoleAdded(Role)
                local RoleData = ROLES_DATA[Role]

                table.insert(BoxObjects, self._ESP:Add(Character, {
                    Name = "Role: " .. RoleData.Name .. " | " .. "Player Name: " .. Player.Name,
                    Color = RoleData.Color,
                    PrimaryPart = RootPart,
                    IsEnabled = RoleData.Flag,
                }))
            end

            for _, Attribute in ipairs({"IsHider", "IsHunter"}) do
                CharacterMaid:GiveTask(Player:GetAttributeChangedSignal(Attribute):Connect(function()
                    if Player:GetAttribute(Attribute) ~= true then return end
                    OnRoleAdded(Attribute)
                end))
                if Player:GetAttribute(Attribute) == true then
                    task.spawn(OnRoleAdded, Attribute)
                end
            end
        end

        PlayerMaid:GiveTask(Player.AncestryChanged:Connect(function(_, NewParent)
            if NewParent then return end
            PlayerMaid:Destroy()
        end))

        PlayerMaid:GiveTask(Player.CharacterAdded:Connect(OnCharacterAdded))
        if Player.Character then
            task.spawn(OnCharacterAdded, Player.Character)
        end
    end
    
    self._Maid:GiveTask(Players.PlayerAdded:Connect(OnPlayerAdded))
    for _, Player in ipairs(Players:GetPlayers()) do
        task.spawn(OnPlayerAdded, Player)
    end
    
    self._UIManager.Toggles.HiderESP:OnChanged(function() 
        self._ESP.Hiders = self._UIManager:GetToggleValue("HiderESP")
    end)

    self._UIManager.Toggles.HunterESP:OnChanged(function() 
        self._ESP.Hunters = self._UIManager:GetToggleValue("HunterESP")
    end)

    self._Maid:GiveTask(function()
        for _, Box in ipairs(BoxObjects) do
            Box:Remove()
        end
        table.clear(BoxObjects)

        self._ESP:Toggle(false)

        self._UIManager.Toggles.HiderESP:OnChanged(function() end)
        self._UIManager.Toggles.HunterESP:OnChanged(function() end)
    end)
   
    self._ESP.Players = true
    self._ESP:Toggle(true)

    warn("HideAndSeek feature started!")
end

function HideAndSeek.Destroy(self: HideAndSeek)
    warn("HideAndSeek feature destroyed!")
    self._Maid:Destroy()
end

return HideAndSeek