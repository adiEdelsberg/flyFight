-- ShipConfig
-- Defines all ship configurations (shared between client and server)

local ShipConfig = {}

-- FrogShip Configuration
ShipConfig.FrogShip = {
	name = "FrogShip",
	assetPath = "ReplicatedStorage/Assets/Ships/FrogShip",
	
	-- Flight properties
	maxSpeed = 50,
	forwardSpeedMultiplier = 1.35,
	backwardSpeedMultiplier = 0.65,
	acceleration = 150,
	turnSpeed = 2.5,
	visualForwardYawOffset = 0,
	maxPitchTilt = math.rad(8),
	maxRollTilt = math.rad(12),
	tiltResponsiveness = 8,
	
	-- Vertical movement
	ascendSpeed = 30,
	descendSpeed = 30,
	
	-- Boost
	boostSpeed = 100,
	boostDuration = 1,
	boostCooldown = 2,
	
	-- Combat
	health = 1, -- One hit = one kill
	
	-- Respawn
	respawnDelay = 1.5,

	-- Spawn placement
	spawnPosition = Vector3.new(0, 0, 0),
	spawnForwardOffset = 14,
	spawnGroundY = 0,
	spawnGroundClearance = 0.25,
}

-- Get config by ship name
function ShipConfig:GetShip(shipName)
	return self[shipName]
end

-- Get default ship (for MVP)
function ShipConfig:GetDefaultShip()
	return self.FrogShip
end

return ShipConfig
