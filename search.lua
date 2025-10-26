--[[

	qol exploit that creates a search bar for the player list
	first ever roblox exploit that is entierly harmless :o woah..
	
	(i used to make these type of things alot)
	
]]

-- CONSTANTS
local WIDGET_ID = 'TEMP'

local WHITE = Color3.new(1, 1, 1)
local GREY = Color3.fromRGB(154, 154, 154)

local ACTIVE_TRANSPARENCY = .3
local INACTIVE_TRANSPARENCY = .67

-- visual fixes since we are injecting
local PATCHED_HEIGHT = 16
local REAL_HEIGHT = 32

local connections = {} :: { RBXScriptConnection }

local function connect(connection: RBXScriptConnection)
	table.insert(connections, connection)
end

local function disconnectAll()
	for _, connection in connections do
		connection:Disconnect()
	end
	
	connections = {}
end

local function newSearchWidget(CorePlayersArea: Frame)
	-- local CorePlayersArea = script.Parent

	-- find already existing assets
	if CorePlayersArea:FindFirstChild(WIDGET_ID) then
		local area = CorePlayersArea :: any -- lol
		area[WIDGET_ID]:Destroy()
		disconnectAll()
	end
	
	-- main frame
	local ListEntry = Instance.new("Frame")
	-- button
	local mainButton = Instance.new("ImageButton")
	-- the search box
	local searchBox = Instance.new("TextBox")
	-- decorative outline
	local border = Instance.new("UIStroke")
	-- decorative icon
	local icon = Instance.new("ImageLabel")

	do -- properties
		ListEntry.Name = WIDGET_ID
		ListEntry.BackgroundTransparency = 1
		ListEntry.LayoutOrder = -3
		ListEntry.Size = UDim2.new(1, 0, 0, 16)
		mainButton.Name = "Search"
		mainButton.AutoButtonColor = false
		mainButton.BackgroundColor3 = Color3.fromRGB(35, 37, 39)
		mainButton.BackgroundTransparency = 0.5
		mainButton.ImageTransparency = 0.65
		mainButton.LayoutOrder = -1
		mainButton.Size = UDim2.new(1, 0, 0, 32)
		mainButton.ZIndex = 0
		local uICorner = Instance.new("UICorner")
		uICorner.Parent = mainButton
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.BackgroundTransparency = 1
		icon.Image = "rbxassetid://110026935972195"
		icon.ImageColor3 = GREY
		icon.Position = UDim2.new(0, 3, 0.5, 0)
		icon.Size = UDim2.fromScale(0.8, 0.8)
		icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
		icon.ZIndex = 3
		icon.Parent = mainButton
		border.Color = Color3.new(1, 1, 1)
		border.Transparency = INACTIVE_TRANSPARENCY
		border.Parent = mainButton
		searchBox.Active = false
		searchBox.ClearTextOnFocus = false
		searchBox.AutoLocalize = false
		searchBox.BackgroundTransparency = 1
		searchBox.CursorPosition = -1
		searchBox.FontFace = Font.new(
			"rbxasset://fonts/families/BuilderSans.json",
			Enum.FontWeight.Medium,
			Enum.FontStyle.Normal
		)
		searchBox.PlaceholderColor3 = GREY
		searchBox.PlaceholderText = "Search"
		searchBox.Position = UDim2.fromOffset(32, 0)
		searchBox.Selectable = false
		searchBox.Size = UDim2.new(1, -32, 1, 0)
		searchBox.Text = ""
		searchBox.TextColor3 = Color3.new(1, 1, 1)
		searchBox.TextSize = 18
		searchBox.TextXAlignment = Enum.TextXAlignment.Left
		searchBox.ZIndex = 3
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Transparency = 0.39
		uIStroke.Parent = searchBox
		searchBox.Parent = mainButton
		mainButton.Parent = ListEntry
		ListEntry.Parent = CorePlayersArea
	end

	--> VARIABLES
	local query = ''

	local list = {} :: { { any } }

	-- visual fix
	local function onHolderUnknownAbsoluteSizeChanged(size: Vector2)
		local height = size.Y
		ListEntry.Size = UDim2.new(1, 0, 0, height == 0 and PATCHED_HEIGHT or REAL_HEIGHT)
	end

	local function wouldTextBeVisible(text: string)
		if query == '' then
			return true
		end

		local text = text:lower()
		local visible = text:find(query) and true or false

		return visible
	end

	local function wouldEntryBeVisible(entry: any)
		local text = entry[2]:lower()
		local displayName = entry[3] and entry[3]:lower()

		local visible

		if displayName then
			visible = wouldTextBeVisible(displayName) or wouldTextBeVisible(text)
		else
			visible = wouldTextBeVisible(text)
		end

		return visible
	end

	-- child added to the list
	local function handleNewChild(label: ImageLabel)
		if not (label:IsA('ImageLabel') and label.Name:sub(1, 11) == 'PlayerLabel') then
			return
		end
		-- local label = CorePlayersArea.PlayerLabelspritesworkshop

		local displayNameLabel = label:FindFirstChild('DisplayNameLabel') :: TextLabel
		local nameLabel = label:WaitForChild('NameLabel') :: TextLabel

		local entry = {
			label,
			nameLabel.Text,
		}

		if displayNameLabel then
			entry[3] = displayNameLabel.Text
		end

		label.Visible = wouldEntryBeVisible(entry)
		table.insert(list, entry)

		connect(label.Destroying:Connect(function()
			table.remove(list, table.find(list, entry))
		end))
	end

	local function onSearchBoxFocused()
		border.Transparency = ACTIVE_TRANSPARENCY

		searchBox.SelectionStart = 1
		searchBox.CursorPosition = #searchBox.Text + 1
	end
	local function onSearchBoxFocusLost()
		border.Transparency = INACTIVE_TRANSPARENCY
	end
	local function onSearchBoxChanged()
		query = searchBox.Text:lower()

		if query == '' then
			icon.ImageColor3 = GREY
		else
			icon.ImageColor3 = WHITE
		end

		for _, entry in pairs(list) do
			entry[1].Visible = wouldEntryBeVisible(entry)
		end
	end

	--> INIT
	connect(searchBox.Focused:Connect(onSearchBoxFocused))
	connect(searchBox.FocusLost:Connect(onSearchBoxFocusLost))
	connect(searchBox:GetPropertyChangedSignal('Text'):Connect(onSearchBoxChanged))

	connect(mainButton.Activated:Connect(function(inputObject: InputObject, clickCount: number)
		searchBox:CaptureFocus()
	end))

	connect(CorePlayersArea.ChildAdded:Connect(handleNewChild))
	for _, any in pairs(CorePlayersArea:GetChildren()) do
		pcall(handleNewChild, any)
	end

	local holderUnknown = CorePlayersArea:WaitForChild('Holder') :: Frame
	onHolderUnknownAbsoluteSizeChanged(holderUnknown.AbsoluteSize)
	connect(holderUnknown:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
		onHolderUnknownAbsoluteSizeChanged(holderUnknown.AbsoluteSize)
	end))
end

local CorePlayersArea = game.CoreGui
	:WaitForChild('RobloxGui', math.huge)
	:WaitForChild('SettingsClippingShield', math.huge)
	:WaitForChild('SettingsShield', math.huge)
	:WaitForChild('MenuContainer', math.huge)
	:WaitForChild('PageViewClipper', math.huge)
	:WaitForChild('PageView', math.huge)
	:WaitForChild('PageViewInnerFrame', math.huge)
	:WaitForChild('Players', math.huge) :: Frame

newSearchWidget(CorePlayersArea)