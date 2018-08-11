local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "WLKDEMOhelp"
	local desc = "[Xel][8.x] Spellhelper: Demonology"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_shadow_shadowbolt) # Shadow Bolt
	Texture(ability_warlock_handofguldan) # Hand of Gul'dan
	Texture(inv__demonbolt) # Demonbolt
	Texture(inv_implosion) # Implosion
	Texture(ability_warrior_titansgrip) # Axe Toss (command demon)
	Texture(spell_shadow_mindrot) # Spell Lock (command demon)
	
	# Survival stuff
	Texture(spell_shadow_lifedrain02) # Drain Life
	Texture(spell_shadow_lifedrain) # Health Funnel

	# Buffs
	Texture(inv_summondemonictyrant) # Summon Demonic Tyrant
	Texture(spell_warlock_calldreadstalkers) # Call Dreadstalkers

	# Talents
	Texture(ability_warlock_demonicempowerment) # Demonic Strength (T1)
	Texture(ability_hunter_pet_bat) # Bilescourge Bombers (T1)
	Texture(ability_warlock_backdraft) # Power Siphon (T2)
	Texture(spell_shadow_shadowbolt) # Doom (T2)
	Texture(inv_polearm_2h_fellord_04) # Soul Strike (T4)
	Texture(inv_argusfelstalkermount) # Summon Vilefiend (T4)
	Texture(ability_warlock_mortalcoil) # Mortal Coil (T5)
	Texture(spell_shadow_summonfelguard) # Grimoire: Felguard (T6)
	Texture(inv_netherportal) # Nether Portal (T7)

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
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "demonology", name, desc, code, "script")
end
