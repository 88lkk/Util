------------------------------
-- Setup + Fixes
------------------------------

local Env = getfenv()
local cloneref = cloneref or function(Inst) return Inst end

if Env["88llkUtil"] then return end
Env["88llkUtil"] = 1

------------------------------
-- Services
------------------------------

for _, Serv in {
	"CoreGui",
	"TweenService",
	"UserInputService",
	"ReplicatedStorage",
	"Players",
	"RunService",
	"HttpService",
	"Lighting",
	"SoundService",
	"StarterGui",
	"StarterPlayer",
	"StarterPack",
	"Teams",
	"Chat",
	"TextChatService",
	"MarketplaceService",
	"ContextActionService",
	"TeleportService",
	"CollectionService",
	"Debris",
	"PathfindingService",
	"TextService",
    "VirtualInputManager"
} do
	getfenv()[Serv] = cloneref(game:GetService(Serv))
end

------------------------------
-- Variables & Functions
------------------------------

local Dump = {}

-- Variables
Dump.LocalPlayer = Players.LocalPlayer
Dump.Camera = workspace.CurrentCamera
Dump.Core = (gethui and gethui())
    or CoreGui
    or LocalPlayer:FindFirstChildOfClass("PlayerGui")

-- General Functions
Dump.GetHumanoid = function(Target)
	return Target
        and Target.Character
        and Target.Character:FindFirstChildOfClass("Humanoid")
end

Dump.GetRoot = function(Target)
	return Target
        and Target.Character
        and Target.Character:FindFirstChild("HumanoidRootPart")
end

Dump.GetOthers = function()
	local Others = {}

	for _, Player in Players:GetPlayers() do
		if Player == LocalPlayer then continue end
		table.insert(Others, Player)
	end

	return Others
end

Dump.GetPlayer = function(Query)
	if not Query then return end
	Query = Query:lower()

	if Query == "me" then return {LocalPlayer} end
	if Query == "others" then return GetOthers() end
	if Query == "all" then return Players:GetPlayers() end
	if Query == "random" then local Others = Dump.GetOthers() return Others[math.random(#Others)] end

	for _, Player in Players:GetPlayers() do
		if Player.Name:lower():find(Query) then
			return {Player}
		end

		if Player.DisplayName:lower():find(Query) then
			return {Player}
		end
	end
end

-- Custom Table Funcs
local tableclone = {}

for Name, Func in table do
	tableclone[Name] = Func
end

tableclone.delete = function(Root, Delete)
	for Key, Value in Root do
		if Value == Delete then
			Root[Key] = nil
		end
	end
end

tableclone.reverse = function(Root)
	for _ = 1, math.floor(#Root / 2) do
		local New = #Root - _ + 1
		Root[_] = Root[New]
		Root[New] = Root[_]
	end
	return Root
end

Dump.table = tableclone

-- Maid Functions
Dump.Connections = {}
Dump.Maid = function(Connection)
	table.insert(Connections, Connection)
	return Connection
end

Dump.Loops = {}
Dump.Loop = function(Name, Callback)
	Dump.Loops[Name] = true

	task.spawn(function()
		while Dump.Loops[Name] do
			Callback()
		end
	end)
end

Dump.Unloop = function(Name)
	Dump.Loops[Name] = nil
end

Dump.Marks = {}
Dump.Mark = function(Name, Connection)
	Dump.Marks[Name] = Connection
	return Connection
end

Dump.Unmark = function(Name)
	local Found = Dump.Marks[Name]
	if not Found then return end

	Found:Disconnect()
	Dump.Marks[Name] = nil
end

-- Instance Functions
local DefaultProperties = {}
Dump["_"] = function(ClassName, Properties)
	local Inst = Instance.new(ClassName)
	
	local Custom = DefaultProperties[ClassName]
	if Custom then
		for Property, Value in Custom do
			local Success, Error = pcall(function()
				Inst[Property] = Value
			end)
			if not Success then
				warn(Error)
			end
		end
	end
	
	for Property, Value in Properties do
		local Success, Error = pcall(function()
			Inst[Property] = Value
		end)
		if not Success then
			warn(Error)
		end
	end
	return Inst
end

Dump.SetDefaultProperty = function(ClassName, Property, Value)
	if not DefaultProperties[ClassName] then
		DefaultProperties[ClassName] = {}
	end

	DefaultProperties[ClassName][Property] = Value
end

-- Ui Functions
Dump.NewScreen = function()
	local Screen = Dump["_"]("ScreenGui", {
		Parent = Dump.Core,
		ResetOnSpawn = false,
		DisplayOrder = 2_147_483_647
	})
	return Screen
end

Dump.Pad = function(Inst)
	local Padding = Dump["_"]("UIPadding", {
        Parent = Inst
    })
	
	local Tree = {}

	function Tree:A(S, O)
		Padding.PaddingLeft = UDim.new(S, O)
		Padding.PaddingRight = UDim.new(S, O)
		Padding.PaddingTop = UDim.new(S, O)
		Padding.PaddingBottom = UDim.new(S, O)
		return Tree
	end

	function Tree:L(S, O)
		Padding.PaddingLeft = UDim.new(S, O)
		return Tree
	end

	function Tree:R(S, O)
		Padding.PaddingRight = UDim.new(S, O)
		return Tree
	end

	function Tree:T(S, O)
		Padding.PaddingTop = UDim.new(S, O)
		return Tree
	end

	function Tree:B(S, O)
		Padding.PaddingBottom = UDim.new(S, O)
		return Tree
	end

	return Tree
end

Dump.Stroke = function(Inst)
	local UIStroke = Dump["_"]("UIStroke", {
        Parent = Inst,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
	
	local Tree = {}
	Tree.Inst = UIStroke

	function Tree:Col(Color)
		UIStroke.Color = Color
		return Tree
	end

	function Tree:Trans(Num)
		UIStroke.Transparency = Num
		return Tree
	end

	function Tree:Size(Num)
		UIStroke.Thickness = Num
		return Tree
	end

	function Tree:Z(Num)
		UIStroke.ZIndex = Num
		return Tree
	end

	function Tree:Apply(New)
		UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode[New]
		return Tree
	end

	function Tree:Line(New)
		UIStroke.LineJoinMode = Enum.LineJoinMode[New]
		return Tree
	end

	return Tree
end

Dump.Ratio = function(Inst, Amount)
	local Aspect = Dump["_"]("UIAspectRatioConstraint", {
        Parent = Inst,
        AspectRatio = Amount
    })
	return Aspect
end

Dump.Center = function(Inst)
	Inst.AnchorPoint = Vector2.new(0.5, 0.5)
	Inst.Position = UDim2.new(0.5, 0, 0.5, 0)
end

Dump.CenterX = function(Inst)
	Inst.AnchorPoint = Vector2.new(0.5, 0)
	Inst.Position = UDim2.new(0.5, 0, Inst.Position.Y.Scale, Inst.Position.Y.Offset)
end

Dump.CenterY = function(Inst)
	Inst.AnchorPoint = Vector2.new(0, 0.5)
	Inst.Position = UDim2.new(Inst.Position.X.Scale, Inst.Position.X.Offset, 0.5, 0)
end

Dump.MultCol = function(Col, Mult)
	return Color3.new(Col.R * Mult, Col.G * Mult, Col.B * Mult)
end

Dump.Round = function(Inst, Scale, Offset)
	local Corner = Dump["_"]("UICorner", {
		Parent = Inst,
		CornerRadius = UDim.new(Scale or 0, Offset or 0)
	})
	return Corner
end

Dump.Style = function(Properties)
	local StyleTree = {}

	function StyleTree:Apply(Inst)
		for Property, Value in Properties do
			Inst[Property] = Value
		end
	end
	
	return StyleTree
end

-- Shit Exectutor Fixes
Dump.FindFirstDescendantOfClass = function(Inst, ClassName)
	for _, Desc in Inst:GetDescendants() do
		if Desc:IsA(ClassName) then
			return Desc
		end
	end
end

local Saves = {}
local function Save(Name, Inst, Properties)
	local PropDump = {}

	for _, Property in Properties do
		PropDump[Property] = Inst[Property]
	end
	
	Saves[Name] = {
		Inst = Inst,
		PropDump = PropDump
	}
end

local function Load(Name)
	local Found = Saves[Name]
	if not Found then return end

	local Inst, PropDump = Found.Inst, Found.PropDump
	for Property, Value in PropDump do
		Inst[Property] = Value
	end
end

Dump.fireclickdetector = function(Root)
	if not Root then return end

	local Part
	local Click

	if Root:IsA("ClickDetector") then
		Part = Root.Parent
		Click = Root
	else
		Click = Dump.FindFirstDescendantOfClass(Root, "ClickDetector")
	end

	if not Part then return end
	if not Click then return end

	if Part:IsA("Model") then
		Part = Dump.FindFirstDescendantOfClass(Part, "BasePart")
	end

	if not Part then return end
	if not Click then return end

	Save("Part", Part, {"CFrame", "Transparency", "CanTouch", "CanCollide"})
	Save("Click", Click, {"MaxActivationDistance"})

	Part.CFrame = Camera.CFrame * CFrame.new(0, 0, -Part.Size.Z - 1)
	Part.Transparency = 1
	Part.CanTouch = false
	Part.CanCollide = false
	Click.MaxActivationDistance = math.huge

	task.wait()

	local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
	if OnScreen then
		VirtualInputManager:SendMouseButtonEvent(ScreenPos.X, ScreenPos.Y, 0, true, game, 0)
		VirtualInputManager:SendMouseButtonEvent(ScreenPos.X, ScreenPos.Y, 0, false, game, 0)
	end

	task.wait()

	Load("Part")
	Load("Click")
end

-- Dump
for Name, Value in Dump do
    Env[Name] = Value
end

-- Import
local Util = {}

function Util:Import(ModuleName)
	loadstring(game:HttpGet(`https://raw.githubusercontent.com/88lkk/Util/refs/heads/main/Modules/{ModuleName}.lua`))()
end

return Util
