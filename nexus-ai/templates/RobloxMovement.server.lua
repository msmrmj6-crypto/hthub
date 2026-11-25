-- NEXUS AI starter template
-- Place this Script in ServerScriptService in YOUR OWN Roblox experience.
-- Create a RemoteEvent named "NexusMovementEvent" in ReplicatedStorage.
-- Grant the player the CanUseNexusAbilities attribute from trusted server code.
-- Add a client-side settings UI separately; do not use this in games you do not own.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local event = ReplicatedStorage:WaitForChild("NexusMovementEvent")

local DEFAULT_SPEED = 16
local MAX_SPEED = 32
local DEFAULT_JUMP_POWER = 50
local MAX_JUMP_POWER = 80
local FLY_SPEED = 42

local activeFlight = {}

local function getCharacterParts(player)
	local character = player.Character
	if not character then return nil end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return nil end
	return character, humanoid, root
end

local function stopFlight(player)
	local record = activeFlight[player]
	if not record then return end
	if record.velocity and record.velocity.Parent then record.velocity:Destroy() end
	if record.attachment and record.attachment.Parent then record.attachment:Destroy() end
	activeFlight[player] = nil
end

local function startFlight(player)
	local _, humanoid, root = getCharacterParts(player)
	if not humanoid or not root then return end
	stopFlight(player)

	local attachment = Instance.new("Attachment")
	attachment.Name = "NexusFlightAttachment"
	attachment.Parent = root

	local velocity = Instance.new("LinearVelocity")
	velocity.Name = "NexusFlightVelocity"
	velocity.Attachment0 = attachment
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.VectorVelocity = Vector3.zero
	velocity.MaxForce = 50000
	velocity.Parent = root

	humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	activeFlight[player] = { attachment = attachment, velocity = velocity }
end

local function validDirection(value)
	if typeof(value) ~= "Vector3" then return false end
	if value.X ~= value.X or value.Y ~= value.Y or value.Z ~= value.Z then return false end
	return value.Magnitude <= 1.05
end

event.OnServerEvent:Connect(function(player, action, value)
	-- Server-side permission check: never trust a client-only toggle.
	if player:GetAttribute("CanUseNexusAbilities") ~= true then return end

	local _, humanoid = getCharacterParts(player)
	if not humanoid then return end

	if action == "SetSpeed" then
		local speed = tonumber(value)
		if not speed or speed ~= speed then return end
		humanoid.WalkSpeed = math.clamp(speed, DEFAULT_SPEED, MAX_SPEED)

	elseif action == "SetJump" then
		local jumpPower = tonumber(value)
		if not jumpPower or jumpPower ~= jumpPower then return end
		humanoid.UseJumpPower = true
		humanoid.JumpPower = math.clamp(jumpPower, DEFAULT_JUMP_POWER, MAX_JUMP_POWER)

	elseif action == "Flight" then
		if value == true then
			startFlight(player)
		elseif value == false then
			stopFlight(player)
		end

	elseif action == "FlightDirection" then
		if not validDirection(value) then return end
		local record = activeFlight[player]
		if record and record.velocity and record.velocity.Parent then
			local direction = value.Magnitude > 1 and value.Unit or value
			record.velocity.VectorVelocity = direction * FLY_SPEED
		end
	end
end)

local function resetPlayer(player)
	stopFlight(player)
	local _, humanoid = getCharacterParts(player)
	if humanoid then
		humanoid.WalkSpeed = DEFAULT_SPEED
		humanoid.UseJumpPower = true
		humanoid.JumpPower = DEFAULT_JUMP_POWER
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		resetPlayer(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	stopFlight(player)
end)
