--[=[
	@class Mingle
]=]

local Players = game:GetService("Players")

local Maid = require("@pkgs/maid")
local UIManager = require("@classes/UIManager")

local Mingle = {}
Mingle.__index = Mingle

export type Fields = {
    _UIManager: UIManager.UIManager,
	_Maid: Maid.Maid
}

export type Mingle = typeof(setmetatable({} :: Fields, Mingle))

function Mingle.new(UIManager: UIManager.UIManager): Mingle
    local self = setmetatable({}, Mingle)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    return self
end

function Mingle.Start(self: Mingle)
    local Client = Players.LocalPlayer

    local CharacterMaid: Maid.Maid = Maid.new()
    self._Maid:GiveTask(CharacterMaid)

    local function OnCharacterAdded(Character: Model)
        CharacterMaid:DoCleaning()

        local function OnRemoteForQTEAdded(RemoteForQTE: RemoteEvent)
            CharacterMaid:GiveTask(task.spawn(function()
                while task.wait(0.5) do
                    if not RemoteForQTE then break end
                    if not RemoteForQTE.Parent then break end

                    if self._UIManager:GetToggleValue("MinglePowerHoldAuto") then
                        RemoteForQTE:FireServer()
                    end
                end
            end))
        end

        local function OnChildAdded(Object: Instance)
            if Object.ClassName == "RemoteEvent" and Object.Name == "RemoteForQTE" then
                OnRemoteForQTEAdded(Object :: RemoteEvent)
            end
        end

        CharacterMaid:GiveTask(Character.ChildAdded:Connect(OnChildAdded))
        for _, Object in ipairs(Character:GetChildren()) do
            task.spawn(OnChildAdded, Object)
        end
    end

    self._Maid:GiveTask(Client.CharacterAdded:Connect(OnCharacterAdded))
    if Client.Character then
        task.spawn(OnCharacterAdded, Client.Character)
    end

    warn("Mingle feature started!")
end

function Mingle.Destroy(self: Mingle)
    warn("Mingle feature destroyed!")
    self._Maid:Destroy()
end

return Mingle