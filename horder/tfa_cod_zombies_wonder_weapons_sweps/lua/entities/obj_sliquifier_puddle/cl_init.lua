include("shared.lua")

function ENT:Draw()
	self.Color.a = math.Clamp((self.LifeTime - CurTime())*24, 0, 255)
	render.SetMaterial(self.Mat)
	render.DrawQuadEasy(self:GetPos(), self:GetUp(), 128, 128, self.Color)
end

function ENT:IsTranslucent()
	return true
end