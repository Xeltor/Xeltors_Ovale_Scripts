local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_elemental"
	local desc = "[Xel][7.1] Shaman: Elemental"
	local code = [[
# Based on SimulationCraft profile "Shaman_Elemental_T18M".
#	class=shaman
#	spec=elemental
#	talents=3113211

Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_shaman_spells)

Define(ghost_wolf_buff 2645)

# Fixyfix
Define(earth_shock 8042)
	SpellInfo(earth_shock maelstrom=10)

# Elemental
AddIcon specialization=1 help=main
{
	if not InCombat() and not target.IsFriend() and not mounted() and target.Present()
	{
		if BuffRemaining(resonance_totem_buff) < 2 Spell(totem_mastery)
	}
	
	# Interrupt
	if InCombat() and target.Casting(interrupt) InterruptActions()
	
	if target.InRange(lightning_bolt) and HasFullControl() and InCombat()
    {
		# Cooldowns
		if Boss()
		{
			if StandingStill() ElementalDefaultCdActions()
		}
		
		# Short Cooldowns
		if StandingStill() ElementalDefaultShortCdActions()
		
		# Default rotation
		if StandingStill() ElementalDefaultMainActions()
		
		#lava_burst,moving=1
		if not StandingStill() and Enemies(tagged=1) > 2 Spell(lava_burst)
		#frost_shock,moving=1,if=buff.icefury.up
		if not StandingStill() and BuffPresent(icefury_buff) and Enemies(tagged=1) == 1 Spell(frost_shock)
		#flame_shock,moving=1,target_if=refreshable
		if not StandingStill() and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
		#flame_shock,moving=1
		if not StandingStill() and Enemies(tagged=1) == 1 Spell(flame_shock)
	}
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction StandingStill
{
	{Speed() == 0}
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(wind_shear) Spell(wind_shear)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_mana)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

### actions.default

AddFunction ElementalDefaultMainActions
{
	#potion,name=prolonged_power,if=cooldown.fire_elemental.remains>280|target.time_to_die<=60
	#run_action_list,name=ptr_default,if=ptr
	if PTR() ElementalPtrDefaultMainActions()

	unless PTR() and ElementalPtrDefaultMainPostConditions()
	{
		#storm_elemental
		Spell(storm_elemental)
		#run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
		if Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } ElementalAoeMainActions()

		unless Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalAoeMainPostConditions()
		{
			#run_action_list,name=single_asc,if=talent.ascendance.enabled
			if Talent(ascendance_talent) ElementalSingleAscMainActions()

			unless Talent(ascendance_talent) and ElementalSingleAscMainPostConditions()
			{
				#run_action_list,name=single_if,if=talent.icefury.enabled
				if Talent(icefury_talent) ElementalSingleIfMainActions()

				unless Talent(icefury_talent) and ElementalSingleIfMainPostConditions()
				{
					#run_action_list,name=single_lr,if=talent.lightning_rod.enabled
					if Talent(lightning_rod_talent) ElementalSingleLrMainActions()
				}
			}
		}
	}
}

AddFunction ElementalDefaultMainPostConditions
{
	PTR() and ElementalPtrDefaultMainPostConditions() or Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalAoeMainPostConditions() or Talent(ascendance_talent) and ElementalSingleAscMainPostConditions() or Talent(icefury_talent) and ElementalSingleIfMainPostConditions() or Talent(lightning_rod_talent) and ElementalSingleLrMainPostConditions()
}

AddFunction ElementalDefaultShortCdActions
{
	#potion,name=prolonged_power,if=cooldown.fire_elemental.remains>280|target.time_to_die<=60
	#run_action_list,name=ptr_default,if=ptr
	if PTR() ElementalPtrDefaultShortCdActions()

	unless PTR() and ElementalPtrDefaultShortCdPostConditions() or Spell(storm_elemental)
	{
		#elemental_mastery
		Spell(elemental_mastery)
		#run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
		if Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } ElementalAoeShortCdActions()

		unless Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalAoeShortCdPostConditions()
		{
			#run_action_list,name=single_asc,if=talent.ascendance.enabled
			if Talent(ascendance_talent) ElementalSingleAscShortCdActions()

			unless Talent(ascendance_talent) and ElementalSingleAscShortCdPostConditions()
			{
				#run_action_list,name=single_if,if=talent.icefury.enabled
				if Talent(icefury_talent) ElementalSingleIfShortCdActions()

				unless Talent(icefury_talent) and ElementalSingleIfShortCdPostConditions()
				{
					#run_action_list,name=single_lr,if=talent.lightning_rod.enabled
					if Talent(lightning_rod_talent) ElementalSingleLrShortCdActions()
				}
			}
		}
	}
}

AddFunction ElementalDefaultShortCdPostConditions
{
	PTR() and ElementalPtrDefaultShortCdPostConditions() or Spell(storm_elemental) or Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalAoeShortCdPostConditions() or Talent(ascendance_talent) and ElementalSingleAscShortCdPostConditions() or Talent(icefury_talent) and ElementalSingleIfShortCdPostConditions() or Talent(lightning_rod_talent) and ElementalSingleLrShortCdPostConditions()
}

AddFunction ElementalDefaultCdActions
{
	#bloodlust,if=target.health.pct<25|time>0.500
	if target.HealthPercent() < 25 or TimeInCombat() > 0.5 ElementalBloodlust()
	#potion,name=prolonged_power,if=cooldown.fire_elemental.remains>280|target.time_to_die<=60
	#run_action_list,name=ptr_default,if=ptr
	if PTR() ElementalPtrDefaultCdActions()

	unless PTR() and ElementalPtrDefaultCdPostConditions()
	{
		#totem_mastery,if=buff.resonance_totem.remains<2
		if BuffRemaining(resonance_totem_buff) < 2 Spell(totem_mastery)
		#fire_elemental
		Spell(fire_elemental)

		unless Spell(storm_elemental)
		{
			#use_item,name=gnawed_thumb_ring,if=equipped.gnawed_thumb_ring&(talent.ascendance.enabled&!buff.ascendance.up|!talent.ascendance.enabled)
			if HasEquippedItem(gnawed_thumb_ring) and { Talent(ascendance_talent) and not BuffPresent(ascendance_caster_buff) or not Talent(ascendance_talent) } ElementalUseItemActions()
			#blood_fury,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
			if not Talent(ascendance_talent) or BuffPresent(ascendance_caster_buff) or SpellCooldown(ascendance_caster) > 50 Spell(blood_fury_apsp)
			#berserking,if=!talent.ascendance.enabled|buff.ascendance.up
			if not Talent(ascendance_talent) or BuffPresent(ascendance_caster_buff) Spell(berserking)
			#wind_shear
			ElementalInterruptActions()
			#run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
			if Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } ElementalAoeCdActions()

			unless Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalAoeCdPostConditions()
			{
				#run_action_list,name=single_asc,if=talent.ascendance.enabled
				if Talent(ascendance_talent) ElementalSingleAscCdActions()

				unless Talent(ascendance_talent) and ElementalSingleAscCdPostConditions()
				{
					#run_action_list,name=single_if,if=talent.icefury.enabled
					if Talent(icefury_talent) ElementalSingleIfCdActions()

					unless Talent(icefury_talent) and ElementalSingleIfCdPostConditions()
					{
						#run_action_list,name=single_lr,if=talent.lightning_rod.enabled
						if Talent(lightning_rod_talent) ElementalSingleLrCdActions()
					}
				}
			}
		}
	}
}

AddFunction ElementalDefaultCdPostConditions
{
	PTR() and ElementalPtrDefaultCdPostConditions() or Spell(storm_elemental) or Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalAoeCdPostConditions() or Talent(ascendance_talent) and ElementalSingleAscCdPostConditions() or Talent(icefury_talent) and ElementalSingleIfCdPostConditions() or Talent(lightning_rod_talent) and ElementalSingleLrCdPostConditions()
}

### actions.aoe

AddFunction ElementalAoeMainActions
{
	#flame_shock,if=spell_targets.chain_lightning<4&maelstrom>=20&!talent.lightning_rod.enabled,target_if=refreshable
	if Enemies(tagged=1) < 4 and Maelstrom() >= 20 and not Talent(lightning_rod_talent) and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#earthquake
	Spell(earthquake)
	#lava_burst,if=dot.flame_shock.remains>cast_time&buff.lava_surge.up&!talent.lightning_rod.enabled&spell_targets.chain_lightning<4
	if target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and BuffPresent(lava_surge_buff) and not Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 Spell(lava_burst)
	#elemental_blast,if=!talent.lightning_rod.enabled&spell_targets.chain_lightning<5|talent.lightning_rod.enabled&spell_targets.chain_lightning<4
	if not Talent(lightning_rod_talent) and Enemies(tagged=1) < 5 or Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 Spell(elemental_blast)
	#lava_beam
	Spell(lava_beam)
	#chain_lightning,target_if=debuff.lightning_rod.down
	if target.DebuffExpires(lightning_rod_debuff) Spell(chain_lightning)
	#chain_lightning
	Spell(chain_lightning)
	#lava_burst,moving=1
	if Speed() > 0 Spell(lava_burst)
	#flame_shock,moving=1,target_if=refreshable
	if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
}

AddFunction ElementalAoeMainPostConditions
{
}

AddFunction ElementalAoeShortCdActions
{
	#stormkeeper
	Spell(stormkeeper)
	#liquid_magma_totem
	Spell(liquid_magma_totem)
}

AddFunction ElementalAoeShortCdPostConditions
{
	Enemies(tagged=1) < 4 and Maelstrom() >= 20 and not Talent(lightning_rod_talent) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Spell(earthquake) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and BuffPresent(lava_surge_buff) and not Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 and Spell(lava_burst) or { not Talent(lightning_rod_talent) and Enemies(tagged=1) < 5 or Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 } and Spell(elemental_blast) or Spell(lava_beam) or target.DebuffExpires(lightning_rod_debuff) and Spell(chain_lightning) or Spell(chain_lightning) or Speed() > 0 and Spell(lava_burst) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock)
}

AddFunction ElementalAoeCdActions
{
	unless Spell(stormkeeper)
	{
		#ascendance
		if BuffExpires(ascendance_caster_buff) Spell(ascendance_caster)
	}
}

AddFunction ElementalAoeCdPostConditions
{
	Spell(stormkeeper) or Spell(liquid_magma_totem) or Enemies(tagged=1) < 4 and Maelstrom() >= 20 and not Talent(lightning_rod_talent) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Spell(earthquake) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and BuffPresent(lava_surge_buff) and not Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 and Spell(lava_burst) or { not Talent(lightning_rod_talent) and Enemies(tagged=1) < 5 or Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 } and Spell(elemental_blast) or Spell(lava_beam) or target.DebuffExpires(lightning_rod_debuff) and Spell(chain_lightning) or Spell(chain_lightning) or Speed() > 0 and Spell(lava_burst) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock)
}

### actions.precombat

AddFunction ElementalPrecombatMainActions
{
	#flask,type=whispered_pact
	#food,name=fishbrul_special
	#augmentation,type=defiled
	Spell(augmentation)
}

AddFunction ElementalPrecombatMainPostConditions
{
}

AddFunction ElementalPrecombatShortCdActions
{
	unless Spell(augmentation)
	{
		#stormkeeper
		Spell(stormkeeper)
	}
}

AddFunction ElementalPrecombatShortCdPostConditions
{
	Spell(augmentation)
}

AddFunction ElementalPrecombatCdActions
{
	unless Spell(augmentation)
	{
		#snapshot_stats
		#potion,name=prolonged_power
		#totem_mastery
		Spell(totem_mastery)
	}
}

AddFunction ElementalPrecombatCdPostConditions
{
	Spell(augmentation) or Spell(stormkeeper)
}

### actions.ptr_aoe

AddFunction ElementalPtrAoeMainActions
{
	#flame_shock,if=spell_targets.chain_lightning<4&maelstrom>=20,target_if=refreshable
	if Enemies(tagged=1) < 4 and Maelstrom() >= 20 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#earthquake
	Spell(earthquake)
	#lava_burst,if=dot.flame_shock.remains>cast_time&buff.lava_surge.up&!talent.lightning_rod.enabled&spell_targets.chain_lightning<4
	if target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and BuffPresent(lava_surge_buff) and not Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 Spell(lava_burst)
	#elemental_blast,if=!talent.lightning_rod.enabled&spell_targets.chain_lightning<5|talent.lightning_rod.enabled&spell_targets.chain_lightning<4
	if not Talent(lightning_rod_talent) and Enemies(tagged=1) < 5 or Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 Spell(elemental_blast)
	#lava_beam
	Spell(lava_beam)
	#chain_lightning,target_if=debuff.lightning_rod.down
	if target.DebuffExpires(lightning_rod_debuff) Spell(chain_lightning)
	#chain_lightning
	Spell(chain_lightning)
	#lava_burst,moving=1
	if Speed() > 0 Spell(lava_burst)
	#flame_shock,moving=1,target_if=refreshable
	if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
}

AddFunction ElementalPtrAoeMainPostConditions
{
}

AddFunction ElementalPtrAoeShortCdActions
{
	#stormkeeper
	Spell(stormkeeper)
	#liquid_magma_totem
	Spell(liquid_magma_totem)
}

AddFunction ElementalPtrAoeShortCdPostConditions
{
	Enemies(tagged=1) < 4 and Maelstrom() >= 20 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Spell(earthquake) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and BuffPresent(lava_surge_buff) and not Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 and Spell(lava_burst) or { not Talent(lightning_rod_talent) and Enemies(tagged=1) < 5 or Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 } and Spell(elemental_blast) or Spell(lava_beam) or target.DebuffExpires(lightning_rod_debuff) and Spell(chain_lightning) or Spell(chain_lightning) or Speed() > 0 and Spell(lava_burst) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock)
}

AddFunction ElementalPtrAoeCdActions
{
	unless Spell(stormkeeper)
	{
		#ascendance
		if BuffExpires(ascendance_caster_buff) Spell(ascendance_caster)
	}
}

AddFunction ElementalPtrAoeCdPostConditions
{
	Spell(stormkeeper) or Spell(liquid_magma_totem) or Enemies(tagged=1) < 4 and Maelstrom() >= 20 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Spell(earthquake) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and BuffPresent(lava_surge_buff) and not Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 and Spell(lava_burst) or { not Talent(lightning_rod_talent) and Enemies(tagged=1) < 5 or Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 } and Spell(elemental_blast) or Spell(lava_beam) or target.DebuffExpires(lightning_rod_debuff) and Spell(chain_lightning) or Spell(chain_lightning) or Speed() > 0 and Spell(lava_burst) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock)
}

### actions.ptr_default

AddFunction ElementalPtrDefaultMainActions
{
	#storm_elemental,if=talent.primal_elementalist.enabled|!pet.primal_storm_elemental.active
	if Talent(primal_elementalist_talent) or not pet.Present() Spell(storm_elemental)
	#run_action_list,name=ptr_aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
	if Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } ElementalPtrAoeMainActions()

	unless Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalPtrAoeMainPostConditions()
	{
		#run_action_list,name=ptr_single_asc,if=talent.ascendance.enabled
		if Talent(ascendance_talent) ElementalPtrSingleAscMainActions()

		unless Talent(ascendance_talent) and ElementalPtrSingleAscMainPostConditions()
		{
			#run_action_list,name=ptr_single_if,if=talent.icefury.enabled
			if Talent(icefury_talent) ElementalPtrSingleIfMainActions()

			unless Talent(icefury_talent) and ElementalPtrSingleIfMainPostConditions()
			{
				#run_action_list,name=ptr_single_lr,if=talent.lightning_rod.enabled
				if Talent(lightning_rod_talent) ElementalPtrSingleLrMainActions()
			}
		}
	}
}

AddFunction ElementalPtrDefaultMainPostConditions
{
	Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalPtrAoeMainPostConditions() or Talent(ascendance_talent) and ElementalPtrSingleAscMainPostConditions() or Talent(icefury_talent) and ElementalPtrSingleIfMainPostConditions() or Talent(lightning_rod_talent) and ElementalPtrSingleLrMainPostConditions()
}

AddFunction ElementalPtrDefaultShortCdActions
{
	unless { Talent(primal_elementalist_talent) or not pet.Present() } and Spell(storm_elemental)
	{
		#elemental_mastery
		Spell(elemental_mastery)
		#run_action_list,name=ptr_aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
		if Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } ElementalPtrAoeShortCdActions()

		unless Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalPtrAoeShortCdPostConditions()
		{
			#run_action_list,name=ptr_single_asc,if=talent.ascendance.enabled
			if Talent(ascendance_talent) ElementalPtrSingleAscShortCdActions()

			unless Talent(ascendance_talent) and ElementalPtrSingleAscShortCdPostConditions()
			{
				#run_action_list,name=ptr_single_if,if=talent.icefury.enabled
				if Talent(icefury_talent) ElementalPtrSingleIfShortCdActions()

				unless Talent(icefury_talent) and ElementalPtrSingleIfShortCdPostConditions()
				{
					#run_action_list,name=ptr_single_lr,if=talent.lightning_rod.enabled
					if Talent(lightning_rod_talent) ElementalPtrSingleLrShortCdActions()
				}
			}
		}
	}
}

AddFunction ElementalPtrDefaultShortCdPostConditions
{
	{ Talent(primal_elementalist_talent) or not pet.Present() } and Spell(storm_elemental) or Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalPtrAoeShortCdPostConditions() or Talent(ascendance_talent) and ElementalPtrSingleAscShortCdPostConditions() or Talent(icefury_talent) and ElementalPtrSingleIfShortCdPostConditions() or Talent(lightning_rod_talent) and ElementalPtrSingleLrShortCdPostConditions()
}

AddFunction ElementalPtrDefaultCdActions
{
	#totem_mastery,if=buff.resonance_totem.remains<2
	if BuffRemaining(resonance_totem_buff) < 2 Spell(totem_mastery)
	#fire_elemental,if=talent.primal_elementalist.enabled|!pet.primal_fire_elemental.active
	if Talent(primal_elementalist_talent) or not pet.Present() Spell(fire_elemental)

	unless { Talent(primal_elementalist_talent) or not pet.Present() } and Spell(storm_elemental)
	{
		#use_item,name=gnawed_thumb_ring,if=equipped.gnawed_thumb_ring&(talent.ascendance.enabled&!buff.ascendance.up|!talent.ascendance.enabled)
		if HasEquippedItem(gnawed_thumb_ring) and { Talent(ascendance_talent) and not BuffPresent(ascendance_caster_buff) or not Talent(ascendance_talent) } ElementalUseItemActions()
		#blood_fury,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
		if not Talent(ascendance_talent) or BuffPresent(ascendance_caster_buff) or SpellCooldown(ascendance_caster) > 50 Spell(blood_fury_apsp)
		#berserking,if=!talent.ascendance.enabled|buff.ascendance.up
		if not Talent(ascendance_talent) or BuffPresent(ascendance_caster_buff) Spell(berserking)
		#run_action_list,name=ptr_aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
		if Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } ElementalPtrAoeCdActions()

		unless Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalPtrAoeCdPostConditions()
		{
			#run_action_list,name=ptr_single_asc,if=talent.ascendance.enabled
			if Talent(ascendance_talent) ElementalPtrSingleAscCdActions()

			unless Talent(ascendance_talent) and ElementalPtrSingleAscCdPostConditions()
			{
				#run_action_list,name=ptr_single_if,if=talent.icefury.enabled
				if Talent(icefury_talent) ElementalPtrSingleIfCdActions()

				unless Talent(icefury_talent) and ElementalPtrSingleIfCdPostConditions()
				{
					#run_action_list,name=ptr_single_lr,if=talent.lightning_rod.enabled
					if Talent(lightning_rod_talent) ElementalPtrSingleLrCdActions()
				}
			}
		}
	}
}

AddFunction ElementalPtrDefaultCdPostConditions
{
	{ Talent(primal_elementalist_talent) or not pet.Present() } and Spell(storm_elemental) or Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalPtrAoeCdPostConditions() or Talent(ascendance_talent) and ElementalPtrSingleAscCdPostConditions() or Talent(icefury_talent) and ElementalPtrSingleIfCdPostConditions() or Talent(lightning_rod_talent) and ElementalPtrSingleLrCdPostConditions()
}

### actions.ptr_single_asc

AddFunction ElementalPtrSingleAscMainActions
{
	#flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
	if not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() Spell(flame_shock)
	#flame_shock,if=maelstrom>=20&remains<=buff.ascendance.duration&cooldown.ascendance.remains+buff.ascendance.duration<=duration
	if Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_caster_buff) and SpellCooldown(ascendance_caster) + BaseDuration(ascendance_caster_buff) <= BaseDuration(flame_shock_debuff) Spell(flame_shock)
	#earthquake,if=buff.echoes_of_the_great_sundering.up&!buff.ascendance.up&maelstrom>=86
	if BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_caster_buff) and Maelstrom() >= 86 Spell(earthquake)
	#earth_shock,if=maelstrom>=117|!artifact.swelling_maelstrom.enabled&maelstrom>=92
	if Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 Spell(earth_shock)
	#elemental_blast
	Spell(elemental_blast)
	#lightning_bolt,if=buff.power_of_the_maelstrom.up&buff.stormkeeper.up&spell_targets.chain_lightning<3
	if BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt)
	#lava_burst,if=dot.flame_shock.remains>cast_time&(cooldown_react|buff.ascendance.up)
	if target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_caster_buff) } Spell(lava_burst)
	#flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
	if Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#earth_shock,if=maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86
	if Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 Spell(earth_shock)
	#earthquake,if=buff.echoes_of_the_great_sundering.up
	if BuffPresent(echoes_of_the_great_sundering_buff) Spell(earthquake)
	#lava_beam,if=active_enemies>1&spell_targets.lava_beam>1
	if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 Spell(lava_beam)
	#lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
	if BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt)
	#chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
	if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 Spell(chain_lightning)
	#lightning_bolt
	Spell(lightning_bolt)
	#flame_shock,moving=1,target_if=refreshable
	if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#earth_shock,moving=1
	if Speed() > 0 Spell(earth_shock)
	#flame_shock,moving=1,if=movement.distance>6
	if Speed() > 0 and target.Distance() > 6 Spell(flame_shock)
}

AddFunction ElementalPtrSingleAscMainPostConditions
{
}

AddFunction ElementalPtrSingleAscShortCdActions
{
	unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_caster_buff) and SpellCooldown(ascendance_caster) + BaseDuration(ascendance_caster_buff) <= BaseDuration(flame_shock_debuff) and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_caster_buff) and Maelstrom() >= 86 and Spell(earthquake) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock)
	{
		#stormkeeper,if=raid_event.adds.count<3|raid_event.adds.in>50
		if 0 < 3 or 600 > 50 Spell(stormkeeper)

		unless Spell(elemental_blast)
		{
			#liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
			if 0 < 3 or 600 > 50 Spell(liquid_magma_totem)
		}
	}
}

AddFunction ElementalPtrSingleAscShortCdPostConditions
{
	{ not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_caster_buff) and SpellCooldown(ascendance_caster) + BaseDuration(ascendance_caster_buff) <= BaseDuration(flame_shock_debuff) and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_caster_buff) and Maelstrom() >= 86 and Spell(earthquake) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or Spell(elemental_blast) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_caster_buff) } and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 } and Spell(earth_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Spell(earthquake) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(lava_beam) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or Spell(lightning_bolt) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

AddFunction ElementalPtrSingleAscCdActions
{
	#ascendance,if=dot.flame_shock.remains>buff.ascendance.duration&(time>=60|buff.bloodlust.up)&cooldown.lava_burst.remains>0&!buff.stormkeeper.up
	if target.DebuffRemaining(flame_shock_debuff) > BaseDuration(ascendance_caster_buff) and { TimeInCombat() >= 60 or BuffPresent(burst_haste_buff any=1) } and SpellCooldown(lava_burst) > 0 and not BuffPresent(stormkeeper_buff) and BuffExpires(ascendance_caster_buff) Spell(ascendance_caster)

	unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_caster_buff) and SpellCooldown(ascendance_caster) + BaseDuration(ascendance_caster_buff) <= BaseDuration(flame_shock_debuff) and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_caster_buff) and Maelstrom() >= 86 and Spell(earthquake) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or Spell(elemental_blast) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_caster_buff) } and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 } and Spell(earth_shock)
	{
		#totem_mastery,if=buff.resonance_totem.remains<10|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15)
		if BuffRemaining(resonance_totem_buff) < 10 or BuffRemaining(resonance_totem_buff) < BaseDuration(ascendance_caster_buff) + SpellCooldown(ascendance_caster) and SpellCooldown(ascendance_caster) < 15 Spell(totem_mastery)
	}
}

AddFunction ElementalPtrSingleAscCdPostConditions
{
	{ not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_caster_buff) and SpellCooldown(ascendance_caster) + BaseDuration(ascendance_caster_buff) <= BaseDuration(flame_shock_debuff) and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_caster_buff) and Maelstrom() >= 86 and Spell(earthquake) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or Spell(elemental_blast) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_caster_buff) } and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 } and Spell(earth_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Spell(earthquake) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(lava_beam) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or Spell(lightning_bolt) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

### actions.ptr_single_if

AddFunction ElementalPtrSingleIfMainActions
{
	#flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
	if not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() Spell(flame_shock)
	#earthquake,if=buff.echoes_of_the_great_sundering.up&maelstrom>=86
	if BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 Spell(earthquake)
	#frost_shock,if=buff.icefury.up&maelstrom>=111
	if BuffPresent(icefury_buff) and Maelstrom() >= 111 Spell(frost_shock)
	#earth_shock,if=maelstrom>=117|!artifact.swelling_maelstrom.enabled&maelstrom>=92
	if Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 Spell(earth_shock)
	#elemental_blast
	Spell(elemental_blast)
	#icefury,if=raid_event.movement.in<5|maelstrom<=101
	if 600 < 5 or Maelstrom() <= 101 Spell(icefury)
	#lightning_bolt,if=buff.power_of_the_maelstrom.up&buff.stormkeeper.up&spell_targets.chain_lightning<3
	if BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt)
	#lava_burst,if=dot.flame_shock.remains>cast_time&cooldown_react
	if target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 Spell(lava_burst)
	#frost_shock,if=buff.icefury.up&((maelstrom>=20&raid_event.movement.in>buff.icefury.remains)|buff.icefury.remains<(1.5*spell_haste*buff.icefury.stack+1))
	if BuffPresent(icefury_buff) and { Maelstrom() >= 20 and 600 > BuffRemaining(icefury_buff) or BuffRemaining(icefury_buff) < 1.5 * { 100 / { 100 + SpellHaste() } } * BuffStacks(icefury_buff) + 1 } Spell(frost_shock)
	#flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
	if Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#frost_shock,moving=1,if=buff.icefury.up
	if Speed() > 0 and BuffPresent(icefury_buff) Spell(frost_shock)
	#earth_shock,if=maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86
	if Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 Spell(earth_shock)
	#earthquake,if=buff.echoes_of_the_great_sundering.up
	if BuffPresent(echoes_of_the_great_sundering_buff) Spell(earthquake)
	#lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
	if BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt)
	#chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
	if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 Spell(chain_lightning)
	#lightning_bolt
	Spell(lightning_bolt)
	#flame_shock,moving=1,target_if=refreshable
	if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#earth_shock,moving=1
	if Speed() > 0 Spell(earth_shock)
	#flame_shock,moving=1,if=movement.distance>6
	if Speed() > 0 and target.Distance() > 6 Spell(flame_shock)
}

AddFunction ElementalPtrSingleIfMainPostConditions
{
}

AddFunction ElementalPtrSingleIfShortCdActions
{
	unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or BuffPresent(icefury_buff) and Maelstrom() >= 111 and Spell(frost_shock) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock)
	{
		#stormkeeper,if=raid_event.adds.count<3|raid_event.adds.in>50
		if 0 < 3 or 600 > 50 Spell(stormkeeper)

		unless Spell(elemental_blast) or { 600 < 5 or Maelstrom() <= 101 } and Spell(icefury)
		{
			#liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
			if 0 < 3 or 600 > 50 Spell(liquid_magma_totem)
		}
	}
}

AddFunction ElementalPtrSingleIfShortCdPostConditions
{
	{ not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or BuffPresent(icefury_buff) and Maelstrom() >= 111 and Spell(frost_shock) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or Spell(elemental_blast) or { 600 < 5 or Maelstrom() <= 101 } and Spell(icefury) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or BuffPresent(icefury_buff) and { Maelstrom() >= 20 and 600 > BuffRemaining(icefury_buff) or BuffRemaining(icefury_buff) < 1.5 * { 100 / { 100 + SpellHaste() } } * BuffStacks(icefury_buff) + 1 } and Spell(frost_shock) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and BuffPresent(icefury_buff) and Spell(frost_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 } and Spell(earth_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Spell(earthquake) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or Spell(lightning_bolt) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

AddFunction ElementalPtrSingleIfCdActions
{
	unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or BuffPresent(icefury_buff) and Maelstrom() >= 111 and Spell(frost_shock) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or Spell(elemental_blast) or { 600 < 5 or Maelstrom() <= 101 } and Spell(icefury) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or BuffPresent(icefury_buff) and { Maelstrom() >= 20 and 600 > BuffRemaining(icefury_buff) or BuffRemaining(icefury_buff) < 1.5 * { 100 / { 100 + SpellHaste() } } * BuffStacks(icefury_buff) + 1 } and Spell(frost_shock) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and BuffPresent(icefury_buff) and Spell(frost_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 } and Spell(earth_shock)
	{
		#totem_mastery,if=buff.resonance_totem.remains<10
		if BuffRemaining(resonance_totem_buff) < 10 Spell(totem_mastery)
	}
}

AddFunction ElementalPtrSingleIfCdPostConditions
{
	{ not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or BuffPresent(icefury_buff) and Maelstrom() >= 111 and Spell(frost_shock) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or Spell(elemental_blast) or { 600 < 5 or Maelstrom() <= 101 } and Spell(icefury) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or BuffPresent(icefury_buff) and { Maelstrom() >= 20 and 600 > BuffRemaining(icefury_buff) or BuffRemaining(icefury_buff) < 1.5 * { 100 / { 100 + SpellHaste() } } * BuffStacks(icefury_buff) + 1 } and Spell(frost_shock) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and BuffPresent(icefury_buff) and Spell(frost_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 } and Spell(earth_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Spell(earthquake) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or Spell(lightning_bolt) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

### actions.ptr_single_lr

AddFunction ElementalPtrSingleLrMainActions
{
	#flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
	if not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() Spell(flame_shock)
	#earthquake,if=buff.echoes_of_the_great_sundering.up&maelstrom>=86
	if BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 Spell(earthquake)
	#earth_shock,if=maelstrom>=117|!artifact.swelling_maelstrom.enabled&maelstrom>=92
	if Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 Spell(earth_shock)
	#elemental_blast
	Spell(elemental_blast)
	#lava_burst,if=dot.flame_shock.remains>cast_time&cooldown_react
	if target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 Spell(lava_burst)
	#flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
	if Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#earth_shock,if=maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86
	if Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 Spell(earth_shock)
	#earthquake,if=buff.echoes_of_the_great_sundering.up
	if BuffPresent(echoes_of_the_great_sundering_buff) Spell(earthquake)
	#lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3,target_if=debuff.lightning_rod.down
	if BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and target.DebuffExpires(lightning_rod_debuff) Spell(lightning_bolt)
	#lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
	if BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt)
	#chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1,target_if=debuff.lightning_rod.down
	if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and target.DebuffExpires(lightning_rod_debuff) Spell(chain_lightning)
	#chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
	if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 Spell(chain_lightning)
	#lightning_bolt,target_if=debuff.lightning_rod.down
	if target.DebuffExpires(lightning_rod_debuff) Spell(lightning_bolt)
	#lightning_bolt
	Spell(lightning_bolt)
	#flame_shock,moving=1,target_if=refreshable
	if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#earth_shock,moving=1
	if Speed() > 0 Spell(earth_shock)
	#flame_shock,moving=1,if=movement.distance>6
	if Speed() > 0 and target.Distance() > 6 Spell(flame_shock)
}

AddFunction ElementalPtrSingleLrMainPostConditions
{
}

AddFunction ElementalPtrSingleLrShortCdActions
{
	unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock)
	{
		#stormkeeper,if=raid_event.adds.count<3|raid_event.adds.in>50
		if 0 < 3 or 600 > 50 Spell(stormkeeper)

		unless Spell(elemental_blast)
		{
			#liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
			if 0 < 3 or 600 > 50 Spell(liquid_magma_totem)
		}
	}
}

AddFunction ElementalPtrSingleLrShortCdPostConditions
{
	{ not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or Spell(elemental_blast) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 } and Spell(earth_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Spell(earthquake) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and target.DebuffExpires(lightning_rod_debuff) and Spell(lightning_bolt) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and target.DebuffExpires(lightning_rod_debuff) and Spell(chain_lightning) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or target.DebuffExpires(lightning_rod_debuff) and Spell(lightning_bolt) or Spell(lightning_bolt) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

AddFunction ElementalPtrSingleLrCdActions
{
	unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or Spell(elemental_blast) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 } and Spell(earth_shock)
	{
		#totem_mastery,if=buff.resonance_totem.remains<10|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15)
		if BuffRemaining(resonance_totem_buff) < 10 or BuffRemaining(resonance_totem_buff) < BaseDuration(ascendance_caster_buff) + SpellCooldown(ascendance_caster) and SpellCooldown(ascendance_caster) < 15 Spell(totem_mastery)
	}
}

AddFunction ElementalPtrSingleLrCdPostConditions
{
	{ not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or Spell(elemental_blast) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 } and Spell(earth_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Spell(earthquake) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and target.DebuffExpires(lightning_rod_debuff) and Spell(lightning_bolt) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and target.DebuffExpires(lightning_rod_debuff) and Spell(chain_lightning) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or target.DebuffExpires(lightning_rod_debuff) and Spell(lightning_bolt) or Spell(lightning_bolt) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

### actions.single_asc

AddFunction ElementalSingleAscMainActions
{
	#flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
	if not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() Spell(flame_shock)
	#flame_shock,if=maelstrom>=20&remains<=buff.ascendance.duration&cooldown.ascendance.remains+buff.ascendance.duration<=duration
	if Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_caster_buff) and SpellCooldown(ascendance_caster) + BaseDuration(ascendance_caster_buff) <= BaseDuration(flame_shock_debuff) Spell(flame_shock)
	#earthquake,if=buff.echoes_of_the_great_sundering.up&!buff.ascendance.up&maelstrom>=86
	if BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_caster_buff) and Maelstrom() >= 86 Spell(earthquake)
	#earth_shock,if=maelstrom>=92&!buff.ascendance.up
	if Maelstrom() >= 92 and not BuffPresent(ascendance_caster_buff) Spell(earth_shock)
	#elemental_blast
	Spell(elemental_blast)
	#lightning_bolt,if=buff.power_of_the_maelstrom.up&buff.stormkeeper.up&spell_targets.chain_lightning<3
	if BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt)
	#lava_burst,if=dot.flame_shock.remains>cast_time&(cooldown_react|buff.ascendance.up)
	if target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_caster_buff) } Spell(lava_burst)
	#flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
	if Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#earth_shock,if=maelstrom>=86
	if Maelstrom() >= 86 Spell(earth_shock)
	#earthquake,if=buff.echoes_of_the_great_sundering.up
	if BuffPresent(echoes_of_the_great_sundering_buff) Spell(earthquake)
	#lava_beam,if=active_enemies>1&spell_targets.lava_beam>1
	if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 Spell(lava_beam)
	#lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
	if BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt)
	#chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
	if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 Spell(chain_lightning)
	#lightning_bolt
	Spell(lightning_bolt)
	#flame_shock,moving=1,target_if=refreshable
	if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#earth_shock,moving=1
	if Speed() > 0 Spell(earth_shock)
	#flame_shock,moving=1,if=movement.distance>6
	if Speed() > 0 and target.Distance() > 6 Spell(flame_shock)
}

AddFunction ElementalSingleAscMainPostConditions
{
}

AddFunction ElementalSingleAscShortCdActions
{
	unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_caster_buff) and SpellCooldown(ascendance_caster) + BaseDuration(ascendance_caster_buff) <= BaseDuration(flame_shock_debuff) and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_caster_buff) and Maelstrom() >= 86 and Spell(earthquake) or Maelstrom() >= 92 and not BuffPresent(ascendance_caster_buff) and Spell(earth_shock)
	{
		#stormkeeper,if=raid_event.adds.count<3|raid_event.adds.in>50
		if 0 < 3 or 600 > 50 Spell(stormkeeper)

		unless Spell(elemental_blast)
		{
			#liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
			if 0 < 3 or 600 > 50 Spell(liquid_magma_totem)
		}
	}
}

AddFunction ElementalSingleAscShortCdPostConditions
{
	{ not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_caster_buff) and SpellCooldown(ascendance_caster) + BaseDuration(ascendance_caster_buff) <= BaseDuration(flame_shock_debuff) and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_caster_buff) and Maelstrom() >= 86 and Spell(earthquake) or Maelstrom() >= 92 and not BuffPresent(ascendance_caster_buff) and Spell(earth_shock) or Spell(elemental_blast) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_caster_buff) } and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Maelstrom() >= 86 and Spell(earth_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Spell(earthquake) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(lava_beam) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or Spell(lightning_bolt) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

AddFunction ElementalSingleAscCdActions
{
	#ascendance,if=dot.flame_shock.remains>buff.ascendance.duration&(time>=60|buff.bloodlust.up)&cooldown.lava_burst.remains>0&!buff.stormkeeper.up
	if target.DebuffRemaining(flame_shock_debuff) > BaseDuration(ascendance_caster_buff) and { TimeInCombat() >= 60 or BuffPresent(burst_haste_buff any=1) } and SpellCooldown(lava_burst) > 0 and not BuffPresent(stormkeeper_buff) and BuffExpires(ascendance_caster_buff) Spell(ascendance_caster)

	unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_caster_buff) and SpellCooldown(ascendance_caster) + BaseDuration(ascendance_caster_buff) <= BaseDuration(flame_shock_debuff) and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_caster_buff) and Maelstrom() >= 86 and Spell(earthquake) or Maelstrom() >= 92 and not BuffPresent(ascendance_caster_buff) and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or Spell(elemental_blast) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_caster_buff) } and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Maelstrom() >= 86 and Spell(earth_shock)
	{
		#totem_mastery,if=buff.resonance_totem.remains<10|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15)
		if BuffRemaining(resonance_totem_buff) < 10 or BuffRemaining(resonance_totem_buff) < BaseDuration(ascendance_caster_buff) + SpellCooldown(ascendance_caster) and SpellCooldown(ascendance_caster) < 15 Spell(totem_mastery)
	}
}

AddFunction ElementalSingleAscCdPostConditions
{
	{ not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_caster_buff) and SpellCooldown(ascendance_caster) + BaseDuration(ascendance_caster_buff) <= BaseDuration(flame_shock_debuff) and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_caster_buff) and Maelstrom() >= 86 and Spell(earthquake) or Maelstrom() >= 92 and not BuffPresent(ascendance_caster_buff) and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or Spell(elemental_blast) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_caster_buff) } and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Maelstrom() >= 86 and Spell(earth_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Spell(earthquake) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(lava_beam) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or Spell(lightning_bolt) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

### actions.single_if

AddFunction ElementalSingleIfMainActions
{
	#flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
	if not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() Spell(flame_shock)
	#earthquake,if=buff.echoes_of_the_great_sundering.up&maelstrom>=86
	if BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 Spell(earthquake)
	#frost_shock,if=buff.icefury.up&maelstrom>=86
	if BuffPresent(icefury_buff) and Maelstrom() >= 86 Spell(frost_shock)
	#earth_shock,if=maelstrom>=92
	if Maelstrom() >= 92 Spell(earth_shock)
	#elemental_blast
	Spell(elemental_blast)
	#icefury,if=raid_event.movement.in<5|maelstrom<=76
	if 600 < 5 or Maelstrom() <= 76 Spell(icefury)
	#lightning_bolt,if=buff.power_of_the_maelstrom.up&buff.stormkeeper.up&spell_targets.chain_lightning<3
	if BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt)
	#lava_burst,if=dot.flame_shock.remains>cast_time&cooldown_react
	if target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 Spell(lava_burst)
	#frost_shock,if=buff.icefury.up&((maelstrom>=20&raid_event.movement.in>buff.icefury.remains)|buff.icefury.remains<(1.5*spell_haste*buff.icefury.stack+1))
	if BuffPresent(icefury_buff) and { Maelstrom() >= 20 and 600 > BuffRemaining(icefury_buff) or BuffRemaining(icefury_buff) < 1.5 * { 100 / { 100 + SpellHaste() } } * BuffStacks(icefury_buff) + 1 } Spell(frost_shock)
	#flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
	if Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#frost_shock,moving=1,if=buff.icefury.up
	if Speed() > 0 and BuffPresent(icefury_buff) Spell(frost_shock)
	#earth_shock,if=maelstrom>=86
	if Maelstrom() >= 86 Spell(earth_shock)
	#earthquake,if=buff.echoes_of_the_great_sundering.up
	if BuffPresent(echoes_of_the_great_sundering_buff) Spell(earthquake)
	#lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
	if BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt)
	#chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
	if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 Spell(chain_lightning)
	#lightning_bolt
	Spell(lightning_bolt)
	#flame_shock,moving=1,target_if=refreshable
	if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#earth_shock,moving=1
	if Speed() > 0 Spell(earth_shock)
	#flame_shock,moving=1,if=movement.distance>6
	if Speed() > 0 and target.Distance() > 6 Spell(flame_shock)
}

AddFunction ElementalSingleIfMainPostConditions
{
}

AddFunction ElementalSingleIfShortCdActions
{
	unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or BuffPresent(icefury_buff) and Maelstrom() >= 86 and Spell(frost_shock) or Maelstrom() >= 92 and Spell(earth_shock)
	{
		#stormkeeper,if=raid_event.adds.count<3|raid_event.adds.in>50
		if 0 < 3 or 600 > 50 Spell(stormkeeper)

		unless Spell(elemental_blast) or { 600 < 5 or Maelstrom() <= 76 } and Spell(icefury)
		{
			#liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
			if 0 < 3 or 600 > 50 Spell(liquid_magma_totem)
		}
	}
}

AddFunction ElementalSingleIfShortCdPostConditions
{
	{ not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or BuffPresent(icefury_buff) and Maelstrom() >= 86 and Spell(frost_shock) or Maelstrom() >= 92 and Spell(earth_shock) or Spell(elemental_blast) or { 600 < 5 or Maelstrom() <= 76 } and Spell(icefury) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or BuffPresent(icefury_buff) and { Maelstrom() >= 20 and 600 > BuffRemaining(icefury_buff) or BuffRemaining(icefury_buff) < 1.5 * { 100 / { 100 + SpellHaste() } } * BuffStacks(icefury_buff) + 1 } and Spell(frost_shock) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and BuffPresent(icefury_buff) and Spell(frost_shock) or Maelstrom() >= 86 and Spell(earth_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Spell(earthquake) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or Spell(lightning_bolt) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

AddFunction ElementalSingleIfCdActions
{
	unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or BuffPresent(icefury_buff) and Maelstrom() >= 86 and Spell(frost_shock) or Maelstrom() >= 92 and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or Spell(elemental_blast) or { 600 < 5 or Maelstrom() <= 76 } and Spell(icefury) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or BuffPresent(icefury_buff) and { Maelstrom() >= 20 and 600 > BuffRemaining(icefury_buff) or BuffRemaining(icefury_buff) < 1.5 * { 100 / { 100 + SpellHaste() } } * BuffStacks(icefury_buff) + 1 } and Spell(frost_shock) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and BuffPresent(icefury_buff) and Spell(frost_shock) or Maelstrom() >= 86 and Spell(earth_shock)
	{
		#totem_mastery,if=buff.resonance_totem.remains<10
		if BuffRemaining(resonance_totem_buff) < 10 Spell(totem_mastery)
	}
}

AddFunction ElementalSingleIfCdPostConditions
{
	{ not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or BuffPresent(icefury_buff) and Maelstrom() >= 86 and Spell(frost_shock) or Maelstrom() >= 92 and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or Spell(elemental_blast) or { 600 < 5 or Maelstrom() <= 76 } and Spell(icefury) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or BuffPresent(icefury_buff) and { Maelstrom() >= 20 and 600 > BuffRemaining(icefury_buff) or BuffRemaining(icefury_buff) < 1.5 * { 100 / { 100 + SpellHaste() } } * BuffStacks(icefury_buff) + 1 } and Spell(frost_shock) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and BuffPresent(icefury_buff) and Spell(frost_shock) or Maelstrom() >= 86 and Spell(earth_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Spell(earthquake) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or Spell(lightning_bolt) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

### actions.single_lr

AddFunction ElementalSingleLrMainActions
{
	#flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
	if not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() Spell(flame_shock)
	#earthquake,if=buff.echoes_of_the_great_sundering.up&maelstrom>=86
	if BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 Spell(earthquake)
	#earth_shock,if=maelstrom>=92
	if Maelstrom() >= 92 Spell(earth_shock)
	#elemental_blast
	Spell(elemental_blast)
	#lava_burst,if=dot.flame_shock.remains>cast_time&cooldown_react
	if target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 Spell(lava_burst)
	#flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
	if Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#earth_shock,if=maelstrom>=86
	if Maelstrom() >= 86 Spell(earth_shock)
	#earthquake,if=buff.echoes_of_the_great_sundering.up
	if BuffPresent(echoes_of_the_great_sundering_buff) Spell(earthquake)
	#lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3,target_if=debuff.lightning_rod.down
	if BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and target.DebuffExpires(lightning_rod_debuff) Spell(lightning_bolt)
	#lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
	if BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt)
	#chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1,target_if=debuff.lightning_rod.down
	if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and target.DebuffExpires(lightning_rod_debuff) Spell(chain_lightning)
	#chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
	if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 Spell(chain_lightning)
	#lightning_bolt,target_if=debuff.lightning_rod.down
	if target.DebuffExpires(lightning_rod_debuff) Spell(lightning_bolt)
	#lightning_bolt
	Spell(lightning_bolt)
	#flame_shock,moving=1,target_if=refreshable
	if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
	#earth_shock,moving=1
	if Speed() > 0 Spell(earth_shock)
	#flame_shock,moving=1,if=movement.distance>6
	if Speed() > 0 and target.Distance() > 6 Spell(flame_shock)
}

AddFunction ElementalSingleLrMainPostConditions
{
}

AddFunction ElementalSingleLrShortCdActions
{
	unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or Maelstrom() >= 92 and Spell(earth_shock)
	{
		#stormkeeper,if=raid_event.adds.count<3|raid_event.adds.in>50
		if 0 < 3 or 600 > 50 Spell(stormkeeper)

		unless Spell(elemental_blast)
		{
			#liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
			if 0 < 3 or 600 > 50 Spell(liquid_magma_totem)
		}
	}
}

AddFunction ElementalSingleLrShortCdPostConditions
{
	{ not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or Maelstrom() >= 92 and Spell(earth_shock) or Spell(elemental_blast) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Maelstrom() >= 86 and Spell(earth_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Spell(earthquake) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and target.DebuffExpires(lightning_rod_debuff) and Spell(lightning_bolt) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and target.DebuffExpires(lightning_rod_debuff) and Spell(chain_lightning) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or target.DebuffExpires(lightning_rod_debuff) and Spell(lightning_bolt) or Spell(lightning_bolt) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

AddFunction ElementalSingleLrCdActions
{
	unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or Maelstrom() >= 92 and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or Spell(elemental_blast) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Maelstrom() >= 86 and Spell(earth_shock)
	{
		#totem_mastery,if=buff.resonance_totem.remains<10|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15)
		if BuffRemaining(resonance_totem_buff) < 10 or BuffRemaining(resonance_totem_buff) < BaseDuration(ascendance_caster_buff) + SpellCooldown(ascendance_caster) and SpellCooldown(ascendance_caster) < 15 Spell(totem_mastery)
	}
}

AddFunction ElementalSingleLrCdPostConditions
{
	{ not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Maelstrom() >= 86 and Spell(earthquake) or Maelstrom() >= 92 and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or Spell(elemental_blast) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Maelstrom() >= 86 and Spell(earth_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and Spell(earthquake) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and target.DebuffExpires(lightning_rod_debuff) and Spell(lightning_bolt) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and target.DebuffExpires(lightning_rod_debuff) and Spell(chain_lightning) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or target.DebuffExpires(lightning_rod_debuff) and Spell(lightning_bolt) or Spell(lightning_bolt) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}
]]

	OvaleScripts:RegisterScript("SHAMAN", "elemental", name, desc, code, "script")
end
