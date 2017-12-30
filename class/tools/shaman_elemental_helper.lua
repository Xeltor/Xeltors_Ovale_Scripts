local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "SHAWMUNELEMhelp"
	local desc = "[Xel][7.x] Spellhelper: Elemental"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_nature_lightning) # Lightning Bolt
	Texture(spell_nature_chainlightning) # Chain Lightning
	Texture(ability_mage_firestarter) # Lava Beam (Ascendance Chain Lightning)
	Texture(spell_shaman_lavaburst) # Lava Burst
	Texture(spell_fire_flameshock) # Flame Shock
	Texture(spell_nature_earthshock) # Earth Shock
	Texture(spell_frost_frostshock) # Frost Shock
	Texture(spell_nature_cyclone) # Wind Shear

	# Buffs
	Texture(spell_fire_elemental_totem) # Fire Elemental Totem
	Texture(spell_nature_earthelemental_totem) # Earth Elemental Totem
	
	# Artifact
	Texture(inv_hand_1h_artifactstormfist_d_01) # Stormkeeper

	# Talents
	Texture(spell_nature_wrathofair_totem) # Totem Mastery (T1)
	Texture(ability_skyreach_four_wind) # Gust of Wind (T2)
	Texture(ability_shaman_ancestralguidance) # Ancestral Guidance (T2)
	Texture(ability_shaman_windwalktotem) # Wind Rush Totem (T2)
	Texture(spell_nature_brilliance) # Lightning Surge Totem (T3)
	Texture(spell_nature_stranglevines) # Earthgrab Totem (T3)
	Texture(spell_totem_wardofdraining) # Voodoo Totem (T3)
	Texture(shaman_talent_elementalblast) # Elemental Blast (T4)
	Texture(spell_frost_iceshard) # Icefury (T5)
	Texture(spell_nature_wispheal) # Elemental Mastery (T6)
	Texture(spell_shaman_measuredinsight) # Storm Elemental (T6)
	Texture(spell_fire_elementaldevastation) # Ascendance (T7)
	Texture(spell_shaman_spewlava) # Liquid Magma Totem (T7)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(ability_warstomp) # War Stomp (Tauren)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(inv_gizmo_rocketlauncher) # Rocket Barrage (Goblin)
	Texture(pandarenracial_quiveringpain) # Quaking Palm (Pandaren)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_holy_holyprotection) # Gift of the Naaru (Draenei)
	
	# Legendary Rings
	Texture(inv_60legendary_ring1c) # Maalus / Thorasus
	Texture(inv_60legendary_ring1e) # Nithramus
	Texture(inv_60legendary_ring1a) # Etheralus
	Texture(inv_60legendary_ring1b) # Sanctus
}
]]

	OvaleScripts:RegisterScript("SHAMAN", "elemental", name, desc, code, "script")
end
