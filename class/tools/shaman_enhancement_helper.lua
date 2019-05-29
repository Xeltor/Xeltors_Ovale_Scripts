local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "SHAWMUNENHANCEhelp"
	local desc = "[Xel][7.x] Spellhelper: Enhancement"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_nature_rockbiter) # Rockbiter
    Texture(ability_shaman_stormstrike) # Stormstrike
    Texture(spell_fire_flametounge) # Flametongue
    Texture(spell_shaman_unleashweapon_frost) # Frostbrand
    Texture(ability_shaman_lavalash) # Lava Lash
    Texture(spell_shaman_crashlightning) # Crash Lightning
    Texture(spell_nature_cyclone) # Wind Shear
	Texture(spell_nature_lightning) # Lightning Bolt

	# Buffs
	Texture(spell_shaman_feralspirit) # Feral Spirit
	Texture(spell_nature_spiritwolf) # Ghost Wolf
	
	# Items
	Texture(inv_jewelry_talisman_12) # Link to a trinket macro

	# Talents
	Texture(ability_skyreach_wind_wall) # Windsong (T1)
	Texture(ability_earthenfury_giftofearth) # Boulderfist (T1)
	Texture(spell_nature_giftofthewaterspirit) # Rainfall (T2)
	Texture(spell_beastmaster_wolf) # Feral Lunge (T2)
	Texture(ability_shaman_windwalktotem) # Wind Rush Totem (T2)
	Texture(spell_nature_brilliance) # Lightning Surge Totem (T3)
	Texture(spell_nature_stranglevines) # Earthgrab Totem (T3)
	Texture(spell_totem_wardofdraining) # Voodoo Totem (T3)
	Texture(spell_nature_lightningshield) # Lightning Shield (T4)
	Texture(ability_ironmaidens_swirlingvortex) # Fury of Air (T6)
	Texture(ability_rhyolith_lavapool) # Sundering (T6)
	Texture(spell_fire_elementaldevastation) # Ascendance (T7)
	Texture(ability_earthen_pillar) # Earthen Spike (T7)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(ability_warstomp) # War Stomp (Tauren)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(inv_gizmo_rocketlauncher) # Rocket Barrage (Goblin)
	Texture(pandarenracial_quiveringpain) # Quaking Palm (Pandaren)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_holy_holyprotection) # Gift of the Naaru (Draenei)

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
]]

	OvaleScripts:RegisterScript("SHAMAN", "enhancement", name, desc, code, "script")
end
