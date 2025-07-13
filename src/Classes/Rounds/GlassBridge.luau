--[=[
	@class GlassBridge
]=]

local Maid = require("@pkgs/maid")
local UIManager = require("@classes/UIManager")

local GlassBridge = {}
GlassBridge.__index = GlassBridge

export type Fields = {
    _UIManager: UIManager.UIManager,
	_Maid: Maid.Maid,
}

export type GlassBridge = typeof(setmetatable({} :: Fields, GlassBridge))

function GlassBridge.new(UIManager: UIManager.UIManager): GlassBridge
    local self = setmetatable({}, GlassBridge)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    return self
end

function GlassBridge.Start(self: GlassBridge)
    local GlassHolder = workspace.GlassBridge.GlassHolder :: Model

    local function SetupGlassPart(GlassPart: BasePart)
        local CanEnableGlassBridgeESP = self._UIManager:GetToggleValue("GlassBridgeESP")
        if not CanEnableGlassBridgeESP then
            GlassPart.Color = Color3.fromRGB(106, 106, 106)
            GlassPart.Transparency = 0.45
            GlassPart.Material = Enum.Material.SmoothPlastic
        else
            -- Game owner is quite funny (may be a honeypot) :skull:
            local Color = GlassPart:GetAttribute("exploitingisevil") and Color3.fromRGB(248, 87, 87) or Color3.fromRGB(28, 235, 87)
            GlassPart.Color = Color
            GlassPart.Transparency = 0
            GlassPart.Material = Enum.Material.Neon
        end
    end
    
    self._UIManager.Toggles.GlassBridgeESP:OnChanged(function()
        for _, PanelPair in ipairs(GlassHolder:GetChildren()) do
            for _, Panel in ipairs(PanelPair:GetChildren()) do
                local GlassPart = Panel:FindFirstChild("glasspart") :: BasePart?
                if GlassPart then
                    task.defer(SetupGlassPart, GlassPart)
                end
            end
        end
    end)

    self._Maid:GiveTask(GlassHolder.DescendantAdded:Connect(function(Descendant: Instance)
        if Descendant.Name == "glasspart" and Descendant:IsA("BasePart") then
            task.defer(SetupGlassPart, Descendant)
        end
    end))

    self._Maid:GiveTask(function()
        self._UIManager.Toggles.GlassBridgeESP:OnChanged(function() end)
    end)

    warn("GlassBridge feature started!")
end

function GlassBridge.Destroy(self: GlassBridge)
    warn("GlassBridge feature destroyed!")
    self._Maid:Destroy()
end

return GlassBridge