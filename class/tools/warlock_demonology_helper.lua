local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "WLKDEMOhelp"
	local desc = "[Xel][7.x] Spellhelper: Demonology"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_shadow_shadowbolt) # Shadow Bolt
	Texture(ability_warlock_handofguldan) # Hand of Gul'dan
	Texture(spell_shadow_auraofdarkness) # Doom
	Texture(spell_shadow_burningspirit) # Life Tap
	Texture(ability_warrior_bladestorm) # Felstorm (command demon)
	Texture(spell_shadow_mindrot) # Spell Lock (command demon)
	Texture(spell_shadow_lifedrain02) # Drain Life (Used with Voidwalker / Voidlord)
	
	# Artifact
	Texture(inv_offhand_1h_artifactskulloferedar_d_01) # Tha'kiel's Consumption

	# Buffs
	Texture(spell_warlock_demonicempowerment) # Demonic Empowerment
	Texture(spell_warlock_demonwrath) # Demonwrath
	Texture(spell_warlock_calldreadstalkers) # Call Dreadstalkers
	Texture(warlock_summon_doomguard) # Summon Doomguard
	Texture(spell_shadow_summoninfernal) # Summon Infernal
	Texture(spell_shadow_lifedrain) # Health Funnel (Used with Voidwalker / Voidlord)

	# Talents
	Texture(ability_warlock_shadowflame) # Shadowflame (T1)
	Texture(spell_shadow_shadowandflame) # Implosion (T2)
	Texture(ability_warlock_mortalcoil) # Mortal Coil (T3)
	Texture(ability_warlock_shadowfurytga) # Shadowfury (T3)
	Texture(spell_warlock_demonsoul) # Soul Harvest (T4)
	Texture(spell_shadow_summonfelguard) # Grimoire: Felguard (T6)
	Texture(achievement_boss_durumu) # Summon Darkglare (T7)
	Texture(spell_warlock_demonbolt) # Demonbolt (T7) (Replaces Shadow Bolt)

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
