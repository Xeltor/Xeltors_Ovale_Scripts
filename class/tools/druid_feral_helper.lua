local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "Feralhelp"
	local desc = "[Xel][7.0.3] Spellhelper: Feral"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_druid_disembowel) # rake
	Texture(spell_druid_thrash) # thrash_cat
	Texture(spell_shadow_vampiricaura) # shred
	Texture(ability_ghoulfrenzy) # rip
	Texture(ability_druid_ferociousbite) # ferocious_bite
	Texture(inv_misc_monsterclaw_03) # swipe_cat
	Texture(spell_nature_starfall) # moonfire
	Texture(inv_bone_skull_04) # skull_bash_cat (silence)
	Texture(ability_druid_mangle) # Maim (stun)
	
	# Buffs
	Texture(ability_druid_catform) # cat_form
	Texture(ability_druid_travelform) # travel_form
	Texture(ability_druid_prowl) # prowl
	Texture(ability_mount_jungletiger) # tigers_fury
	Texture(ability_druid_berserk) # Berserk
	Texture(spell_nature_resistnature) # regrowth
	
	# Items
	Texture(inv_jewelry_talisman_12) # Link to a trinket macro
	
	# Talents
	Texture(spell_nature_natureblessing) # Renewal (T2)
	Texture(spell_druid_displacement) # Displacer Beast (T2)
	Texture(spell_druid_feralchargecat) # Wild Charge (Cat)(T2)
	Texture(ability_hunter_pet_bear) # Wild Charge (Bear)(T2)
	Texture(ability_druid_bash) # Mighty Bash (T4) (Stun)
	Texture(spell_druid_massentanglement) # Mass Entanglement (T4)
	Texture(ability_druid_typhoon) # Typhoon (T4)
	Texture(spell_druid_incarnation) # Incarnation (T5)
	Texture(ability_druid_skinteeth) # Savage Roar (T5)
	Texture(spell_holy_elunesgrace) # Elune's Guidance (T6)
	Texture(ability_druid_ravage) # Brutal Slash (T7)
	
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
	Texture(ability_ambush) # Shadowmeld (Night elf)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
]]

	OvaleScripts:RegisterScript("DRUID", "feral", name, desc, code, "script")
end
