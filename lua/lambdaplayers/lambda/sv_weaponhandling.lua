
local isfunction = isfunction
local random = math.random

-- Switch to a weapon with the provided name.
-- See the lambda/weapons folder for weapons. Check out the holster.lua file to see the current valid weapon settings
function ENT:SwitchWeapon( weaponname )
    local weapondata = _LAMBDAPLAYERSWEAPONS[ weaponname ]
    if !weapondata or weaponname == self.l_Weapon then return end

    local oldwepdata = _LAMBDAPLAYERSWEAPONS[ self.l_Weapon ]
    if oldwepdata and isfunction( oldwepdata.OnUnequip ) then oldwepdata.OnUnequip( self, wepent ) end

    local wepent = self.WeaponEnt

    if weapondata.bonemerge then wepent:AddEffects( EF_BONEMERGE ) else wepent:RemoveEffects( EF_BONEMERGE ) end

    self.l_Weapon = weaponname
    self.l_HasLethal = weapondata.islethal
    self.l_HoldType = weapondata.holdtype
    self.l_CombatKeepDistance = weapondata.keepdistance
    self.l_CombatAttackRange = weapondata.attackrange
    self.l_CombatSpeedAdd = weapondata.addspeed or 0
    
    wepent:SetNoDraw( weapondata.nodraw or false )
    wepent:DrawShadow( !weapondata.nodraw ) -- Prevent Shadows from rendering

    wepent:SetModel( weapondata.model )

    if isfunction( weapondata.OnEquip ) then weapondata.OnEquip( self, wepent ) end

end

local string_Explode = string.Explode
local string_find = string.find
local function TranslateRandomization( string )
    local hasstar = string_find( string, "*" )

    if hasstar then
        local exp = string_Explode( "*", string )
        local firsthalf = exp[ 1 ]
        local num = exp[ 2 ]
        local secondhalf = exp[ 3 ]
        return firsthalf .. random( num ) .. secondhalf
    else
        return string
    end
end

function ENT:UseWeapon( target )
    local weapondata = _LAMBDAPLAYERSWEAPONS[ self.l_Weapon ]
    if !weapondata or CurTime() < self.l_WeaponUseCooldown then return end
    local wepent = self.WeaponEnt

    local ismelee = weapondata.ismelee or false
    
    
    local callback = weapondata.callback
    local gesture = weapondata.attackanim
    local snd = weapondata.attacksnd
    local damage = weapondata.damage
    local rateoffire = weapondata.rateoffire

    if ismelee then

        local hitsnd = weapondata.hitsnd

        if callback == nil or isfunction( callback ) and !callback( self, wepent, target) then

            self.l_WeaponUseCooldown = CurTime() + rateoffire

            wepent:EmitSound( TranslateRandomization( snd ), 70, 100, 1, CHAN_WEAPON )
        
            self:RemoveGesture( gesture )
            self:AddGesture( gesture )

            local dmg = DamageInfo() 
            dmg:SetDamage( damage )
            dmg:SetAttacker( self )
            dmg:SetInflictor( wepent )
            dmg:SetDamageType( DMG_CLUB )
            dmg:SetDamageForce( ( target:WorldSpaceCenter() - self:WorldSpaceCenter() ):GetNormalized() * damage )

            target:EmitSound( TranslateRandomization( hitsnd ), 70 )

            target:TakeDamageInfo( dmg )
        end
        
    end

end