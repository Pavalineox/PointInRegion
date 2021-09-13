local PointInRegion = require(script.Parent.PointInRegion)

local ExampleCode = {
    CurrentRegion = false
}

function ExampleCode:UpdateRegion(NewRegionName)
    self.CurrentRegion = NewRegionName
    --Do other stuff like change music idk
end

function ExampleCode:GetCurrentRegion()
    local PlayerPosition = game.Players.LocalPlayer.Character.PrimaryPart.Position
    local RegionName = PointInRegion:FindRegionNameWithPoint(PlayerPosition)
    if RegionName then
        if self.CurrentRegion ~= RegionName then
            self:UpdateRegion(RegionName)
        end
    else
        self:UpdateRegion(false)
    end
end

return ExampleCode