--[=[
	@class RedLightGreenLight
]=]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require("@pkgs/maid")
local UIManager = require("@classes/UIManager")

local RedLightGreenLight = {}
RedLightGreenLight.__index = RedLightGreenLight

export type Fields = {
    _UIManager: UIManager.UIManager,
	_Maid: Maid.Maid,
    _IsGreenLight: boolean?,
    _LastRootPartCFrame: CFrame?
}

export type RedLightGreenLight = typeof(setmetatable({} :: Fields, RedLightGreenLight))

function RedLightGreenLight.new(UIManager: UIManager.UIManager): RedLightGreenLight
    local self = setmetatable({}, RedLightGreenLight)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    return self
end

function RedLightGreenLight.Start(self: RedLightGreenLight)
    local Client = Players.LocalPlayer
    local PlayerGui = Client:WaitForChild("PlayerGui")

    local TrafficLightImage = PlayerGui:WaitForChild("ImpactFrames"):WaitForChild("TrafficLightEmpty") :: ImageLabel

    self._IsGreenLight = TrafficLightImage.Image == ReplicatedStorage.Effects.Images.TrafficLights.GreenLight.Image

    local RootPart = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
    self._LastRootPartCFrame = RootPart and RootPart.CFrame
    
    self._Maid:GiveTask(ReplicatedStorage.Remotes.Effects.OnClientEvent:Connect(function(EffectsData)
        if EffectsData.EffectName ~= "TrafficLight" then return end

        self._IsGreenLight = EffectsData.GreenLight == true

        local RootPart = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
        self._LastRootPartCFrame = RootPart and RootPart.CFrame
    end))

    local OriginalNamecall
    OriginalNamecall = hookfunction(getrawmetatable(game).__namecall, newcclosure(function(Instance, ...)
        local Args = {...}

        if getnamecallmethod() == "FireServer" and Instance.ClassName == "RemoteEvent" and Instance.Name == "rootCFrame" then
            if self._UIManager:GetToggleValue("RedLightGodMode") and self._IsGreenLight == false and self._LastRootPartCFrame then
                -- Send cached CFrame data when it's red light
                Args[1] = self._LastRootPartCFrame
                return OriginalNamecall(Instance, unpack(Args))
            end
        end

        return OriginalNamecall(Instance, ...)
    end))

    self._Maid:GiveTask(function()
        hookfunction(getrawmetatable(game).__namecall, OriginalNamecall)
    end)

    warn("RLGL feature started!")
end

function RedLightGreenLight.Destroy(self: RedLightGreenLight)
    warn("RLGL feature destroyed!")
    self._Maid:Destroy()
end

return RedLightGreenLight