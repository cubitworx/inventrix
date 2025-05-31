InventorixTooltip = {}

local copperIcon = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:0:0|t"
local goldIcon = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:0:0|t"
local silverIcon = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:0:0|t"
local reagentColor = BRIGHTBLUE_FONT_COLOR
local valueColor = WHITE_FONT_COLOR
local warbandColor = FRAMESTACK_FRAME_COLOR

function InventorixTooltip:AddItemCountSection(tooltipLines, itemId, sectionTitle)
	local totalCount = 0

	table.insert(tooltipLines, {" "})
	table.insert(tooltipLines, {sectionTitle})
	local titleLineIndex = #tooltipLines

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

	if not tooltipLines[titleLineIndex + 1] then
		table.insert(tooltipLines, {" "})
	end

	tooltipLines[titleLineIndex][2] = "Total " .. valueColor:WrapTextInColorCode(totalCount)
	tooltipLines[titleLineIndex + 1][2] = warbandColor:WrapTextInColorCode("Warband ") .. valueColor:WrapTextInColorCode(warbandCount)
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
		for _, recipe in pairs(itemRecipes) do
			local reagentCounts = {}

			table.insert(tooltipLines, {" "})
			table.insert(tooltipLines, {recipe.title})

			-- Players
			for reagentId, reagentName in pairs(recipe.reagents) do
				reagentCounts[reagentName] = reagentCounts[reagentName] or 0
				for _, player in ipairs(CLIB_PlayerRegistry.players) do
					reagentCounts[reagentName] = reagentCounts[reagentName] + (CLIB_Inventory:GetItemCountPlayer(player, reagentId) or 0)
				end
			end

			for reagentName, reagentCount in pairs(reagentCounts) do
				table.insert(tooltipLines, {reagentColor:WrapTextInColorCode(reagentName) .. " " .. valueColor:WrapTextInColorCode(reagentCount)})
			end
		end
	end
end

function InventorixTooltip:AddVendorPurchasePrice(tooltipLines, itemId)
	local vendorPurchasePrice = CLIB_Constants:GetVendorPurchasePrice(itemId)

	if vendorPurchasePrice then
		table.insert(tooltipLines, {vendorPurchasePrice["source"], valueColor:WrapTextInColorCode(self:MoneyString(vendorPurchasePrice["price"]))})
	end
end

function InventorixTooltip:PlayerWithItemCount(player, itemCount)
	local classColor = C_ClassColor.GetClassColor(player.classFilename)

	return classColor:WrapTextInColorCode(player.playerName)
		.. " " .. valueColor:WrapTextInColorCode(itemCount)
end

function InventorixTooltip:MoneyString(amount)
	amount = math.floor(amount)

	local copper = amount % 100
	local silver = (amount % 10000 - copper) / 100
	local gold = (amount - silver * 100 - copper) / 10000

	local result = copper .. " " .. copperIcon

	if copper < 10 and (gold ~= 0 or silver ~= 0) then
		result = "0" .. result
	end

	if silver ~= 0 or gold ~= 0 then
		result = silver .. " " .. silverIcon .. " " .. result
	end

	if gold ~= 0 and silver < 10 then
		result = "0" .. result
	end

	if gold ~= 0 then
		result = gold .. " " .. goldIcon .. " " .. result
	end

	return result
end
