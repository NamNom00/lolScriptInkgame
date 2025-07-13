--[=[
	@class TugOfWar
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require("@pkgs/maid")
local UIManager = require("@classes/UIManager")

local TugOfWar = {}
TugOfWar.__index = TugOfWar

export type Fields = {
    _UIManager: UIManager.UIManager,
	_Maid: Maid.Maid
}

export type TugOfWar = typeof(setmetatable({} :: Fields, TugOfWar))

function TugOfWar.new(UIManager: UIManager.UIManager): TugOfWar
    local self = setmetatable({}, TugOfWar)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    return self
end

function TugOfWar.Start(self: TugOfWar)
    local TemporaryReachedBindableRemote = ReplicatedStorage.Remotes.TemporaryReachedBindable
    
    local PULL_RATE = 0.025
    local VALID_PULL_DATA = {
        ["PerfectQTE"] = true
    }

    self._Maid:GiveTask(task.spawn(function()
        while task.wait(PULL_RATE) do
            if self._UIManager:GetToggleValue("TugOfWarAuto") then
                TemporaryReachedBindableRemote:FireServer(VALID_PULL_DATA)
            end
        end
    end))

    warn("TugOfWar feature started!")
end

function TugOfWar.Destroy(self: TugOfWar)
    warn("TugOfWar feature destroyed!")
    self._Maid:Destroy()
end

return TugOfWar