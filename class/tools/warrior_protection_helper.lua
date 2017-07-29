local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "WARRPROThelp"
	local desc = "[Xel][7.x] Spellhelper: Protection"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(inv_sword_11) # Devastate
	Texture(ability_warrior_focusedrage) # Focused Rage
	Texture(inv_shield_05) # Shield Slam
	Texture(ability_warrior_revenge) # Revenge
	Texture(spell_nature_thunderclap) # Thunder Clap
	Texture(ability_warrior_devastate) # Victory Rush
	Texture(ability_warrior_victoryrush) # Intercept
	Texture(inv_axe_66) # Heroic Throw
	Texture(inv_gauntlets_04) # Pummel

	# Buffs
	Texture(ability_warrior_renewedvigor) # Ignore Pain
	Texture(ability_defend) # Shield Block
	Texture(warrior_talent_icon_innerrage) # Battle Cry
	Texture(spell_nature_ancestralguardian) # Berserker Rage
	Texture(ability_warrior_warcry) # Demoralizing Shout
	Texture(spell_holy_ashestoashes) # Last Stand
	Texture(ability_warrior_shieldwall) # Shield Wall

	# Artifact
	Texture(inv_shield_1h_artifactmagnar_d_01) # Neltharion's Fury

	# Talents
	Texture(ability_warrior_shockwave) # Shockwave (T1)
	Texture(warrior_talent_icon_stormbolt) # Storm Bolt (T1)
	Texture(spell_impending_victory) # Impending Victory (T2) (replaces Victroy Rush)
	Texture(warrior_talent_icon_avatar) # Avatar (T3)
	Texture(warrior_talent_icon_ravager) # Ravager (T7)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(ability_warstomp) # War Stomp (Tauren)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(inv_gizmo_rocketlauncher) # Rocket Barrage (Goblin)
	Texture(pandarenracial_quiveringpain) # Quaking Palm (Pandaren)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_shadow_charm) # Every Man for Himself (Human)
	Texture(spell_holy_holyprotection) # Gift of the Naaru (Draenei)
	Texture(ability_racial_darkflight) # Darkflight (Worgen)
	Texture(ability_rogue_trip) # Escape Artist (Gnome)
	Texture(ability_ambush) # Shadowmeld (Night Elf)
	
	# Legendary Rings
	Texture(inv_60legendary_ring1c) # Maalus / Thorasus
	Texture(inv_60legendary_ring1e) # Nithramus
	Texture(inv_60legendary_ring1a) # Etheralus
	Texture(inv_60legendary_ring1b) # Sanctus
}
]]

	OvaleScripts:RegisterScript("WARRIOR", "protection", name, desc, code, "script")
end
