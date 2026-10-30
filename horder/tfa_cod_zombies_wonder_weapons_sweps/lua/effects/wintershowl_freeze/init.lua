EFFECT.ParentEntOverlayMat = Material("models/weapons/black_ops_1/freeze_gun/rus_ter_ice_slush")
function EFFECT:Init(data)
	self.ParentEnt = data:GetEntity()
	
	if !IsValid(self.ParentEnt) or self.ParentEnt.IceEffect then 
		self:Remove() 
		return
	end
	
	self.AttID = data:GetAttachment()
	
	self:SetRenderBounds(self.ParentEnt:GetModelRenderBounds(), Vector(4,4,8)) --Vector(-20, -20, 0), Vector(20, 20, 80)
	self:SetPos(self.ParentEnt:GetPos())
	self:SetModel("models/weapons/black_ops_1/freezegun/ice_"..math.random(0,1)..".mdl")
	
	self:SetModelScale(0.1, 0)

	self.Time = 0
end

function EFFECT:Think()
	self.Time = self.Time + FrameTime()
	
	if IsValid(self) and IsValid(self.ParentEnt) and self.ParentEnt:GetNW2Float("IceStaffSlow", 0) > 0 then return true end
	
	return false
end

function EFFECT:Render()
	if !IsValid(self) or !IsValid(self.ParentEnt) then return end
	
	local att = self.ParentEnt:GetAttachment(self.AttID)
	
	--self:SetRenderOrigin(att.Pos - vector_up*8)
	--self:SetRenderAngles(att.Ang)
	
	self:SetModelScale(math.Clamp(self.Time * 0.25, 0.1, 1), 0)
	self:SetupBones()
	if att then
		self:SetPos(att.Pos)
		self:SetAngles(att.Ang)
	else
		self:SetPos(self.ParentEnt:WorldSpaceCenter())
		self:SetAngles(self.ParentEnt:GetAngles())
	end
	
	self:DrawModel()
end