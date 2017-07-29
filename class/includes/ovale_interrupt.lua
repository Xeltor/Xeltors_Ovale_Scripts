local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "ovale_interrupt"
	local desc = "[7.0.3] Ovale: Common interrupt definitions"
	local code = [[
# Draenor Dungeons.
# Black Rook Hold
Define(dark_mending 225573)
Define(spirit_blast 196883)
Define(arcane_blitz 200248)

# Court of Stars
Define(sound_alarm 210261)
Define(drain_magic 209485)
Define(seal_magic 209404)
Define(searing_glare 211299)
Define(charging_station 225100)
Define(drifting_embers 211401)
Define(bewitch 211470)
Define(withering_soul 208165)

# Darkheart Thicket
Define(star_shower 200658)
Define(tormenting_fear 204246)
Define(dread_inferno 201400)

# Eye of Azshara
Define(storm 196870)
Define(arc_lightning 218532)
Define(thundering_stomp 195129)
Define(rejuvenating_waters 195046)
Define(restoration 197502)
Define(bellowing_roar 192135)
Define(aqua_spout 196027)
Define(armorshell 196175)
Define(rampage_serpentix 191848)
Define(blazing_nova 192003)

# Halls of Valor
Define(healing_light 198931)
Define(shattered_rune 198962)
Define(searing_light 192288)
Define(unruly_yell 199726)

# Maw of Souls
Define(soul_siphon 194657)
Define(torrent_of_souls 199514)
Define(void_snap 194266)
Define(bone_chilling_scream 198405)
Define(debilitating_shout_mos 195293)
Define(necrotic_bolt 198407)
Define(torrent_mos 198495)

# Neltharion's Lair
Define(stone_gaze_rokmora 202181)
Define(bound 193585)

# The Arcway
Define(eye_of_the_vortex 211007)
Define(portal_argus 211757)
Define(demonic_ascension 226285)
Define(phase_breach 211115)
Define(overcharge_mana 196392)
Define(accelerating_blast 203176)
Define(time_lock 203957)

# Vault of the Wardens
Define(furious_blast 191823)
Define(sap_soul 200905)
Define(frightening_shout_votw 201488)
Define(sear_votw 195332)

# Violet Hold
Define(lob_poison 224453)
Define(venom_nova 224460)
Define(shadow_bolt_volley 204963)

# Emerald Nightmare
Define(wave_of_decay_en 221059)
Define(spread_infestation_en 205070)
Define(dread_wrath_volley_en 223392)
Define(mind_flay_en 208697)
Define(raining_filth_en 225079)
Define(defile_eruption_en 203771)
Define(corruption_en 205300)
Define(twisted_touch_of_life_en 211368)
Define(shadow_volley_en 222939)

# Main list
SpellList(interrupt storm arc_lightning thundering_stomp rejuvenating_waters restoration bellowing_roar aqua_spout armorshell rampage_serpentix blazing_nova stone_gaze_rokmora bound healing_light shattered_rune searing_light unruly_yell star_shower tormenting_fear dread_inferno lob_poison venom_nova shadow_bolt_volley sound_alarm drain_magic seal_magic searing_glare charging_station drifting_embers bewitch withering_soul dark_mending spirit_blast arcane_blitz soul_siphon torrent_of_souls void_snap bone_chilling_scream debilitating_shout_mos necrotic_bolt torrent_mos eye_of_the_vortex portal_argus demonic_ascension phase_breach overcharge_mana accelerating_blast time_lock furious_blast sap_soul frightening_shout_votw sear_votw wave_of_decay_en spread_infestation_en dread_wrath_volley_en mind_flay_en raining_filth_en defile_eruption_en corruption_en twisted_touch_of_life_en shadow_volley_en)

]]

	OvaleScripts:RegisterScript(nil, nil, name, desc, code, "include")
end
