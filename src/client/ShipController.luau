-- ShipController
-- Handles ship movement and animation (client-side)

local ShipController = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local InputController = require(script.Parent:WaitForChild("InputController"))
local BoardingController = require(script.Parent:WaitForChild("BoardingController"))
local ShipConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ShipConfig"))

local player = Players.LocalPlayer
local currentShip = nil
local renderCFrame = nil
local baseRotation = nil
local currentYaw = 0
local currentPitchTilt = 0
local currentRollTilt = 0
local currentAimPitch = 0
local shipVelocity = Vector3.new(0, 0, 0) -- Track ship velocity
local flightDirection = nil
local facingDirection = nil
local hasStarted = false
local camera = workspace.CurrentCamera
local wasBoostPressed = false
local boostCooldownRemaining = 0
local boostTimeRemaining = 0
local boostDirection = nil

local function hasUsableShipPart(ship)
	if ship:IsA("BasePart") then
		return true
	end

	return ship:FindFirstChildWhichIsA("BasePart", true) ~= nil
end

local function getShipCFrame(ship)
	if ship:IsA("Model") then
		return ship:GetPivot()
	end

	return ship.CFrame
end

local function getCameraMovementAxes()
	local look = camera.CFrame.LookVector
	local forward = Vector3.new(look.X, 0, look.Z)
	if forward.Magnitude < 0.01 then
		forward = Vector3.new(0, 0, -1)
	else
		forward = forward.Unit
	end

	local right = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
	if right.Magnitude < 0.01 then
		right = Vector3.new(1, 0, 0)
	else
		right = right.Unit
	end

	return forward, right
end

local function getYawFromDirection(direction)
	return math.atan2(-direction.X, -direction.Z)
end

local function getDirectionFromYaw(yaw)
	return Vector3.new(-math.sin(yaw), 0, -math.cos(yaw))
end

local function getDirectionFromYawPitch(yaw, pitch)
	local horizontal = math.cos(pitch)
	return Vector3.new(
		-math.sin(yaw) * horizontal,
		math.sin(pitch),
		-math.cos(yaw) * horizontal
	)
end

-- Wait for and get the ship
local function getShip()
	-- Keep trying to find the ship (server spawns it after character loads)
	local attempts = 0
	while not currentShip and attempts < 100 do
		-- Look for any ship model in workspace
		for _, obj in ipairs(workspace:GetChildren()) do
			-- Check if this object is a ship (has Owner tag)
			if obj:FindFirstChild("Owner") then
				local ownerValue = obj:FindFirstChild("Owner")
				if ownerValue and ownerValue.Value == player.UserId and hasUsableShipPart(obj) then
					currentShip = obj
					break
				end
			end
		end
		
		if not currentShip then
			wait(0.1)
			attempts = attempts + 1
		end
	end
	
	if currentShip then
	else
		warn("Could not find ship!")
	end
end

-- Update ship position and rotation based on input
local function updateShip(input, deltaTime)
	if not currentShip or not currentShip.Parent then return end
	
	-- Only move ship if player is boarded
	if not BoardingController:IsBoarded() then
		return
	end
	
	local config = ShipConfig:GetDefaultShip()
	local cframe = renderCFrame or getShipCFrame(currentShip)
	local position = cframe.Position
	local up = Vector3.new(0, 1, 0)
	local lookDelta = InputController:ConsumeLookDelta()

	currentYaw -= (input.moveX * config.turnSpeed * deltaTime)
		+ (lookDelta.X * (config.mouseYawSensitivity or 0.0035))
		+ ((input.lookX or 0) * (config.controllerYawSpeed or 2.8) * deltaTime)
	currentAimPitch = math.clamp(
		currentAimPitch
			- lookDelta.Y * (config.mousePitchSensitivity or 0.0025)
			+ ((input.lookY or 0) * (config.controllerPitchSpeed or 2) * deltaTime),
		-(config.maxCameraPitch or math.rad(28)),
		config.maxCameraPitch or math.rad(28)
	)
	facingDirection = getDirectionFromYawPitch(currentYaw, currentAimPitch)

	boostCooldownRemaining = math.max(boostCooldownRemaining - deltaTime, 0)
	if input.boost and not wasBoostPressed and boostCooldownRemaining <= 0 then
		boostDirection = facingDirection
		boostTimeRemaining = config.boostDashDuration or 0.25
		boostCooldownRemaining = config.boostCooldown or 1.25
	end
	wasBoostPressed = input.boost

	local forwardMultiplier = input.moveZ < 0 and (config.forwardSpeedMultiplier or 1) or 1
	local backwardMultiplier = input.moveZ > 0 and (config.backwardSpeedMultiplier or 1) or 1

	-- Convert input to world space velocity
	local movement = (
		(up * input.pitch) +
		(facingDirection * -input.moveZ * forwardMultiplier * backwardMultiplier)
	)

	local desiredVelocity = movement * config.maxSpeed
	if boostTimeRemaining > 0 and boostDirection then
		local dashSpeed = (config.boostDashDistance or 35) / (config.boostDashDuration or 0.25)
		desiredVelocity += boostDirection * dashSpeed
		boostTimeRemaining = math.max(boostTimeRemaining - deltaTime, 0)
	end

	-- Smooth acceleration
	local accelerationAlpha = math.clamp(deltaTime * config.acceleration / 50, 0, 1)
	shipVelocity = shipVelocity:Lerp(desiredVelocity, accelerationAlpha)

	-- Update position
	local newPosition = position + shipVelocity * deltaTime

	local horizontalVelocity = Vector3.new(shipVelocity.X, 0, shipVelocity.Z)
	flightDirection = horizontalVelocity.Magnitude > 0.5 and horizontalVelocity.Unit or facingDirection

	local newCFrame = cframe - cframe.Position + newPosition
	if baseRotation then
		local tiltAlpha = math.clamp(deltaTime * (config.tiltResponsiveness or 8), 0, 1)
		local targetPitchTilt = input.moveZ * (config.maxPitchTilt or math.rad(8))
		local targetRollTilt = -input.moveX * (config.maxRollTilt or math.rad(12))

		currentPitchTilt += (targetPitchTilt - currentPitchTilt) * tiltAlpha
		currentRollTilt += (targetRollTilt - currentRollTilt) * tiltAlpha

		newCFrame = CFrame.new(newPosition)
			* CFrame.Angles(0, currentYaw + (config.visualForwardYawOffset or 0), 0)
			* CFrame.Angles(currentAimPitch + currentPitchTilt, 0, currentRollTilt)
			* baseRotation
	end

	renderCFrame = newCFrame
	currentShip:PivotTo(newCFrame)
end

-- Main update loop
local function update(deltaTime)
	if currentShip and currentShip.Parent then
		updateShip(InputController.inputState, deltaTime)
	end
end

-- Start the ship controller
function ShipController:Start()
	if hasStarted then
		return
	end
	hasStarted = true

	getShip()
	
	if currentShip then
		renderCFrame = getShipCFrame(currentShip)
		baseRotation = renderCFrame - renderCFrame.Position
		facingDirection = select(1, getCameraMovementAxes())
		currentYaw = getYawFromDirection(facingDirection)
		currentPitchTilt = 0
		currentRollTilt = 0
		currentAimPitch = 0
		-- Start the update loop
		RunService:BindToRenderStep("FlyFightShipMovement", Enum.RenderPriority.Input.Value, update)
	else
		warn("ShipController failed to start - no ship found")
	end
end

-- Get the current ship
function ShipController:GetShip()
	return currentShip
end

function ShipController:GetRenderCFrame()
	return renderCFrame or (currentShip and getShipCFrame(currentShip)) or nil
end

function ShipController:GetFlightDirection()
	return flightDirection
end

function ShipController:GetFacingDirection()
	return facingDirection
end

function ShipController:GetCameraTarget()
	local cframe = self:GetRenderCFrame()
	if not cframe then
		return nil, nil
	end

	return cframe.Position, facingDirection, currentAimPitch
end

return ShipController
