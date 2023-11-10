--[[
	PartCache V2.0 by Xan
	Creating parts is laggy, especially if they are supposed to be there for a split second and/or need to be made frequently.
	This module aims to resolve this lag by pre-creating the parts and CFraming them to a location far away and out of sight.
	When necessary, the user can get one of these parts and CFrame it to where they need, then return it to the cache when they are done with it.
	
	According to Roblox's Technical Director, zeuxcg (https://devforum.roblox.com/u/zeuxcg/summary)...
		>> CFrame is currently the only "fast" property in that you can change it every frame without really heavy code kicking in. Everything else is expensive.
		
		- https://devforum.roblox.com/t/event-that-fires-when-rendering-finishes/32954/19
	
	This alone should ensure the speed granted by this module.
		
		
	HOW TO USE THIS MODULE:
	
	Look at the bottom of my thread for an API! https://devforum.roblox.com/t/partcache-for-all-your-quick-part-creation-needs/246641
--]]

local PartCache = {}
local EXCESSIVE_PART_AMOUNT = 60						-- Will warn if PrecreatedParts > this
local CF_REALLY_FAR_AWAY = CFrame.new(0, 10e8, 0)		-- A CFrame that's really far away. Ideally. You are free to change this as needed.

--Similar to assert but warns instead of errors. This is here for utility.
local function assertwarn(Requirement, MessageIfNotMet)
	if not Requirement then
		warn(MessageIfNotMet)
	end
end

--Dupes a part from the template.
local function MakeFromTemplate(Template, CurrentCacheParent)
	local Part = Template:Clone()
	Part.CFrame = CF_REALLY_FAR_AWAY
	Part.Anchored = true
	Part.Parent = CurrentCacheParent
	return Part
end

--Returns the index of an entry in a table, or nil if no such entry exists.
local function Contains(Table, Entry)
	for Index, Object in pairs(Table) do
		if Object == Entry then
			return Index
		end
	end
	return nil
end

function PartCache.new(Template, PrecreatedParts)
	local PrecreatedParts = PrecreatedParts or 5
	
	--Catch cases for incorrect input.
	--Template stuff. Ensure template is non-nil, ensure template is a BasePart
	assert(Template ~= nil, "PartCache.new() failed! Reason: No template part specified.")
	assert(typeof(Template) == "Instance", "Error: Expected type Instance for parameter 'Template', got " .. typeof(Template) .. ".")
	assert(Template:IsA("BasePart"), "Error: Expected BasePart for parameter 'Template', got " .. Template.ClassName .. ".")
	
	--PrecreatedParts value.
	--Same thing. Ensure it's a number, ensure it's not negative, warn if it's really huge or 0.
	assert(typeof(PrecreatedParts) == "number", "Error: Expected type Number for parameter 'PrecreatedParts', got " .. typeof(PrecreatedParts) .. ".")
	assert(PrecreatedParts > 0, "PrecreatedParts can not be negative!")
	assertwarn(PrecreatedParts ~= 0, "PrecreatedParts is 0! This may have adverse effects when initially using the cache.")
	assertwarn(PrecreatedParts <= EXCESSIVE_PART_AMOUNT, "It is not advised to set PrecreatedParts > " .. EXCESSIVE_PART_AMOUNT .. " as this can cause lag on creation.")
	assertwarn(Template.Archivable, "The template's Archivable property has been set to false, which prevents it from being cloned. It will temporarily be set to true.")
	
	local PCache = {}
	local OldArchivable = Template.Archivable
	Template.Archivable = true
	local New = Template:Clone() --If they destroy it, we'll have a reference here to keep.
	Template.Archivable = OldArchivable
	
	Template = New
	New = nil
	
	local Open = {}
	local InUse = {}
	local CurrentCacheParent = workspace
	for _ = 1, PrecreatedParts do
		table.insert(Open, MakeFromTemplate(Template, CurrentCacheParent))
	end
	
	-- Gets a part from the cache, or creates one if no more are available.
	function PCache:GetPart()
		if #Open == 0 then
			warn("No parts available in the cache! Creating a new part instance... (This cache now contains a grand total of " .. tostring(#Open + #InUse + 1) .. " parts.)")
			table.insert(Open, MakeFromTemplate(Template, CurrentCacheParent))
		end
		local Part = Open[#Open]
		Open[#Open] = nil
		table.insert(InUse, Part)
		return Part
	end
	
	-- Returns a part to the cache.
	function PCache:ReturnPart(Part)
		assert(Part ~= nil, "Error: Part is nil")
		assert(typeof(Part) == "Instance", "Error: Expected type Instance for parameter 'Part', got " .. typeof(Part) .. ".")
		assert(Part:IsA("BasePart"), "Error: Expected BasePart for parameter 'Part', got " .. Part.ClassName .. ".")
		
		local Index = Contains(InUse, Part)
		if Index then
			table.remove(InUse, Index)
			table.insert(Open, Part)
			Part.CFrame = CF_REALLY_FAR_AWAY
			Part.Anchored = true
		else
			error("Attempted to return part \"" .. tostring(Part) .. "\" to the cache, but it's not in-use! Did you call this on the wrong part?")
		end
	end
	
	-- Deprecated in favor of ReturnPart
	function PCache:DestroyPart(Part)
		warn("PCache::DestroyPart has been deprecated in favor of PCache::ReturnPart. Use the new method instead.")
		PCache.DestroyPart = PCache.ReturnPart -- This will make it so the warning doesn't show again, and it calls ReturnPart directly, never using this function again.
		self:ReturnPart(Part)
	end
	
	-- Sets the parent of all cached parts.
	function PCache:SetCacheParent(Parent)
		assert(Parent ~= nil, "Error: Parent cannot be nil")
		assert(typeof(Parent) == "Instance", "Error: Expected type Instance for parameter 'Parent', got " .. typeof(Parent) .. ".")
		assert(Parent:IsDescendantOf(workspace) or Parent == workspace, "Cache parent is not a descendant of Workspace! Parts should be kept where they will remain in the visible world.") --To do: Normal error in this case? EDIT: Yes.
		
		CurrentCacheParent = Parent
		for Index, Object in pairs(Open) do
			Object.Parent = Parent
		end
		for Index, Object in pairs(InUse) do
			Object.Parent = Parent
		end
	end
	
	-- Add an amount of parts to this existing cache.
	-- This was going to be released but I have removed it. You should just specify more parts in PrecreatedParts. Or let the cache continue its automatic creation if you don't know how many parts you need.
	
--	function PCache:AddMoreParts(Amount)
--		assert(Amount ~= nil, "Amount parameter cannot be a nil value.")
--		assert(typeof(Amount) == "number", "Error: Expected type number for parameter 'Amount', got " .. typeof(Amount) .. ".")
--		assert(Amount > 0, "Error: Cannot add an amount of parts <= 0 to the cache.")
--		assertwarn(Amount <= EXCESSIVE_PART_AMOUNT, "Adding more than " .. EXCESSIVE_PART_AMOUNT .. " parts at one time may potentially cause lagspikes. Consider calling PartCache.new() with a higher value for 'precreatedParts' instead.")
--		
--		for _ = 1, Amount do
--			table.insert(Open, MakeFromTemplate(Template, CurrentCacheParent))
--		end
--	end
		
	-- Destroys this cache entirely. Use this when you don't need this cache object anymore.
	function PCache:Destroy()
		for Index, Object in pairs(Open) do
			Object:Destroy()
		end
		for Index, Object in pairs(InUse) do
			Object:Destroy()
		end
		Open = nil
		InUse = nil
		PCache.GetPart = nil
		PCache.DestroyPart = nil
		PCache.SetCacheParent = nil
--		PCache.CreateMoreParts = nil
		PCache.Destroy = nil
		PCache = nil
	end
	
	return PCache
end

return PartCache