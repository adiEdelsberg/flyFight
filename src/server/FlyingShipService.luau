-- FlyingShipService
-- Handles ship spawning, management, and destruction (server-side)

local FlyingShipService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ShipConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ShipConfig"))

-- Keep track of player ships
local playerShips = {}

local function destroyOwnedShipsInWorkspace(player)
	for _, obj in ipairs(workspace:GetChildren()) do
		local ownerTag = obj:FindFirstChild("Owner", true)
		if ownerTag and ownerTag:IsA("NumberValue") and ownerTag.Value == player.UserId then
			obj:Destroy()
		end
	end
end

local function isUsableShipPart(part)
	return part:IsA("BasePart") and part.CanQuery and part.Transparency < 1
end

local function findShipPart(ship)
	if ship:IsA("BasePart") and isUsableShipPart(ship) then
		return ship
	end

	if ship:IsA("Model") and ship.PrimaryPart and isUsableShipPart(ship.PrimaryPart) then
		return ship.PrimaryPart
	end

	for _, descendant in ipairs(ship:GetDescendants()) do
		if isUsableShipPart(descendant) then
			return descendant
		end
	end

	return ship:FindFirstChildWhichIsA("BasePart", true)
end

local function getShipBottomOffset(ship)
	if ship:IsA("Model") then
		local boundingCFrame, boundingSize = ship:GetBoundingBox()
		return (boundingCFrame.Position.Y - (boundingSize.Y / 2)) - ship:GetPivot().Position.Y
	end

	if ship:IsA("BasePart") then
		return -ship.Size.Y / 2
	end

	return 0
end

local function createShipModel(asset)
	local clone = asset:Clone()

	if clone:IsA("Model") and clone:FindFirstChildOfClass("BasePart") then
		return clone
	end

	local modelChild = clone:FindFirstChildOfClass("Model")
	if modelChild then
		modelChild.Parent = nil
		clone:Destroy()
		return modelChild
	end

	local shipModel = Instance.new("Model")
	shipModel.Name = clone.Name

	if clone:IsA("BasePart") then
		clone.Parent = shipModel
	else
		for _, child in ipairs(clone:GetChildren()) do
			child.Parent = shipModel
		end
		clone:Destroy()
	end

	return shipModel
end

local function getSpawnPosition(player, config)
	local spawnPosition = config.spawnPosition or Vector3.new(0, 0, 0)
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not rootPart then
		return spawnPosition
	end

	local forward = Vector3.new(rootPart.CFrame.LookVector.X, 0, rootPart.CFrame.LookVector.Z)
	if forward.Magnitude <= 0 then
		return spawnPosition
	end

	return rootPart.Position + forward.Unit * (config.spawnForwardOffset or 14)
end

local function placeShipOnFloor(ship, player, config)
	local spawnPosition = getSpawnPosition(player, config)
	local groundY = config.spawnGroundY or 0
	local clearance = config.spawnGroundClearance or 0
	local bottomOffset = getShipBottomOffset(ship)
	local pivotY = groundY + clearance - bottomOffset
	local currentPivot = ship:GetPivot()
	local rotation = currentPivot - currentPivot.Position

	ship:PivotTo(CFrame.new(spawnPosition.X, pivotY, spawnPosition.Z) * rotation)
end

-- Spawn a ship for a player
function FlyingShipService:SpawnShip(player, shipName)
	if not player or not player.Parent then
		return nil
	end
	
	-- If player already has a ship, destroy it
	if playerShips[player.UserId] then
		self:DestroyShip(player)
	end
	destroyOwnedShipsInWorkspace(player)
	
	-- Get ship config
	local config = ShipConfig:GetShip(shipName or "FrogShip")
	if not config then
		warn("Ship config not found: " .. tostring(shipName))
		return nil
	end
	
	-- Find the asset location
	local assetParts = string.split(config.assetPath, "/")
	local asset = game
	for _, part in ipairs(assetParts) do
		asset = asset:FindFirstChild(part)
		if not asset then
			warn("Asset not found: " .. config.assetPath)
			return nil
		end
	end
	
	-- Clone the ship into a Model so clients can rely on PrimaryPart.
	local ship = createShipModel(asset)
	
	local firstPart = findShipPart(ship)
	if not firstPart then
		return nil
	end
	
	ship.PrimaryPart = firstPart
	
	-- Anchor all parts so CFrame manipulation works without physics fighting
	for _, part in ipairs(ship:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	-- Place the ship so its visible bottom rests on the floor even if its pivot is offset.
	placeShipOnFloor(ship, player, config)

	-- Tag ship with player for hit detection (use NumberValue for proper type)
	local ownerTag = Instance.new("NumberValue")
	ownerTag.Name = "Owner"
	ownerTag.Value = player.UserId
	ownerTag.Parent = ship

	ship.Parent = workspace

	-- Store ship reference
	playerShips[player.UserId] = ship
	
	return ship
end

-- Destroy a player's ship
function FlyingShipService:DestroyShip(player)
	if not playerShips[player.UserId] then
		return
	end
	
	local ship = playerShips[player.UserId]
	playerShips[player.UserId] = nil
	
	if ship and ship.Parent then
		ship:Destroy()
	end
	destroyOwnedShipsInWorkspace(player)
end

-- Get a player's current ship
function FlyingShipService:GetPlayerShip(player)
	return playerShips[player.UserId]
end

-- Respawn a player's ship
function FlyingShipService:RespawnShip(player)
	local config = ShipConfig:GetDefaultShip()
	wait(config.respawnDelay)
	self:SpawnShip(player, "FrogShip")
end

-- Clean up on player leave
Players.PlayerRemoving:Connect(function(player)
	if playerShips[player.UserId] then
		FlyingShipService:DestroyShip(player)
	end
end)

return FlyingShipService
