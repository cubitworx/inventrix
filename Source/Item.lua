Inventorix.Item = {
	itemName = "",
}

function Inventorix.Item:New()
	local instance = self

	if not instance.isInstance then
		instance = CreateFromMixins(self)
		instance.isInstance = true
	end

	return instance
end

function Inventorix.Item:CreateFromItemId(itemId)
	local instance = self:New()

	instance.itemId = itemId
	instance.item = Item:CreateFromItemID(instance.itemId)

	instance.item:ContinueOnItemLoad(function()
		instance.itemName = instance.item:GetItemName()
	end)

	return instance
end

function Inventorix.Item:CreateFromItemLink(itemLink)
	local instance = self:New()

	instance.itemId = tonumber(string.match(itemLink, "item:(%d+)"))
	instance.item = Item:CreateFromItemID(instance.itemId)

	instance.item:ContinueOnItemLoad(function()
		instance.itemName = instance.item:GetItemName()
	end)

	return instance
end
