if SERVER then
	AddCSLuaFile()
end

if LocalPlayer then
		surface.CreateFont( "Half Life 2", {
		font = "BoxRocket", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		extended = true,
		size = 50,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = true,
		outline = false,
		} )
		
	surface.CreateFont( "Sci-Fi", {
	font = "Zekton Rg",
	size = 13,
	weight = 400,
})
	--Color Constants

	local BGColor = Color(0,0,0,20)

	local AccentColor = Color(225,225,225,225)

	local InactiveColor = Color(128,128,128,225)

	local DamageColor = Color(200,10,10,225)

	local ArmorChargeColor = Color(10,255,182,225)

	local ArmorDrainColor = Color(225,10,10,225)

	local HealColor = Color(10,255,182,225)

	local blurTex = Material( "pp/blurscreen" )

	--Constant Tables

	local HUDBounds = {
		['x']=1/64,
		['y']=1/64*ScrW()/ScrH()
	}

	local HiddenElements = {
		['CHudHealth']=true,
		['CHudBattery']=true,
		['CHudAmmo']=true,
		['CHudSecondaryAmmo']=true
	}

	--Text Constants

	local HealthTextTable = {
		['text'] = "+",
		['font'] = "Half Life 2",
		['pos'] = {0,0},
		['xalign'] = TEXT_ALIGN_LEFT,
		['yalign'] = TEXT_ALIGN_CENTER,
		['color'] = AccentColor
	}

	local ArmorTextTable = {
		['text'] = "⌂",
		['font'] = "Half Life 2",
		['pos'] = {0,0},
		['xalign'] = TEXT_ALIGN_LEFT,
		['yalign'] = TEXT_ALIGN_CENTER,
		['color'] = AccentColor
	}

	local GunTextTable = {
		['text'] = 'asdf',
		['font'] = "Sci-Fi",
		['pos'] = {0,0},
		['xalign'] = TEXT_ALIGN_LEFT,
		['yalign'] = TEXT_ALIGN_TOP,
		['color'] = AccentColor
	}

	local CompassTextTable = {
		['text'] = "NN",
		['font'] = "Half Life 2",
		['pos'] = {0,0},
		['xalign'] = TEXT_ALIGN_LEFT,
		['yalign'] = TEXT_ALIGN_CENTER,
		['color'] = AccentColor
	}

	WeaponNames = {
		['weapon_crowbar'] = "Crowbar",
		['weapon_ar2'] = "Combine AR2",
		['weapon_357'] = ".357 Magnum",
		['weapon_pistol'] = "USP Match",
		['weapon_smg1'] = "H&K MP7A1",
		['weapon_slam'] = "SLAM Anti-Personel",
		['weapon_rpg'] = "RPG-9",
		['weapon_stunstick'] = "Stunstick",
		['weapon_frag'] = "Fragmentation Grenades",
		['weapon_shotgun'] = "SPAS-12",
		['weapon_bugbait'] = "Bug Bait",
		['weapon_physcannon'] = "Zero Point Energy Field Manipulator",
		['weapon_physgun'] = "Physics Gun",
		['weapon_camera'] = "Camera",
		['weapon_crossbow'] = "Resistance Crossbow",
		['weapon_hands'] = "None",
		['hands'] = "None"
	}

	local CompassDirections = {
	"NN",
	"NE",
	"EE",
	"SE",
	"SS",
	"SW",
	"WW",
	"NW"
	}
	
	--Health Fade Stuff

	local HealthColor = Color(AccentColor.r,AccentColor.g,AccentColor.b,AccentColor.a)

	local ArmorColor = Color(AccentColor.r,AccentColor.g,AccentColor.b,AccentColor.a)

	local FlashFade = 200 --Health fade per second

	local OldHealth = 100

	local OldArmor = 0

	--Bullets Code

	local BulletShiftSpeed = 1

	local BulletGravity = 1100 --Pixels per second

	local HUDBullets = {}

	local HUDBulletParticles = {}

	local BulletDefaultSprite = 'bullet'

	local WeaponBulletSpriteCache = {
		['weapon_shotgun'] = 'shotgun'
	}

	local BulletSprites = {
		['bullet'] ={
			['sprite'] = surface.GetTextureID("vgui/hud/tfa_bullet"),
			['sprite_spent'] = surface.GetTextureID("vgui/hud/tfa_bullet_spent"),
			['w'] = 8,
			['h'] = 32,
			['w_spent'] = 8,
			['h_spent'] = 24
		},
		['shotgun'] ={
			['sprite'] = surface.GetTextureID("vgui/hud/tfa_shotgun_shell"),
			['sprite_spent'] = surface.GetTextureID("vgui/hud/tfa_shotgun_shell_spent"),
			['w'] = 14,
			['h'] = 31,
			['w_spent'] = 14,
			['h_spent'] = 25
		},
		['9mm'] ={
			['sprite'] = surface.GetTextureID("vgui/hud/tfa_bullet_9mm"),
			['sprite_spent'] = surface.GetTextureID("vgui/hud/tfa_bullet_9mm_spent"),
			['w'] = 8,
			['h'] = 32,
			['w_spent'] = 8,
			['h_spent'] = 24
		}
	}

	local function WeaponIsShotgun( wep )
		if !IsValid(wep) then return false end
		
		if wep and wep.Primary and wep.Primary.Shotgun then return true end
		
		if wep.Shotgun then return true end
		
		if wep.IsShotgun then return true end
		
		if string.find(string.lower(wep.Category or ""),"shotgun") then return true end
		
		if string.find(string.lower(wep.PrintName or ""),"shotgun") then return true end
		
		if string.find(string.lower(wep:GetClass() or ""),"shotgun") then return true end
		
		if string.find(string.lower(wep.Base or ""),"shotgun") then return true end
		
		local ammotype = string.lower(wep:GetPrimaryAmmoType())
		
		if wep.Primary and wep.Primary.Ammo then
			ammotype = string.lower(wep.Primary.Ammo)
		end
		
		if string.find(string.lower(ammotype or ""),"buck") then return true end
		
		return false
	end

	local function WeaponIsPistol( wep )
		if !IsValid(wep) then return false end
		
		if wep and wep.Primary and wep.Primary.Pistol then return true end
		
		if wep.Pistol then return true end
		
		if wep.Pistol then return true end
		
		if string.find(string.lower(wep.Category or ""),"pistol") then return true end
		
		if string.find(string.lower(wep.PrintName or ""),"pistol") then return true end
		
		if string.find(string.lower(wep:GetClass() or ""),"pistol") then return true end
		
		if string.find(string.lower(wep.Base or ""),"pistol") then return true end
		
		local ammotype = string.lower(wep:GetPrimaryAmmoType())
		
		if wep.Primary and wep.Primary.Ammo then
			ammotype = string.lower(wep.Primary.Ammo)
		end
		
		if string.find(ammotype or "","9mm") or string.find(ammotype or "","pistol") then return true end
		
		return false
	end

	local function GetBulletWidth( bul )
		return BulletSprites[bul.sprite].w
	end

	local function AddHUDBullet( spritename )
		local lastx, lasty, lastbul, bul
		
		lastbul = HUDBullets[#HUDBullets]
		
		bul = {
			['sprite'] = "bullet",
			['x'] = 2,
			['y'] = 0
		}
		
		if lastbul and lastbul.x then
			bul.x = lastbul.x + GetBulletWidth(lastbul) + 1
		end
		
		if spritename then
			bul.sprite = spritename
		end
		
		table.insert(HUDBullets,#HUDBullets+1,bul)
	end

	local function TFAHudAddBulletParticle( spritev, xv, yv, velocityv, velocity_av, drag_liv, drag_av )
		local spritetbl = BulletSprites[spritev]
		local bul = {
			['sprite'] = spritev,
			['x'] = xv,
			['y'] = yv+(spritetbl.h-spritetbl.h_spent)/2,
			['velocity'] = velocityv,
			['velocity_a'] = velocity_av,
			['drag_li'] = drag_liv,
			['drag_a'] = drag_av,
			['rotation'] = 0
		}
		table.insert(HUDBulletParticles,#HUDBulletParticles+1,bul)
	end

	local function TFAHudBulletsProcess()
		local w,h = ScrW(), ScrH()

		local lastbul,targetx
		for k,v in ipairs(HUDBullets) do
			lastbul = HUDBullets[k-1]
			targetx = 2
			
			if lastbul and lastbul.x then
				targetx = lastbul.x + GetBulletWidth(lastbul)+1
			end

			if v.x>targetx then
				v.x = math.max(targetx,v.x-FrameTime()*(w/7)*BulletShiftSpeed)
			elseif v.x<targetx then
				v.x = math.min(targetx,v.x+FrameTime()*(w/7)*BulletShiftSpeed)		
			end
		end
		
		for k,v in ipairs(HUDBulletParticles) do
			v.x = v.x + v.velocity.x*FrameTime()
			v.y = v.y + v.velocity.y*FrameTime()
			v.rotation=v.rotation + v.velocity_a*FrameTime()
			v.velocity.y = v.velocity.y + BulletGravity*FrameTime()
			v.velocity.x = math.Approach(v.velocity.x,0,v.drag_li)
			v.velocity.y = math.Approach(v.velocity.y,0,v.drag_li)
			v.velocity_a = math.Approach(v.velocity_a,0,v.drag_a)
		end
		
		for k,v in ipairs(HUDBulletParticles) do
			if v.y>ScrH()+30 then
				table.remove(HUDBulletParticles,k)
			end
		end
		
	end

	local OldAmmo = -1

	local OldWeapon = nil

	--Main Code

	local function draw_circle( x, y, radius, seg )
		local cir = {}

		table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		for i = 0, seg do
			local a = math.rad( ( i / seg ) * -360 )
			table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end

		local a = math.rad( 0 ) -- This is need for non absolute segment counts
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

		surface.DrawPoly( cir )
	end
	
	local function TFAHudBulletsPopulate(ply, oldwep, newwep)
		table.Empty(HUDBullets)
		ply = ply and ply or LocalPlayer()
		if !IsValid(ply) then return end
		newwep = newwep and newwep or ply:GetActiveWeapon()
		if !IsValid(newwep) then return end
		local wep = newwep
		local i=0
		
		if !WeaponBulletSpriteCache[wep:GetClass()] then
			if WeaponIsShotgun(wep) then
				WeaponBulletSpriteCache[wep:GetClass()] = "shotgun"
			elseif WeaponIsPistol(wep) then
				WeaponBulletSpriteCache[wep:GetClass()] = "9mm"		
			else
				WeaponBulletSpriteCache[wep:GetClass()] = BulletDefaultSprite
			end
		end
		
		while i<wep:Clip1() do
			AddHUDBullet(WeaponBulletSpriteCache[wep:GetClass()])
			i=i+1
		end
	end

	local function DrawBlurRect(x, y, w, h, blur, passes)
		
		surface.SetDrawColor(255,255,255)
		surface.SetMaterial(blurTex)
		
		for i = 1, passes do
			blurTex:SetFloat("$blur", blur)
			blurTex:Recompute()
		
			render.UpdateScreenEffectTexture()
			
			render.SetScissorRect(x, y, x+w, y+h, true)
				surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			render.SetScissorRect(0, 0, 0, 0, false)
		end
	end

	local function ShouldDraw()
		local ply = LocalPlayer()
		if !IsValid(ply) then return end
		if !ply:Alive() then return false end
		return ( GetConVarNumber("cl_drawhud",1) == 1 ) and true or false
	end

	local function TFAHideHud( el )
		if HiddenElements[el] then return false end
	end

	local function TFAHudDraw()
		if !ShouldDraw() then return end
		
		local ply = LocalPlayer()
		
		local w,h = ScrW(), ScrH()
		
		local xx, yy
		
		local iconx,icony
		
		local textx,texty = 19,16
		
		xx=w*HUDBounds.x
		yy=h-h*(HUDBounds.y)
		
		--draw.RoundedBox(0,0,yy,w,1,color_white)
		
		--Health	
		
		yy=yy-56
		
		DrawBlurRect( xx, yy, w/0, 0, 0, 0 )
		
		surface.SetDrawColor(BGColor)
		
		surface.DrawRect( xx, yy, w/6.8,30 )
		
		HealthTextTable.pos = {xx+- -3,yy+6.5}
		HealthTextTable.text =  "+"
		
		HealthTextTable.font =  "Half Life 2"
		
		HealthTextTable.xalign = TEXT_ALIGN_LEFT
		HealthTextTable.yalign = TEXT_ALIGN_CENTER
		
		if ply:Health()<1 then
			HealthTextTable.color = InactiveColor
		else
			HealthTextTable.color = AccentColor
		end
		
		iconx,icony = draw.Text( HealthTextTable )
		
		HealthTextTable.pos[1] = HealthTextTable.pos[1]+iconx+textx/2+7
		
		HealthTextTable.pos[2] = HealthTextTable.pos[2]- -7
		
		HealthTextTable.xalign = TEXT_ALIGN_CENTER
		HealthTextTable.yalign = TEXT_ALIGN_CENTER
		
		HealthTextTable.text =  tostring(math.ceil(ply:Health()))
		
		HealthTextTable.text = string.sub(HealthTextTable.text,1,math.min(string.len(HealthTextTable.text),3))

		HealthTextTable.font =  "DermaDefault"
		
		iconx,icony = draw.Text( HealthTextTable )
		
		local healthpercent = math.Clamp( ply:Health() / math.max( ply:GetMaxHealth(), 1 ), 0, 1)
		
		
		if HealthColor.r>AccentColor.r then
			HealthColor.r = math.Clamp(math.max(HealthColor.r-FrameTime()*FlashFade,AccentColor.r),0,255)
		elseif HealthColor.r<AccentColor.r then
			HealthColor.r = math.Clamp(math.min(HealthColor.r+FrameTime()*FlashFade,AccentColor.r),0,255)
		end
		
		if HealthColor.g>AccentColor.g then
			HealthColor.g = math.Clamp(math.max(HealthColor.g-FrameTime()*FlashFade,AccentColor.g),0,255)
		elseif HealthColor.g<AccentColor.g then
			HealthColor.g = math.Clamp(math.min(HealthColor.g+FrameTime()*FlashFade,AccentColor.g),0,255)
		end
		
		if HealthColor.b>AccentColor.b then
			HealthColor.b = math.Clamp(math.max(HealthColor.b-FrameTime()*FlashFade,AccentColor.b),0,255)
		elseif HealthColor.b<AccentColor.b then
			HealthColor.b = math.Clamp(math.min(HealthColor.b+FrameTime()*FlashFade,AccentColor.b),0,255)
		end
		
		if HealthColor.a>AccentColor.a then
			HealthColor.a = math.Clamp(math.max(HealthColor.a-FrameTime()*FlashFade,AccentColor.a),0,255)
		elseif HealthColor.a<AccentColor.a then
			HealthColor.a = math.Clamp(math.min(HealthColor.a+FrameTime()*FlashFade,AccentColor.a),0,255)
		end
		
		if ply:Health()<OldHealth then
			for k,v in pairs(DamageColor) do
				HealthColor[k]=v
			end
		elseif ply:Health()>OldHealth then
			for k,v in pairs(HealColor) do
				HealthColor[k]=v
			end	
		end
		
		OldHealth = ply:Health()
		
		surface.SetDrawColor(HealthColor)
		
		surface.DrawRect( HealthTextTable.pos[1]+textx-5, yy+12.5, ( (w/7) - (textx+iconx+19) )*healthpercent,4 )
		
		--Armor
		
		yy = yy - 35
		
		DrawBlurRect( xx, yy, w/7, 25, 2, 2 )
		
		surface.SetDrawColor(BGColor)
		
		surface.DrawRect( xx, yy, w/6.8,30 )
		
		ArmorTextTable.pos = {xx+- -3,yy+6.5}
		
		ArmorTextTable.text = "*"
		
		ArmorTextTable.font =  "Half Life 2"
		
		ArmorTextTable.xalign = TEXT_ALIGN_LEFT
		ArmorTextTable.yalign = TEXT_ALIGN_CENTER
		
		if ply:Armor()<1 then
			ArmorTextTable.color = InactiveColor
		else
			ArmorTextTable.color = AccentColor
		end
		
		iconx,icony = draw.Text( ArmorTextTable )
		
		ArmorTextTable.pos[1] = ArmorTextTable.pos[1]+iconx+textx/1.5- -5
		
		ArmorTextTable.pos[2] = ArmorTextTable.pos[2]- -7
		
		ArmorTextTable.xalign = TEXT_ALIGN_CENTER
		ArmorTextTable.yalign = TEXT_ALIGN_CENTER
		
		ArmorTextTable.text =  tostring(math.ceil(ply:Armor()))
		
		ArmorTextTable.text = string.sub(ArmorTextTable.text,1,math.min(string.len(ArmorTextTable.text),3))
		
		ArmorTextTable.font =  "DermaDefault"
		
		iconx,icony = draw.Text( ArmorTextTable )
		
		local armorpercent = math.Clamp( ply:Armor() / 100, 0, 1)
		
		
		if ArmorColor.r>AccentColor.r then
			ArmorColor.r = math.Clamp(math.max(ArmorColor.r-FrameTime()*FlashFade,AccentColor.r),0,255)
		elseif ArmorColor.r<AccentColor.r then
			ArmorColor.r = math.Clamp(math.min(ArmorColor.r+FrameTime()*FlashFade,AccentColor.r),0,255)
		end
		
		if ArmorColor.g>AccentColor.g then
			ArmorColor.g = math.Clamp(math.max(ArmorColor.g-FrameTime()*FlashFade,AccentColor.g),0,255)
		elseif ArmorColor.g<AccentColor.g then
			ArmorColor.g = math.Clamp(math.min(ArmorColor.g+FrameTime()*FlashFade,AccentColor.g),0,255)
		end
		
		if ArmorColor.b>AccentColor.b then
			ArmorColor.b = math.Clamp(math.max(ArmorColor.b-FrameTime()*FlashFade,AccentColor.b),0,255)
		elseif ArmorColor.b<AccentColor.b then
			ArmorColor.b = math.Clamp(math.min(ArmorColor.b+FrameTime()*FlashFade,AccentColor.b),0,255)
		end
		
		if ArmorColor.a>AccentColor.a then
			ArmorColor.a = math.Clamp(math.max(ArmorColor.a-FrameTime()*FlashFade,AccentColor.a),0,255)
		elseif ArmorColor.a<AccentColor.a then
			ArmorColor.a = math.Clamp(math.min(ArmorColor.a+FrameTime()*FlashFade,AccentColor.a),0,255)
		end
		
		if ply:Armor()<OldArmor then
			for k,v in pairs(ArmorDrainColor) do
				ArmorColor[k]=v
			end
		elseif ply:Armor()>OldArmor then
			for k,v in pairs(ArmorChargeColor) do
				ArmorColor[k]=v
			end	
		end
		
		OldArmor = ply:Armor()
		
		surface.SetDrawColor(ArmorColor)
		
		surface.DrawRect( HealthTextTable.pos[1]+textx-5, yy+12.5, ( (w/7) - (textx+iconx+19) )*armorpercent,4 )
		
		--Ammo
		
		
		xx=w*(1-HUDBounds.x)-(w/7)
		yy=h*(1-HUDBounds.y)-65
		
		DrawBlurRect( xx, yy, w/7, 65, 2, 2 )
		
		surface.SetDrawColor(BGColor)
		
		surface.DrawRect( xx, yy, w/7,65 )
		
		local AccentColorOld = table.Copy(AccentColor)
		
		surface.SetDrawColor(AccentColor)
		
		local i=5
		
		local oldalph = AccentColor.a
		
		while i<(w/7) do
			AccentColor.a=math.Clamp( math.pow(1 - ( (i-5) / (w/7) ),6 )*255 , 0, 255 )
		
			surface.SetDrawColor(AccentColor)
			
			surface.DrawLine(xx+i,yy+25,xx+i+1,yy+25)
			i=i+1
		end
		
		i=25
		
		while i>5 do
			AccentColor.a=math.Clamp( math.pow(1 - ( (i-5) / (25) ),4 )*255 , 0, 255 )
		
			surface.SetDrawColor(AccentColor)
			
			surface.DrawLine(xx+w/11,yy+i,xx+w/11,yy+i+1)
			i=i-1
		end
		
		AccentColor.a=oldalph
		
		local wep = ply:GetActiveWeapon()
		
		if IsValid(wep) and ( wep.PrintName or WeaponNames[wep:GetClass()] ) then
			GunTextTable.text = wep.PrintName or WeaponNames[wep:GetClass()]
		else
			GunTextTable.text = "Invalid Weapon"
		end
		
		GunTextTable.pos[1] = xx+5
		GunTextTable.pos[2] = yy+5
		GunTextTable.xalign = TEXT_ALIGN_LEFT
		
		GunTextTable.color = AccentColor
		
		render.SetScissorRect( xx, yy, xx+w/11, h*(1-HUDBounds.y), true )
			draw.Text(GunTextTable)
		render.SetScissorRect( 0, 0, 0, 0, false ) -- Disable after you are done
		
		yy=yy+30
		
		local wep = ply:GetActiveWeapon()
		
		if IsValid(wep) then
			
			local ammo = wep:Clip1()
			
			local ammotype = wep:GetPrimaryAmmoType()
			
			if wep.Primary and wep.Primary.Ammo then
				ammotype = wep.Primary.Ammo
			end
			
			local reserve = ply:GetAmmoCount( ammotype and ammotype or "" )
			
			local ammo2 = wep:Clip2()
			
			local ammotype2 = wep:GetSecondaryAmmoType()
			
			if wep.Secondary and wep.Secondary.Ammo then
				ammotype2 = wep.Secondary.Ammo
			end
			
			local reserve2 = ply:GetAmmoCount( ammotype2 and ammotype2 or "" )
			
			if wep.Primary and wep.Primary.RPM then
				BulletShiftSpeed = math.max(0.5*(wep.Primary.RPM)/500,0.35)
			else
				BulletShiftSpeed = 1
			end
			
			if wep != OldWeapon then
				TFAHudBulletsPopulate()
			elseif ammo != OldAmmo and ammo>=0 then
				if ammo<OldAmmo then
					while (#HUDBullets>ammo and #HUDBullets>0) do
						local bul = HUDBullets[1]
						
						local hspd = -math.random(150,300)
						local vspd = -math.random(200,300)
						TFAHudAddBulletParticle(bul.sprite,bul.x,bul.y,Vector(hspd,vspd,0),math.sqrt(math.abs(hspd*400)),0.025,0.01)
						table.remove(HUDBullets,1)
					end
				else
					TFAHudBulletsPopulate()
				end
			end
			
			TFAHudBulletsProcess()
			
			if ammo>=0 then
			
				render.SetScissorRect( xx, yy, xx+w/7-1, h*(1-HUDBounds.y), true )
					for k,v in ipairs(HUDBullets) do
						surface.SetDrawColor( AccentColor )
						local spritetbl,sprite,spritew,spriteh, bulx, buly
						spritetbl = BulletSprites[v.sprite]
						sprite = spritetbl.sprite
						spritew = spritetbl.w
						spriteh = spritetbl.h		
						surface.SetTexture( sprite	) -- If you use Material, cache it!
						bulx = xx + v.x
						buly = yy + v.y
						surface.DrawTexturedRect( bulx,buly,spritew,spriteh)		
					end		
			end
			
			render.SetScissorRect( xx, yy-30, xx+w/7-1, h*(1-HUDBounds.y), true )
			
				yy=yy-28
				
				if ( tostring(ammotype) != "-1" ) then
					if ammo >= 0 then
						GunTextTable.text = "/"
						GunTextTable.xalign = TEXT_ALIGN_CENTER
						GunTextTable.pos[1] = xx+9*w/77
						GunTextTable.pos[2] = yy
						
						draw.Text(GunTextTable)
						
						GunTextTable.text = ammo	
						GunTextTable.xalign = TEXT_ALIGN_RIGHT
						GunTextTable.pos[1] = GunTextTable.pos[1]-5
						
						draw.Text(GunTextTable)
						
						GunTextTable.text = reserve	
						GunTextTable.xalign = TEXT_ALIGN_LEFT
						GunTextTable.pos[1] = GunTextTable.pos[1]+10
						
						draw.Text(GunTextTable)
						yy=yy+14
					elseif reserve>=0 then
						GunTextTable.text = reserve
						GunTextTable.xalign = TEXT_ALIGN_CENTER
						GunTextTable.pos[1] = xx+9*w/77
						GunTextTable.pos[2] = yy
						
						draw.Text(GunTextTable)
						
						yy=yy+14
					end
				end
				
				if string.lower(ammotype2) != "none" and ammotype != ammotype2 and tostring(ammotype2) != "-1" then
					if ammo2 >= 0 then
						GunTextTable.text = "/"
						GunTextTable.xalign = TEXT_ALIGN_CENTER
						GunTextTable.pos[1] = xx+9*w/77
						GunTextTable.pos[2] = yy
						
						draw.Text(GunTextTable)
						
						GunTextTable.text = ammo2
						GunTextTable.xalign = TEXT_ALIGN_RIGHT
						GunTextTable.pos[1] = GunTextTable.pos[1]-5
						
						draw.Text(GunTextTable)
						
						GunTextTable.text = reserve2
						GunTextTable.xalign = TEXT_ALIGN_LEFT
						GunTextTable.pos[1] = GunTextTable.pos[1]+10
						
						draw.Text(GunTextTable)
					elseif reserve2>-1 then
						
						GunTextTable.text = reserve2
						GunTextTable.xalign = TEXT_ALIGN_CENTER
						GunTextTable.pos[1] = xx+9*w/77
						GunTextTable.pos[2] = yy
						
						draw.Text(GunTextTable)
					
					end
					
				end
			
			render.SetScissorRect( 0, 0, 0, 0, false ) -- Disable after you are done
			
			yy=yy+30
			
			for k,v in ipairs(HUDBulletParticles) do
				surface.SetDrawColor( AccentColor )
				local spritetbl,sprite,spritew,spriteh, bulx, buly, bulrot
				spritetbl = BulletSprites[v.sprite]
				sprite = spritetbl.sprite_spent
				spritew = spritetbl.w_spent
				spriteh = spritetbl.h_spent		
				surface.SetTexture( sprite	) -- If you use Material, cache it!
				bulx = xx + v.x
				buly = yy + v.y
				bulrot = v.rotation
				surface.DrawTexturedRectRotated( bulx,buly,spritew,spriteh,bulrot)		
			end	
			
			OldAmmo = ammo
			
		end
		
		OldWeapon = wep
		
		--Compass
		
		xx=w*HUDBounds.x
		yy=h-h*(HUDBounds.y)
		
		yy=yy-20
		
		local plyang = EyeAngles()
		plyang:Normalize()
		
		local compasspad =0-- w/3
		
		local compasswidth = ScrW()/7
		
		DrawBlurRect( xx+compasspad, yy, compasswidth , 20, 2, 2 )
		
		surface.SetDrawColor(BGColor)
		
		surface.DrawRect( xx, yy, w/6.8,22 )
		
		
		CompassTextTable.pos = {xx+5,yy+2}
		
		CompassTextTable.text = "D"
		
		CompassTextTable.font =  "Half Life 2"
		
		CompassTextTable.xalign = TEXT_ALIGN_LEFT
		CompassTextTable.yalign = TEXT_ALIGN_CENTER
		
		CompassTextTable.color = AccentColor
		
		iconx,icony = draw.Text( CompassTextTable )
		
		CompassTextTable.pos[1] = CompassTextTable.pos[1]+iconx+textx/2- -11
		
		CompassTextTable.pos[2] = CompassTextTable.pos[2]- -7
		
		CompassTextTable.xalign = TEXT_ALIGN_CENTER
		CompassTextTable.yalign = TEXT_ALIGN_CENTER
		
		local deg = math.ceil(plyang.y-90)
		
		while deg<0 do
			deg=deg+360
		end
		
		while deg>360 do
			deg=deg-360
		end
		
		CompassTextTable.text =  tostring(math.abs(deg))
		
		CompassTextTable.text = string.sub(CompassTextTable.text,1,math.min(string.len(CompassTextTable.text),3))
		
		CompassTextTable.font =  "DermaDefault"
		
		iconx,icony = draw.Text( CompassTextTable )
		
		compasspad = CompassTextTable.pos[1]+textx-5-xx
		
		compasswidth = ( (w/7) - (textx+iconx+19) )
		
		local i=1
		
		local directioncounter = 3
		
		surface.SetDrawColor( AccentColor )
		draw.NoTexture()
			
		render.SetScissorRect( xx+compasspad, yy, xx+compasspad+compasswidth , yy+20, true ) -- Disable after you are done
		
		xx=xx+math.Round(compasspad-compasswidth*3/2)
		
		xx = xx + plyang.y/180 * compasswidth
		
		ArmorTextTable.font =  "Half Life 2"
		
		while i<=18 do
			local txt = CompassDirections[directioncounter]
		
			draw_circle(math.floor(xx),yy+10,3,24)
			
			CompassTextTable.color = AccentColor
			
			CompassTextTable.xalign = TEXT_ALIGN_RIGHT
			
			CompassTextTable.text = string.sub(txt,1,1)
			
			CompassTextTable.pos[1] = math.floor(xx)-5
			
			CompassTextTable.pos[2] = yy+10
			
			draw.Text(CompassTextTable)
			
			CompassTextTable.pos[1] = math.floor(xx)+5
			
			CompassTextTable.xalign = TEXT_ALIGN_LEFT
			
			CompassTextTable.text = string.sub(txt,2,2)
			
			draw.Text(CompassTextTable)
			
			xx=xx+math.Round(compasswidth/4)
			
			i=i+1
			directioncounter = directioncounter+1
			if directioncounter>#CompassDirections then
				directioncounter = 1
			end
		end
			
		render.SetScissorRect( 0, 0, 0, 0, false ) -- Disable after you are done
		
	end

	hook.Add( 'HUDShouldDraw', 'TFAHideHud', TFAHideHud )

	hook.Add( 'HUDPaint', 'TFAHudDraw', TFAHudDraw )

	hook.Add( 'PlayerSpawn', 'TFAHudBulletsPopulate_WeaponSwitch', TFAHudBulletsPopulate)

	TFAHudBulletsPopulate()
end

