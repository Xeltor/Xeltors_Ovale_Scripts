local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "WLKAFFLICTIONhelp"
	local desc = "[Xel][7.1] Spellhelper: Affliction"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_shadow_curseofsargeras) # Agony
	Texture(spell_shadow_abominationexplosion) # Corruption
	Texture(spell_shadow_unstableaffliction_3) # Unstable Affliction
	Texture(spell_shadow_lifedrain02) # Drain Life
	Texture(spell_shadow_seedofdestruction) # Seed of Corruption
	Texture(spell_shadow_mindrot) # Spel Lock (Felhunter)

	# Buffs
	Texture(spell_shadow_burningspirit) # Life Tap
	Texture(warlock_summon_doomguard) # Summon Doomguard
	Texture(spell_shadow_lifedrain) # Health Funnel
	
	# Artifact
	Texture(inv_staff_2h_artifactdeadwind_d_01) # Reap Souls
	
	# Talents
	Texture(ability_warlock_haunt) # Haunt (T1)
	Texture(spell_shadow_haunting) # Drain Soul (T1) (Replaces Drain Life)
	Texture(spell_shadow_manafeed) # Mana Tap (T2)
	Texture(spell_shadow_requiem) # Siphon Life (T4)
	Texture(spell_warlock_demonsoul) # Soul Harvest (T4)
	Texture(spell_shadow_summonfelhunter) # Grimoire of Service (T6) (Grimoire: Felhunter)
	Texture(inv_enchant_voidsphere) # Phantom Singularity (T7)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(inv_gizmo_rocketlauncher) # Rocket Barrage (Goblin)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_shadow_charm) # Every Man for Himself (Human)
	Texture(ability_racial_darkflight) # Darkflight (Worgen)
	Texture(ability_rogue_trip) # Escape Artist (Gnome)
	
	### Required symbols
	# agony
	# agony_debuff
	# arcane_torrent_mana
	# archimondes_darkness_talent
	# berserking
	# blood_fury_sp
	# cataclysm
	# cataclysm_talent
	# corruption
	# corruption_debuff
	# dark_intent
	# dark_soul_misery
	# dark_soul_misery_buff
	# demonic_servitude_talent
	# draenic_intellect_potion
	# drain_soul
	# grimoire_of_sacrifice
	# grimoire_of_sacrifice_buff
	# grimoire_of_sacrifice_talent
	# grimoire_of_service_talent
	# haunt
	# haunt_debuff
	# haunting_spirits_buff
	# kiljaedens_cunning
	# life_tap
	# mannoroths_fury
	# nithramus_buff
	# seed_of_corruption
	# seed_of_corruption_debuff
	# service_felhunter
	# soul_swap
	# soulburn
	# soulburn_buff
	# soulburn_haunt_talent
	# summon_doomguard
	# summon_felhunter
	# summon_infernal
	# unstable_affliction
	# unstable_affliction_debuff
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "affliction", name, desc, code, "script")
end
