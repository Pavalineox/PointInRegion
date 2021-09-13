--Feel free to change these requires i just edited it so it works without our framework
--Useful functions are WindingNumberTest / CheckIfPointInRegion
local RegionList = require(script.Parent.RegionList)

local RegionFolder = game.ReplicatedFirst.RegionFolder

local PointInRegion = {}

PointInRegion.RegionTable = {}

function PointInRegion:GenerateRegionTable()
	for _,RegionDataFolder in pairs (RegionFolder:GetChildren()) do
		RegionList[RegionDataFolder.Name] = {}
		local VectorPositionData = {}
		local ObjectCounter = 0
		local PartYPosition = false
		for Index, Part in pairs(RegionDataFolder:GetChildren()) do
			if Part.ClassName == "Part" then 
				if not PartYPosition then PartYPosition = Part.Position.Y end
				ObjectCounter = ObjectCounter + 1
			end
		end
		for Count = 1, ObjectCounter do
			for Index, Part in pairs(RegionDataFolder:GetChildren()) do
				if Part.ClassName == "Part" then 
					if Part.Name == tostring(Count) then
						VectorPositionData[Count] = Vector2.new(Part.Position.X, Part.Position.Z)
					end
				end
			end
		end
		VectorPositionData[ObjectCounter + 1] = VectorPositionData[1]
		PointInRegion.RegionTable[RegionDataFolder.Name] = VectorPositionData
		for Index, Property in pairs(RegionDataFolder.PropertyFolder:GetChildren()) do
			RegionList[RegionDataFolder.Name][Property.Name] = Property.Value
		end
		RegionList[RegionDataFolder.Name]["RegionHeight"] = PartYPosition
	end
end

function PointInRegion:CheckIfPointInRegion(Position, RegionName)
	if PointInRegion.RegionTable[RegionName] then
		return PointInRegion:WindingNumberTest(Vector2.new(Position.X, Position.Z), PointInRegion.RegionTable[RegionName])
	else
		print("Error, Region Not Found")
	end
end

function PointInRegion:GetCentroidOfRegion(RegionName)
	local CalcPosition = Vector3.new()
	for _,Vertex in pairs(PointInRegion.RegionTable[RegionName]) do
		CalcPosition = CalcPosition + Vector3.new(Vertex.X,0,Vertex.Y)
	end
	CalcPosition = Vector3.new(CalcPosition.X,self:GetRegionPropertiesFromName(RegionName)["RegionHeight"],CalcPosition.Z)
	return (CalcPosition / Vector3.new(#PointInRegion.RegionTable[RegionName],1,#PointInRegion.RegionTable[RegionName]))
end

function PointInRegion:FindRegionNameWithPoint(Position)
	debug.profilebegin("GetRegionFromPosition")
	local CurrentRegionName = false
	local CurrentRegionPriority = -1
	for RegionName,RegionTable in pairs(self.RegionTable) do
		local RegionProperties = self:GetRegionPropertiesFromName(RegionName)
		if not RegionProperties.IgnoreAsPlayerRegion then
			if RegionProperties.RegionPriority > CurrentRegionPriority then
				local IsInRegion = self:CheckIfPointInRegion(Position, RegionName)
				if IsInRegion then 
					CurrentRegionName = RegionName
					CurrentRegionPriority = RegionProperties.RegionPriority
				end
			end
		end
	end
	debug.profileend()
	return CurrentRegionName
end

function PointInRegion:GetRegionPropertiesFromName(RegionName)
	return RegionList[RegionName]
end

function PointInRegion:IsLeft(P0, P1, P2)
	return ((P1.X - P0.X) * (P2.Y - P0.Y) - (P2.X - P0.X) * (P1.Y -P0.Y))
end

function PointInRegion:CrossNumberPoly(Point, VertexList)
	local CrossNumber = 0.0
	for i, v in pairs(VertexList) do
		if VertexList[i] and VertexList[i+1] then
			if (VertexList[i].Y <= Point.Y and VertexList[i+1].Y > Point.Y) or (VertexList[i].Y > Point.Y and VertexList[i+1].Y <= Point.Y) then
				local IntCoord = (Point.Y - VertexList[i].Y) / (VertexList[i+1].Y - VertexList[i].Y)
				if (Point.X < VertexList[i].X + IntCoord * (VertexList[i+1].X - VertexList[i].X)) then
					CrossNumber = CrossNumber + 1
				end
			end
		end
	end
	return CrossNumber % 2 == 0
end

function PointInRegion:WindingNumberTest(Point, VertexList)
	local WindingNumber = 0
	for i, v in pairs (VertexList) do
		if VertexList[i] and VertexList[i+1] then
			if (VertexList[i].Y <= Point.Y) then
				if VertexList[i+1].Y > Point.Y then
					if (self:IsLeft(VertexList[i], VertexList[i+1], Point) > 0) then
						WindingNumber = WindingNumber + 1
					end
				end
			else
				if VertexList[i+1].Y <= Point.Y then
					if  (self:IsLeft(VertexList[i], VertexList[i+1], Point) < 0) then
						WindingNumber = WindingNumber - 1
					end
				end
			end
		end
	end
	if WindingNumber == 0 then
		return false
	else
		return true
	end
end

PointInRegion:GenerateRegionTable()

return PointInRegion