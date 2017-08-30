local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_frost"
	local desc = "[Xel][7.1] Mage: Frost"
	local code = [[
# Based on SimulationCraft profile "Mage_Frost_T19P".
#	class=mage
#	spec=frost
#	talents=1121113

Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_mage_spells)

Define(frostjaw 102051)
Define(ice_block_buff 45438)

AddIcon specialization=3 help=main
{
	if InCombat() InterruptActions()
	
	if BuffExpires(ice_barrier) and IncomingDamage(5) > 0 and not mounted() and not { target.Classification(worldboss) or BuffPresent(burst_haste_buff any=1) } Spell(ice_barrier)
	
	if InCombat() and target.InRange(frostbolt) and HasFullControl()
	{
		if BuffExpires(ice_floes_buff) and not NotMoving() Spell(ice_floes)
		
		# Cooldowns
		if Boss()
		{
			if NotMoving() FrostDefaultCdActions()
		}
		if NotMoving() FrostDefaultShortCdActions()
		if NotMoving() FrostDefaultMainActions()
		#ice_lance,moving=1
		if Speed() > 0 Spell(ice_lance)
	}
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(counterspell) Spell(counterspell)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_mana)
			if target.InRange(quaking_palm) Spell(quaking_palm)
		}
	}
}

AddFunction NotMoving
{
	{Speed() ==0 or BuffPresent(ice_floes_buff)}
}

### actions.default

AddFunction FrostDefaultMainActions
{
	#ice_lance,if=buff.fingers_of_frost.react=0&prev_gcd.1.flurry&spell_haste<0.845
	if BuffStacks(fingers_of_frost_buff) == 0 and PreviousGCDSpell(flurry) and 100 / { 100 + SpellHaste() } < 0.845 Spell(ice_lance)
	#call_action_list,name=cooldowns
	FrostCooldownsMainActions()

	unless FrostCooldownsMainPostConditions()
	{
		#call_action_list,name=aoe,if=active_enemies>=4
		if Enemies(tagged=1) >= 4 FrostAoeMainActions()

		unless Enemies(tagged=1) >= 4 and FrostAoeMainPostConditions()
		{
			#call_action_list,name=single
			FrostSingleMainActions()
		}
	}
}

AddFunction FrostDefaultMainPostConditions
{
	FrostCooldownsMainPostConditions() or Enemies(tagged=1) >= 4 and FrostAoeMainPostConditions() or FrostSingleMainPostConditions()
}

AddFunction FrostDefaultShortCdActions
{
	unless BuffStacks(fingers_of_frost_buff) == 0 and PreviousGCDSpell(flurry) and 100 / { 100 + SpellHaste() } < 0.845 and Spell(ice_lance)
	{
		#call_action_list,name=cooldowns
		FrostCooldownsShortCdActions()

		unless FrostCooldownsShortCdPostConditions()
		{
			#call_action_list,name=aoe,if=active_enemies>=4
			if Enemies(tagged=1) >= 4 FrostAoeShortCdActions()

			unless Enemies(tagged=1) >= 4 and FrostAoeShortCdPostConditions()
			{
				#call_action_list,name=single
				FrostSingleShortCdActions()
			}
		}
	}
}

AddFunction FrostDefaultShortCdPostConditions
{
	BuffStacks(fingers_of_frost_buff) == 0 and PreviousGCDSpell(flurry) and 100 / { 100 + SpellHaste() } < 0.845 and Spell(ice_lance) or FrostCooldownsShortCdPostConditions() or Enemies(tagged=1) >= 4 and FrostAoeShortCdPostConditions() or FrostSingleShortCdPostConditions()
}

AddFunction FrostDefaultCdActions
{
	#counterspell,if=target.debuff.casting.react
	# if target.IsInterruptible() FrostInterruptActions()

	unless BuffStacks(fingers_of_frost_buff) == 0 and PreviousGCDSpell(flurry) and 100 / { 100 + SpellHaste() } < 0.845 and Spell(ice_lance)
	{
		#time_warp,if=(time=0&buff.bloodlust.down)|(buff.bloodlust.down&equipped.132410&(cooldown.icy_veins.remains<1|target.time_to_die<50))
		# if { TimeInCombat() == 0 and BuffExpires(burst_haste_buff any=1) or BuffExpires(burst_haste_buff any=1) and HasEquippedItem(132410) and { SpellCooldown(icy_veins) < 1 or target.TimeToDie() < 50 } } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) Spell(time_warp)
		#call_action_list,name=cooldowns
		FrostCooldownsCdActions()

		unless FrostCooldownsCdPostConditions()
		{
			#call_action_list,name=aoe,if=active_enemies>=4
			if Enemies(tagged=1) >= 4 FrostAoeCdActions()

			unless Enemies(tagged=1) >= 4 and FrostAoeCdPostConditions()
			{
				#call_action_list,name=single
				FrostSingleCdActions()
			}
		}
	}
}

AddFunction FrostDefaultCdPostConditions
{
	BuffStacks(fingers_of_frost_buff) == 0 and PreviousGCDSpell(flurry) and 100 / { 100 + SpellHaste() } < 0.845 and Spell(ice_lance) or FrostCooldownsCdPostConditions() or Enemies(tagged=1) >= 4 and FrostAoeCdPostConditions() or FrostSingleCdPostConditions()
}

### actions.aoe

AddFunction FrostAoeMainActions
{
	#frostbolt,if=prev_off_gcd.water_jet
	if PreviousOffGCDSpell(water_elemental_water_jet) Spell(frostbolt)
	#blizzard
	Spell(blizzard)
	#ice_nova
	Spell(ice_nova)
	#flurry,if=(buff.brain_freeze.react|prev_gcd.1.ebonbolt)&buff.fingers_of_frost.react=0
	if { BuffPresent(brain_freeze_buff) or PreviousGCDSpell(ebonbolt) } and BuffStacks(fingers_of_frost_buff) == 0 Spell(flurry)
	#ice_lance,if=buff.fingers_of_frost.react>0
	if BuffStacks(fingers_of_frost_buff) > 0 Spell(ice_lance)
	#glacial_spike
	Spell(glacial_spike)
	#frostbolt
	Spell(frostbolt)
}

AddFunction FrostAoeMainPostConditions
{
}

AddFunction FrostAoeShortCdActions
{
	unless PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or Spell(blizzard)
	{
		#frozen_orb
		Spell(frozen_orb)
		#comet_storm
		Spell(comet_storm)

		unless Spell(ice_nova)
		{
			#water_jet,if=prev_gcd.1.frostbolt&buff.fingers_of_frost.stack<(2+artifact.icy_hand.enabled)&buff.brain_freeze.react=0
			if PreviousGCDSpell(frostbolt) and BuffStacks(fingers_of_frost_buff) < 2 + HasArtifactTrait(icy_hand) and BuffStacks(brain_freeze_buff) == 0 Spell(water_elemental_water_jet)

			unless { BuffPresent(brain_freeze_buff) or PreviousGCDSpell(ebonbolt) } and BuffStacks(fingers_of_frost_buff) == 0 and Spell(flurry)
			{
				#frost_bomb,if=debuff.frost_bomb.remains<action.ice_lance.travel_time&buff.fingers_of_frost.react>0
				if target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and BuffStacks(fingers_of_frost_buff) > 0 Spell(frost_bomb)

				unless BuffStacks(fingers_of_frost_buff) > 0 and Spell(ice_lance)
				{
					#ebonbolt,if=buff.brain_freeze.react=0
					if BuffStacks(brain_freeze_buff) == 0 Spell(ebonbolt)
				}
			}
		}
	}
}

AddFunction FrostAoeShortCdPostConditions
{
	PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or Spell(blizzard) or Spell(ice_nova) or { BuffPresent(brain_freeze_buff) or PreviousGCDSpell(ebonbolt) } and BuffStacks(fingers_of_frost_buff) == 0 and Spell(flurry) or BuffStacks(fingers_of_frost_buff) > 0 and Spell(ice_lance) or Spell(glacial_spike) or Spell(frostbolt)
}

AddFunction FrostAoeCdActions
{
}

AddFunction FrostAoeCdPostConditions
{
	PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or Spell(blizzard) or Spell(frozen_orb) or Spell(comet_storm) or Spell(ice_nova) or { BuffPresent(brain_freeze_buff) or PreviousGCDSpell(ebonbolt) } and BuffStacks(fingers_of_frost_buff) == 0 and Spell(flurry) or target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and BuffStacks(fingers_of_frost_buff) > 0 and Spell(frost_bomb) or BuffStacks(fingers_of_frost_buff) > 0 and Spell(ice_lance) or BuffStacks(brain_freeze_buff) == 0 and Spell(ebonbolt) or Spell(glacial_spike) or Spell(frostbolt)
}

### actions.cooldowns

AddFunction FrostCooldownsMainActions
{
}

AddFunction FrostCooldownsMainPostConditions
{
}

AddFunction FrostCooldownsShortCdActions
{
	#rune_of_power,if=cooldown.icy_veins.remains<cast_time|charges_fractional>1.9&cooldown.icy_veins.remains>10|buff.icy_veins.up|target.time_to_die.remains+5<charges_fractional*10
	if SpellCooldown(icy_veins) < CastTime(rune_of_power) or Charges(rune_of_power count=0) > 1.9 and SpellCooldown(icy_veins) > 10 or BuffPresent(icy_veins_buff) or target.TimeToDie() + 5 < Charges(rune_of_power count=0) * 10 Spell(rune_of_power)
}

AddFunction FrostCooldownsShortCdPostConditions
{
}

AddFunction FrostCooldownsCdActions
{
	unless { SpellCooldown(icy_veins) < CastTime(rune_of_power) or Charges(rune_of_power count=0) > 1.9 and SpellCooldown(icy_veins) > 10 or BuffPresent(icy_veins_buff) or target.TimeToDie() + 5 < Charges(rune_of_power count=0) * 10 } and Spell(rune_of_power)
	{
		#potion,name=deadly_grace,if=cooldown.icy_veins.remains<1&active_enemies=1
		#potion,name=prolonged_power,if=cooldown.icy_veins.remains<1
		#icy_veins,if=buff.icy_veins.down
		if BuffExpires(icy_veins_buff) Spell(icy_veins)
		#mirror_image
		Spell(mirror_image)
		#blood_fury
		Spell(blood_fury_sp)
		#berserking
		Spell(berserking)
		#arcane_torrent
		Spell(arcane_torrent_mana)
	}
}

AddFunction FrostCooldownsCdPostConditions
{
	{ SpellCooldown(icy_veins) < CastTime(rune_of_power) or Charges(rune_of_power count=0) > 1.9 and SpellCooldown(icy_veins) > 10 or BuffPresent(icy_veins_buff) or target.TimeToDie() + 5 < Charges(rune_of_power count=0) * 10 } and Spell(rune_of_power)
}

### actions.precombat

AddFunction FrostPrecombatMainActions
{
	#flask,type=flask_of_the_whispered_pact
	#food,type=azshari_salad
	#augmentation,type=defiled
	Spell(augmentation)
	#potion,name=deadly_grace
	#frostbolt
	Spell(frostbolt)
}

AddFunction FrostPrecombatMainPostConditions
{
}

AddFunction FrostPrecombatShortCdActions
{
	unless Spell(augmentation)
	{
		#water_elemental
		if not pet.Present() Spell(water_elemental)
	}
}

AddFunction FrostPrecombatShortCdPostConditions
{
	Spell(augmentation) or Spell(frostbolt)
}

AddFunction FrostPrecombatCdActions
{
	unless Spell(augmentation) or not pet.Present() and Spell(water_elemental)
	{
		#snapshot_stats
		#mirror_image
		Spell(mirror_image)
	}
}

AddFunction FrostPrecombatCdPostConditions
{
	Spell(augmentation) or not pet.Present() and Spell(water_elemental) or Spell(frostbolt)
}

### actions.single

AddFunction FrostSingleMainActions
{
	#ice_nova,if=debuff.winters_chill.up
	if target.DebuffPresent(winters_chill_debuff) Spell(ice_nova)
	#frostbolt,if=prev_off_gcd.water_jet
	if PreviousOffGCDSpell(water_elemental_water_jet) Spell(frostbolt)
	#ray_of_frost,if=buff.icy_veins.up|(cooldown.icy_veins.remains>action.ray_of_frost.cooldown&buff.rune_of_power.down)
	if BuffPresent(icy_veins_buff) or SpellCooldown(icy_veins) > SpellCooldown(ray_of_frost) and BuffExpires(rune_of_power_buff) Spell(ray_of_frost)
	#flurry,if=(buff.brain_freeze.react|prev_gcd.1.ebonbolt)&buff.fingers_of_frost.react=0
	if { BuffPresent(brain_freeze_buff) or PreviousGCDSpell(ebonbolt) } and BuffStacks(fingers_of_frost_buff) == 0 Spell(flurry)
	#ice_lance,if=buff.fingers_of_frost.react>0&cooldown.icy_veins.remains>10|buff.fingers_of_frost.react>2
	if BuffStacks(fingers_of_frost_buff) > 0 and SpellCooldown(icy_veins) > 10 or BuffStacks(fingers_of_frost_buff) > 2 Spell(ice_lance)
	#ice_nova
	Spell(ice_nova)
	#blizzard,if=talent.arctic_gale.enabled|active_enemies>1|(buff.zannesu_journey.stack=5&buff.zannesu_journey.remains>cast_time)
	if Talent(arctic_gale_talent) or Enemies(tagged=1) > 1 or BuffStacks(zannesu_journey_buff) == 5 and BuffRemaining(zannesu_journey_buff) > CastTime(blizzard) Spell(blizzard)
	#glacial_spike
	Spell(glacial_spike)
	#frostbolt
	Spell(frostbolt)
}

AddFunction FrostSingleMainPostConditions
{
}

AddFunction FrostSingleShortCdActions
{
	unless target.DebuffPresent(winters_chill_debuff) and Spell(ice_nova) or PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt)
	{
		#water_jet,if=prev_gcd.1.frostbolt&buff.fingers_of_frost.stack<(2+artifact.icy_hand.enabled)&buff.brain_freeze.react=0
		if PreviousGCDSpell(frostbolt) and BuffStacks(fingers_of_frost_buff) < 2 + HasArtifactTrait(icy_hand) and BuffStacks(brain_freeze_buff) == 0 Spell(water_elemental_water_jet)

		unless { BuffPresent(icy_veins_buff) or SpellCooldown(icy_veins) > SpellCooldown(ray_of_frost) and BuffExpires(rune_of_power_buff) } and Spell(ray_of_frost) or { BuffPresent(brain_freeze_buff) or PreviousGCDSpell(ebonbolt) } and BuffStacks(fingers_of_frost_buff) == 0 and Spell(flurry)
		{
			#frost_bomb,if=debuff.frost_bomb.remains<action.ice_lance.travel_time&buff.fingers_of_frost.react>0
			if target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and BuffStacks(fingers_of_frost_buff) > 0 Spell(frost_bomb)

			unless { BuffStacks(fingers_of_frost_buff) > 0 and SpellCooldown(icy_veins) > 10 or BuffStacks(fingers_of_frost_buff) > 2 } and Spell(ice_lance)
			{
				#frozen_orb
				Spell(frozen_orb)

				unless Spell(ice_nova)
				{
					#comet_storm
					Spell(comet_storm)

					unless { Talent(arctic_gale_talent) or Enemies(tagged=1) > 1 or BuffStacks(zannesu_journey_buff) == 5 and BuffRemaining(zannesu_journey_buff) > CastTime(blizzard) } and Spell(blizzard)
					{
						#ebonbolt,if=buff.brain_freeze.react=0
						if BuffStacks(brain_freeze_buff) == 0 Spell(ebonbolt)
					}
				}
			}
		}
	}
}

AddFunction FrostSingleShortCdPostConditions
{
	target.DebuffPresent(winters_chill_debuff) and Spell(ice_nova) or PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or { BuffPresent(icy_veins_buff) or SpellCooldown(icy_veins) > SpellCooldown(ray_of_frost) and BuffExpires(rune_of_power_buff) } and Spell(ray_of_frost) or { BuffPresent(brain_freeze_buff) or PreviousGCDSpell(ebonbolt) } and BuffStacks(fingers_of_frost_buff) == 0 and Spell(flurry) or { BuffStacks(fingers_of_frost_buff) > 0 and SpellCooldown(icy_veins) > 10 or BuffStacks(fingers_of_frost_buff) > 2 } and Spell(ice_lance) or Spell(ice_nova) or { Talent(arctic_gale_talent) or Enemies(tagged=1) > 1 or BuffStacks(zannesu_journey_buff) == 5 and BuffRemaining(zannesu_journey_buff) > CastTime(blizzard) } and Spell(blizzard) or Spell(glacial_spike) or Spell(frostbolt)
}

AddFunction FrostSingleCdActions
{
}

AddFunction FrostSingleCdPostConditions
{
	target.DebuffPresent(winters_chill_debuff) and Spell(ice_nova) or PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or { BuffPresent(icy_veins_buff) or SpellCooldown(icy_veins) > SpellCooldown(ray_of_frost) and BuffExpires(rune_of_power_buff) } and Spell(ray_of_frost) or { BuffPresent(brain_freeze_buff) or PreviousGCDSpell(ebonbolt) } and BuffStacks(fingers_of_frost_buff) == 0 and Spell(flurry) or target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and BuffStacks(fingers_of_frost_buff) > 0 and Spell(frost_bomb) or { BuffStacks(fingers_of_frost_buff) > 0 and SpellCooldown(icy_veins) > 10 or BuffStacks(fingers_of_frost_buff) > 2 } and Spell(ice_lance) or Spell(frozen_orb) or Spell(ice_nova) or Spell(comet_storm) or { Talent(arctic_gale_talent) or Enemies(tagged=1) > 1 or BuffStacks(zannesu_journey_buff) == 5 and BuffRemaining(zannesu_journey_buff) > CastTime(blizzard) } and Spell(blizzard) or BuffStacks(brain_freeze_buff) == 0 and Spell(ebonbolt) or Spell(glacial_spike) or Spell(frostbolt)
}
]]

	OvaleScripts:RegisterScript("MAGE", "frost", name, desc, code, "script")
end
