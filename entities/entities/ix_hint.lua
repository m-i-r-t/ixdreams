AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Hint"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = false
ENT.playersInRange = {}
-- ENT.bNoPersist = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Description")
	self:NetworkVar("Int", 1, "DrawRange")
end

function ENT:Initialize()
	if SERVER then
		self:SetDescription("This is a hint entity.")
		self:SetDrawRange(200)

		self:SetModel("models/hunter/plates/plate.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)
		self:SetNoDraw(true)

		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) then
			phys:Wake()
		end
	end
	
	if CLIENT then
		self:CallOnRemove( "RemovePanelOnDelete", function(ent) if ent.panel and ispanel(ent.panel) then ent.panel:Remove() end end )
	end
end

if SERVER then
    util.AddNetworkString("ixSetHintDescription")
	util.AddNetworkString("ixSetHintDrawRange")
	util.AddNetworkString("ixDrawHintTooltip")
	
	net.Receive("ixSetHintDescription", function(length, client)
		local entity = net.ReadEntity()
		local sDescription = net.ReadString()

		if IsValid(entity) and entity:GetClass() == "ix_hint" then
			entity:SetDescription(sDescription)
		end
	end)
	
	net.Receive("ixSetHintDrawRange", function(length, client)
		local entity = net.ReadEntity()
		local range = net.ReadInt(32)

		if IsValid(entity) and entity:GetClass() == "ix_hint" then
			entity:SetDrawRange(range)
		end
	end)

    function ENT:Use(activator, caller)
        -- Placeholder for use interaction
    end
	
	function ENT:PlayersInRange(tbl)
		self.playersInRange = tbl
	end
	
	function ENT:Think()
		-- keep a record of player IDs within sphere for networking
		
		local entsInSphere = ents.FindInSphere(self:GetPos(), self:GetDrawRange() or 60)
		local playerIDsInSphere = {}

		for _, player in pairs(entsInSphere) do
			if player and player:IsPlayer() then
				local id = player:UserID()
				playerIDsInSphere[id] = true
				
				if not self.playersInRange[id] then		
					net.Start("ixDrawHintTooltip")
					net.WriteEntity(self)
					net.Send(player)
				end
			end
		end
		
		self:PlayersInRange(playerIDsInSphere)
	end
end

properties.Add("set_hint_description", {
	MenuLabel = "Set Description",
	Order = 2,
	MenuIcon = "icon16/application_form_edit.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_hint" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)
		Derma_StringRequest("Set Description", "Enter description:", ent:GetDescription(), function(description)

			net.Start("ixSetHintDescription")
			net.WriteEntity(ent)
			net.WriteString(description)
			net.SendToServer()
			
			if ent.panel then
				ent.panel:SetText(description)
				ent.panel:SizeToContents()
			end
			
		end)
	end
})

properties.Add("set_hint_draw_range", {
	MenuLabel = "Set Draw Range",
	Order = 3,
	MenuIcon = "icon16/application_form_edit.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_hint" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)
		Derma_StringRequest("Set Draw Range", "Enter distance (integer):", tostring(ent:GetDrawRange()), function(text)
			net.Start("ixSetHintDrawRange")
			net.WriteEntity(ent)
			net.WriteInt(tonumber(text), 32)
			net.SendToServer()
		end)
	end
})

if CLIENT then

	ENT.panel = {}

	function ENT:Draw()
		local player = LocalPlayer()
		
		if player:GetMoveType() == MOVETYPE_NOCLIP then
			self:DrawModel()
		end
	end
	
	function ENT:Think()
		if self.panel and ispanel(self.panel) then
			local ply = LocalPlayer()
	
			if not ply then return end
			
			local plyPos = ply:GetPos()
			local worldPos = self:GetPos()
			local dist = plyPos:DistToSqr(worldPos)
			local range = (self:GetDrawRange() or 0) ^ 2
			
			local tr = util.TraceHull( {
			start = LocalPlayer():EyePos(),
			endpos = self:GetPos()
			} )
			
			if dist < range and tr.Entity == self then
				self.panel:SetVisible(true)
				self.panel:SetWorldPos(self:GetPos())
				self.panel:SizeToContents()
			else
				self.panel:SetVisible(false)
			end
		end
	end
	
	net.Receive("ixDrawHintTooltip", function()
		local ply = LocalPlayer()
		
		local hintEntity = net.ReadEntity()
		local message = hintEntity:GetDescription()
		
		if ispanel(hintEntity.panel) then return end
		
		if not ply or not message or not hintEntity then print("ixDrawHintTooltip: not ply or not message or not hintEntity") return end
		
		local plyPos = ply:GetPos()
		local hintPos = hintEntity:GetPos()	
		local textPos = hintPos:ToScreen()
		local dist = plyPos:DistToSqr(hintPos)
		local range = hintEntity:GetDrawRange()
		local rangeSqr = range ^ 2
		
		if dist < (rangeSqr) then
			local hintPanel = vgui.Create("ixHintPanel")
			hintPanel:SetEntity(hintEntity)
			hintPanel:SetWrap(true)
			hintPanel:SetText(message)
			hintPanel:SetRange(range)
			hintPanel:SetWorldPos(hintPos)		
			hintPanel:SetVisible(true)
			
			hintEntity.panel = hintPanel
		end
	end)

end

