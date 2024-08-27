 local PANEL = {}

function PANEL:Init()
	self:SetSize(300, 200)
	self:Center()
	self:SetVisible(false)
	self:SetDrawBackground(false)
	self.background = nil
	self.fontColor = color_white
end

function PANEL:SetRange(range)
	self.range = range
end

function PANEL:SetWorldPos(pos)
	self.worldPos = pos
end

function PANEL:GetWorldPos(pos)
	return self.worldPos
end

function PANEL:SetEntity(entity)
	self.entity = entity
end

function PANEL:GetEntity()
	return self.entity 
end

function PANEL:SetBackground(material)
	self.background = material
end

function PANEL:SetFontColor(color)
	self.fontColor = color
end

function PANEL:Think()
	local ply = LocalPlayer()
	
	if not ply then return end
	
	if not self.entity then self:Remove() end

	local worldPos = self:GetWorldPos() or {0, 0, 0}

	local selfWidth = self:GetWide()
	local selfHeight = self:GetTall()
	local screenPos = worldPos:ToScreen()
	
	local correctedPos = {x = screenPos.x - (selfWidth / 2), y = screenPos.y - (selfHeight / 2)}
	
	self:SetPos(correctedPos.x, correctedPos.y)
end

function PANEL:Paint(w, h)
	if self.background then
		surface.SetMaterial(self.background)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	-- draw.DrawText(self:GetText(), "DermaDefault", w/2, h/2, self.fontColor, TEXT_ALIGN_CENTER)
end

vgui.Register("ixHintPanel", PANEL, "DLabel")