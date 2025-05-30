InventorixTooltip = {}

local reagentColor = WHITE_FONT_COLOR
local valueColor = WHITE_FONT_COLOR
local warbandColor = FRAMESTACK_FRAME_COLOR

function InventorixTooltip:PlayerWithItemCount(player, itemCount)
	local classColor = C_ClassColor.GetClassColor(player.classFilename)

	return classColor:WrapTextInColorCode(player.playerName)
		.. " " .. valueColor:WrapTextInColorCode(itemCount)
end

function InventorixTooltip:AddItemCountSection(tooltipLines, itemId, sectionTitle)
	local totalCount = 0

	table.insert(tooltipLines, {" "})
	table.insert(tooltipLines, {sectionTitle})

	-- Players
	for _, player in ipairs(CLIB_PlayerRegistry.players) do
		local itemCount = CLIB_Inventory:GetItemCountPlayer(player, itemId)
		if itemCount > 0 then
			table.insert(tooltipLines, {self:PlayerWithItemCount(player, itemCount)})
			totalCount = totalCount + itemCount
		end
	end

	-- Warband
	local warbandCount = CLIB_Inventory:GetItemCountWarband(itemId)
	totalCount = totalCount + warbandCount

	if #tooltipLines < 3 then
		table.insert(tooltipLines, {" "})
	end

	tooltipLines[2][2] = "Total " .. valueColor:WrapTextInColorCode(totalCount)
	tooltipLines[3][2] = warbandColor:WrapTextInColorCode("Warband ") .. valueColor:WrapTextInColorCode(warbandCount)
end

function InventorixTooltip:AddItemPartsSection(tooltipLines, itemId)
	local itemParts = CLIB_Constants:GetItemParts(itemId)

	if itemParts then
		for partItemId, title in pairs(itemParts) do
			self:AddItemCountSection(tooltipLines, partItemId, title)
		end
	end
end

function InventorixTooltip:AddItemRanksSection(tooltipLines, itemId)
	local itemRanks = CLIB_Constants:GetItemRanks(itemId)

	if itemRanks then
		for rank, similarItemId in ipairs(itemRanks) do
			if similarItemId ~= itemId then
				self:AddItemCountSection(tooltipLines, similarItemId, "Rank " .. rank)
			end
		end
	end
end

function InventorixTooltip:AddItemRecipesSection(tooltipLines, itemId)
	local itemRecipes = CLIB_Constants:GetItemRecipes(itemId)

	if itemRecipes then
		for title, reagents in pairs(itemRecipes) do
			self:AddRecipeCountSection(tooltipLines, reagents, title)
		end
	end
end

function InventorixTooltip:AddRecipeCountSection(tooltipLines,reagents, sectionTitle)
	local reagentCounts = {}

	table.insert(tooltipLines, {" "})
	table.insert(tooltipLines, {sectionTitle})

	-- Players
	for reagentId, reagentName in pairs(reagents) do
		reagentCounts[reagentName] = reagentCounts[reagentName] or 0
		for _, player in ipairs(CLIB_PlayerRegistry.players) do
			reagentCounts[reagentName] = reagentCounts[reagentName] + (CLIB_Inventory:GetItemCountPlayer(player, reagentId) or 0)
		end
	end

	for reagentName, reagentCount in pairs(reagentCounts) do
		table.insert(tooltipLines, reagentColor:WrapTextInColorCode(reagentName) .. " " .. valueColor:WrapTextInColorCode(reagentCount))
	end
end
