-- this is a module script
local tools = {}

local FolderPlacement = workspace -- < where you want it to be 

local function validationchecker(_string)
	return type(_string) == "string" and _string:match("^[_%a][_%w]*$") ~= nil
end

local function serialize(_table, indent)
	indent = indent or 0
	local lines = {}
	local padding = string.rep("\t", indent)

	table.insert(lines, "{")

	for key, value in pairs(_table) do
		local formattedkey
		if validationchecker(key) then
			formattedkey = key
		else
			formattedkey = string.format("[%q]", tostring(key))
		end

		if type(value) == "table" then
			table.insert(lines, padding .. "\t" .. formattedkey .. " = " .. serialize(value, indent + 1) .. ",")
		elseif type(value) == "string" then
			table.insert(lines, padding .. "\t" .. formattedkey .. " = " .. string.format("%q", value) .. ",")
		else
			table.insert(lines, padding .. "\t" .. formattedkey .. " = " .. tostring(value) .. ",")
		end
	end

	table.insert(lines, padding .. "}")
	return table.concat(lines, "\n")
end

tools.convert = function(Animations: any)

	if not FolderPlacement:FindFirstChild("Animation") then
		local f = Instance.new("Folder")
		f.Name = "Animation"
		f.Parent = FolderPlacement
	end

	for key, v in pairs(Animations) do

		if type(v) ~= "table" and string.find(v, "rbxasset") then

			local a = Instance.new("Animation")
			a.Name = key
			a.Parent = FolderPlacement.Animation
			a.AnimationId = v

		elseif type(v) == "table" then

			for key1, v1 in pairs(v) do

				if not FolderPlacement.Animation:FindFirstChild(tostring(key)) then
					local Folder = Instance.new("Folder")
					Folder.Name = key
					Folder.Parent = FolderPlacement.Animation
				end

				local AnimFolder = FolderPlacement.Animation:FindFirstChild(tostring(key))

				local a = Instance.new("Animation")
				a.Name = key1
				a.Parent = AnimFolder
				a.AnimationId = v1

			end
		end
	end
end

tools.print = function(AnimationFolder: Folder	)
	local AnimFolder: Folder = AnimationFolder

	local AnimFolderChildren = AnimFolder:GetChildren()
	local Accumulation = {}

	for _, Animation in ipairs(AnimFolderChildren) do
		if not Animation:IsA("Folder") then
			local KeyName = Animation.Name
			Accumulation[KeyName] = Animation.AnimationId
		end
	end

	for _, SubAnimFolder in ipairs(AnimFolderChildren) do
		if SubAnimFolder:IsA("Folder") then

			local SubAnimation = SubAnimFolder:GetChildren()
			Accumulation[SubAnimFolder.Name] = {}

			for _, AnimationA in ipairs(SubAnimation) do
				local key = AnimationA.Name
				Accumulation[SubAnimFolder.Name][key] = AnimationA.AnimationId
			end

		end
	end

	task.defer(function()

		print('Output: ', serialize(Accumulation))

	end)

end

tools.main = function(Animations)
	if type(Animations) == "table" then
		tools.convert(Animations)
		task.defer(function()
			if FolderPlacement:FindFirstChild("Animation") then
				tools.print(FolderPlacement.Animation)
			else
				warn("Missing AnimationFolder", FolderPlacement:FindFirstChild("Animation"))
			end
		end)
	else
		warn("Provided parameter is not a table!!!", Animations)
	end
end

-- Uses in studio command lines

--require(Path to module script).main(Animation Table)

-- Example

--[[

local Animation = {
	
	Key1 = "rbxassetid://0", 
	Key2 = "rbxassetid://0", 
	
	Key3 = {
		Value1 = "rbxassetid://0", 
		Value2 = "rbxassetid://0"
	}, 
	
	Key4 = "rbxassetid://0", 
	Key5 = "rbxassetid://0", 
	
	Key6 = {
		Value1 = "rbxassetid://0", 
		Value2 = "rbxassetid://0", 
		Value3 = "rbxassetid://0"
	}, 
}

-- require(workspace.converter).convert(Animation)
-- require(workspace.converter).print(workspace.Animation)

or

local Animation = { Key1 = "rbxassetid://0", Key2 = "rbxassetid://0", Key3 = { Value1 = "rbxassetid://0", Value2 = "rbxassetid://0" }, Key4 = "rbxassetid://0", Key5 = "rbxassetid://0", Key6 = { Value1 = "rbxassetid://0", Value2 = "rbxassetid://0", Value3 = "rbxassetid://0" }, }; require(workspace.converter).main(Animation)

]]

return tools
