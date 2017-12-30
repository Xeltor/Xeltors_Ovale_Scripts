local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "MWWhelp"
	local desc = "[Xel][7.0] Spellhelper: Windwalker"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_monk_tigerpalm) # Tiger Palm
	Texture(ability_monk_roundhousekick) # Blackout Kick
	Texture(ability_monk_risingsunkick) # Rising Sun Kick
	Texture(monk_ability_fistoffury) # Fists of Fury
	Texture(ability_monk_cranekick_new) # Spinning Crane Kick
	Texture(ability_monk_touchofdeath) # Touch of Death
	Texture(ability_monk_spearhand) # Spear Hand Strike
	Texture(ability_monk_paralysis) # Paralysis
	
	# Buffs
	Texture(spell_nature_giftofthewild) # Storm, Earth, and Fire
	
	# Artifact
	Texture(inv_hand_1h_artifactskywall_d_01) # Strike of the Windlord

	# Talents
	Texture(spell_arcane_arcanetorrent) # Chi Burst (T1)
	Texture(ability_monk_chiwave) # Chi Wave (T1)
	Texture(ability_monk_quitornado) # Chi Torpedo (T2)
	Texture(ability_monk_tigerslust) # Tiger's Lust (T2)
	Texture(ability_monk_energizingwine) # Energizing Elixir (T3)
	Texture(spell_monk_ringofpeace) # Ring of Peace (T4)
	Texture(ability_monk_legsweep) # Leg Sweep (T4)
	Texture(ability_monk_jasmineforcetea) # Healing Elixir (T5)
	Texture(spell_monk_diffusemagic) # Diffuse Magic (T5)
	Texture(ability_monk_dampenharm) # Dampen Harm (T5)
	Texture(ability_monk_rushingjadewind) # Rushing Jade Wind (T6)
	Texture(ability_monk_summontigerstatue) # Invoke Xuen, the White Tiger (T6)
	Texture(ability_monk_hurricanestrike) # Whirling Dragon Punch (T7)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(ability_warstomp) # War Stomp (Tauren)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(pandarenracial_quiveringpain) # Quaking Palm (Pandaren)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_shadow_charm) # Every Man for Himself (Human)
	Texture(spell_holy_holyprotection) # Gift of the Naaru (Draenei)
	Texture(ability_rogue_trip) # Escape Artist (Gnome)
	Texture(ability_ambush) # Shadowmeld (Night Elf)
	
	# Legendary Rings
	Texture(inv_60legendary_ring1c) # Maalus / Thorasus
	Texture(inv_60legendary_ring1e) # Nithramus
	Texture(inv_60legendary_ring1a) # Etheralus
	Texture(inv_60legendary_ring1b) # Sanctus
	
	
### Required symbols
# arcane_torrent_chi
# berserking
# blackout_kick
# blood_fury_apsp
# bok_proc_buff
# chi_brew
# chi_burst
# chi_wave
# draenic_agility_potion
# energizing_elixir
# fists_of_fury
# gale_burst
# invoke_xuen
# legendary_ring_agility
# rising_sun_kick
# rushing_jade_wind
# serenity
# serenity_buff
# serenity_talent
# spinning_crane_kick
# storm_earth_and_fire
# storm_earth_and_fire_buff
# strike_of_the_windlord
# tiger_palm
# touch_of_death
# whirling_dragon_punch
}
]]

	OvaleScripts:RegisterScript("MONK", "windwalker", name, desc, code, "script")
end
