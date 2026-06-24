-- CameraController
-- Handles camera following the ship (client-side)

local CameraController = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local BoardingController = require(script.Parent:WaitForChild("BoardingController"))

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local currentShip = nil
local wasBoarded = false
local lastFollowDirection = Vector3.new(0, 0, -1)
local targetProvider = nil

-- Camera settings
local CAMERA_DISTANCE = 30  -- How far behind the ship
local CAMERA_HEIGHT = 10    -- How far above the ship
local CAMERA_SMOOTHING = 0.6  -- How smooth the camera follows (0-1)

-- Set the ship to follow
function CameraController:SetShip(ship)
	currentShip = ship
end

function CameraController:SetTargetProvider(provider)
	targetProvider = provider
end

local function getShipCFrame(ship)
	if ship:IsA("Model") then
		return ship:GetPivot()
	end

	return ship.CFrame
end

local function getFallbackFollowDirection(shipCFrame)
	local direction = Vector3.new(-shipCFrame.ZVector.X, 0, -shipCFrame.ZVector.Z)
	if direction.Magnitude < 0.01 then
		return lastFollowDirection
	end

	lastFollowDirection = direction.Unit
	return lastFollowDirection
end

-- Update camera position to follow ship
local function updateCamera()
	local isBoarded = BoardingController:IsBoarded()
	if not isBoarded then
		wasBoarded = false
		return
	end

	if not currentShip or not currentShip.Parent then return end

	local shipPos = nil
	local followDirection = nil

	if targetProvider then
		shipPos, followDirection = targetProvider()
	end

	if not shipPos or not followDirection then
		local shipCFrame = getShipCFrame(currentShip)
		shipPos = shipCFrame.Position
		followDirection = getFallbackFollowDirection(shipCFrame)
	end

	if followDirection.Magnitude < 0.01 then
		followDirection = lastFollowDirection
	else
		local flatDirection = Vector3.new(followDirection.X, 0, followDirection.Z)
		if flatDirection.Magnitude < 0.01 then
			followDirection = lastFollowDirection
		else
			followDirection = flatDirection.Unit
			lastFollowDirection = followDirection
		end
	end
	
	-- Calculate desired camera position (behind and above the ship)
	local desiredCameraPos = shipPos - followDirection * CAMERA_DISTANCE + Vector3.new(0, CAMERA_HEIGHT, 0)
	local desiredCameraFocus = shipPos + followDirection * 8 + Vector3.new(0, 5, 0)
	
	-- Smoothly move camera
	local currentCameraPos = camera.CFrame.Position
	local smoothing = wasBoarded and CAMERA_SMOOTHING or 1
	local newCameraPos = currentCameraPos:Lerp(desiredCameraPos, smoothing)
	
	-- Create new camera CFrame looking at the ship
	camera.CFrame = CFrame.lookAt(newCameraPos, desiredCameraFocus)
	wasBoarded = true
end

-- Start camera update loop
function CameraController:Start()
	RunService:BindToRenderStep("FlyFightCamera", Enum.RenderPriority.Camera.Value + 1, function()
		if BoardingController:IsBoarded() and camera.CameraType ~= Enum.CameraType.Scriptable then
			camera.CameraType = Enum.CameraType.Scriptable
		end
		updateCamera()
	end)
end

return CameraController
