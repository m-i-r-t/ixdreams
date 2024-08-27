AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Cooking Source"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = false
-- ENT.bNoPersist = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "DisplayName")
	self:NetworkVar("String", 1, "Description")
    self:NetworkVar("String", 3, "VisibleModel")
    self:NetworkVar("Bool", 4, "Point")
end

if SERVER then
    util.AddNetworkString("ixSetCookingSourceDisplayName")
    util.AddNetworkString("ixSetCookingSourceDescription")
    util.AddNetworkString("ixSetCookingSourceVisibleModel")
    util.AddNetworkString("ixSetCookingSourcePoint")

    function ENT:Initialize()
		self:SetDisplayName("Cooking Source")
		self:SetDescription("A cooking source entity.")
	
        self:SetModel("models/props_c17/consolebox01a.mdl")
        self:SetSolid(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        if self:GetPoint() then
            self:SetModel("models/props_junk/watermelon01.mdl")
            self:DrawShadow(false)
            self:SetNoDraw(true)
        else
            self:SetModel(self:GetVisibleModel() or "models/props_c17/consolebox01a.mdl")
        end

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
    end

    function ENT:Use(activator, caller)
        -- Placeholder for use interaction
    end
	
	net.Receive("ixSetCookingSourceDisplayName", function(length, client)
        local entity = net.ReadEntity()
        local sDisplayName = net.ReadString()

        if IsValid(entity) and entity:GetClass() == "ix_cookingsource" then
            entity:SetDisplayName(sDisplayName)
        end
    end)
	
	net.Receive("ixSetCookingSourceDescription", function(length, client)
        local entity = net.ReadEntity()
        local sDescription = net.ReadString()

        if IsValid(entity) and entity:GetClass() == "ix_cookingsource" then
            entity:SetDescription(sDescription)
        end
    end)

    net.Receive("ixSetCookingSourceVisibleModel", function(length, client)
        local entity = net.ReadEntity()
        local model = net.ReadString()

        if IsValid(entity) and entity:GetClass() == "ix_cookingsource" and util.IsValidModel(model) then
            entity:SetVisibleModel(model)
			entity:SetModel(entity:GetVisibleModel())
            entity:SetMoveType(MOVETYPE_VPHYSICS)
            entity:PhysicsInit(SOLID_VPHYSICS)
            entity:SetSolid(SOLID_VPHYSICS)

            local phys = entity:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
            end
        end
    end)

    net.Receive("ixSetCookingSourcePoint", function(length, client)
        local entity = net.ReadEntity()
        local Point = net.ReadBool()

        if IsValid(entity) and entity:GetClass() == "ix_cookingsource" then
            entity:SetPoint(Point)

            if Point then
                entity:SetModel("models/props_junk/watermelon01.mdl")
				entity:SetMoveType(MOVETYPE_VPHYSICS)
				entity:PhysicsInit(SOLID_VPHYSICS)
				entity:SetSolid(SOLID_VPHYSICS)
                entity:DrawShadow(false)
                entity:SetNoDraw(true)
            else
                entity:SetModel(entity:GetVisibleModel() or "models/props_c17/consolebox01a.mdl")
				entity:SetMoveType(MOVETYPE_VPHYSICS)
				entity:PhysicsInit(SOLID_VPHYSICS)
				entity:SetSolid(SOLID_VPHYSICS)
                entity:DrawShadow(true)
                entity:SetNoDraw(false)
            end
        end
    end)
end

properties.Add("set_cooking_source_displayname", {
	MenuLabel = "Set Name",
	Order = 1,
	MenuIcon = "icon16/application_form_edit.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_cookingsource" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)
		Derma_StringRequest("Set Display Name", "Enter display name:", ent:GetDisplayName(), function(name)
		
			net.Start("ixSetCookingSourceDisplayName")
			net.WriteEntity(ent)
			net.WriteString(name)
			net.SendToServer()
		end)
	end
})

properties.Add("set_cooking_source_description", {
	MenuLabel = "Set Description",
	Order = 2,
	MenuIcon = "icon16/application_form_edit.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_cookingsource" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)
		Derma_StringRequest("Set Description", "Enter description:", ent:GetDescription(), function(description)

			net.Start("ixSetCookingSourceDescription")
			net.WriteEntity(ent)
			net.WriteString(description)
			net.SendToServer()
		end)
	end,
})

properties.Add("set_cooking_source_model", {
	MenuLabel = "Set Model",
	Order = 3,
	MenuIcon = "icon16/application_form_edit.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_cookingsource" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)
		Derma_StringRequest("Set Model", "Enter the model path:", ent:GetVisibleModel(), function(modelPath)
			net.Start("ixSetCookingSourceVisibleModel")
			net.WriteEntity(ent)
			net.WriteString(modelPath)
			net.SendToServer()
		end)
	end,
})

properties.Add("set_cooking_source_point", {
	MenuLabel = "Set Point",
	Order = 5,
	MenuIcon = "icon16/brick.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_cookingsource" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)
	
	end,
	
	MenuOpen = function(self, option, ent, tr)

	local submenu = option:AddSubMenu()
	local trueOption = submenu:AddOption("True", function()                 
		net.Start("ixSetCookingSourcePoint")
			net.WriteEntity(ent)
			net.WriteBool(true)
		net.SendToServer()
		end)
		
	local falseOption = submenu:AddOption("False",function()                 
		net.Start("ixSetCookingSourcePoint")
			net.WriteEntity(ent)
			net.WriteBool(false)
		net.SendToServer()
		end)

	-- Set the current selection as checked
	local current = ent:GetPoint()
	if (current) then
		trueOption:SetChecked(true)
	else
		falseOption:SetChecked(true)
	end
end
})

if CLIENT then
	
	ENT.PopulateEntityInfo = true
	
	function ENT:OnPopulateEntityInfo(container)
		local bNoDisplayInfo = self:GetPoint()
		
		if not bNoDisplayInfo then
			local name = container:AddRow("name")
			name:SetImportant()
			name:SetText(self:GetDisplayName())
			name:SizeToContents()

			local descriptionText = self:GetDescription()

			if (descriptionText != "") then
				local description = container:AddRow("description")
				description:SetText(self:GetDescription())
				description:SizeToContents()
			end
		end
	end

	function ENT:Draw()
		local player = LocalPlayer()
		
		if not self:GetPoint() or player:GetMoveType() == MOVETYPE_NOCLIP then
			self:DrawModel()
		end
	end

end

