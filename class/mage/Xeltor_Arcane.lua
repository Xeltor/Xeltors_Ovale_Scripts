local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_arcane"
	local desc = "[Xel][BROKEN] Mage: Arcane"
	local code = [[
# Based on SimulationCraft profile "Mage_Arcane_T18M".
#	class=mage
#	spec=arcane
#	talents=3003222
#	glyphs=cone_of_cold

Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_mage_spells)

Define(frostjaw 102051)
Define(ice_block_buff 45438)

# Arcane
AddIcon specialization=1 help=main
{
    if not mounted() and HealthPercent() > 1
    {
		if BuffExpires(critical_strike_buff any=1) or BuffExpires(spell_power_multiplier_buff any=1) Spell(arcane_brilliance)
    }
	
	if InCombat() and target.Casting(interrupt) InterruptActions()
	
	#cold_snap,if=health.pct<30
	if HealthPercent() < 30 and not mounted() Spell(cold_snap)
	if BuffExpires(ice_barrier) and IncomingDamage(5) > 0 and not mounted() and not { target.Classification(worldboss) or BuffPresent(burst_haste_buff any=1) } Spell(ice_barrier)
	
	if InCombat() and target.InRange(arcane_blast) and HasFullControl() and not BuffPresent(evocation)
	{
		if BuffExpires(ice_floes_buff) and not NotMoving() and CheckBoxOff(aoe) Spell(ice_floes)
		
		# Cooldowns
		if Boss()
		{
			if NotMoving() ArcaneDefaultCdActions()
		}
		if NotMoving() ArcaneDefaultShortCdActions()
		ArcaneDefaultMainActions()
	}
}
AddCheckBox(aoe "Arcane Boom Flower!")

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

AddFunction ArcaneDefaultMainActions
{
	#stop_burn_phase,if=prev_gcd.evocation&burn_phase_duration>gcd.max
	if PreviousGCDSpell(evocation) and GetStateDuration(burn_phase) > GCD() and GetState(burn_phase) > 0 SetState(burn_phase 0)
	#call_action_list,name=aoe,if=active_enemies>=5
	if CheckBoxOn(aoe) ArcaneAoeMainActions()
	#call_action_list,name=init_burn,if=!burn_phase
	if not GetState(burn_phase) > 0 and NotMoving() and { target.Classification(worldboss) or BuffPresent(burst_haste_buff any=1) or CheckBoxOn(bjurst) } ArcaneInitBurnMainActions()
	#call_action_list,name=burn,if=burn_phase
	if GetState(burn_phase) > 0 and NotMoving() and { target.Classification(worldboss) or BuffPresent(burst_haste_buff any=1) or CheckBoxOn(bjurst) } ArcaneBurnMainActions()
	#call_action_list,name=conserve
	if NotMoving() ArcaneConserveMainActions()
}

AddFunction ArcaneDefaultShortCdActions
{
	#stop_burn_phase,if=prev_gcd.evocation&burn_phase_duration>gcd.max
	if PreviousGCDSpell(evocation) and GetStateDuration(burn_phase) > GCD() and GetState(burn_phase) > 0 SetState(burn_phase 0)
	#call_action_list,name=movement,if=raid_event.movement.exists
	# if False(raid_event_movement_exists) ArcaneMovementShortCdActions()
	#rune_of_power,if=buff.rune_of_power.remains<2*spell_haste
	# if TotemRemaining(rune_of_power) < 2 * { 100 / { 100 + SpellHaste() } } Spell(rune_of_power)
	#call_action_list,name=aoe,if=active_enemies>=5
	if CheckBoxOn(aoe) ArcaneAoeShortCdActions()

	unless CheckBoxOn(aoe) and ArcaneAoeShortCdPostConditions()
	{
		#call_action_list,name=init_burn,if=!burn_phase
		if not GetState(burn_phase) > 0 ArcaneInitBurnShortCdActions()
		#call_action_list,name=burn,if=burn_phase
		if GetState(burn_phase) > 0 ArcaneBurnShortCdActions()

		unless GetState(burn_phase) > 0 and ArcaneBurnShortCdPostConditions()
		{
			#call_action_list,name=conserve
			ArcaneConserveShortCdActions()
		}
	}
}

AddFunction ArcaneDefaultCdActions
{
	#counterspell,if=target.debuff.casting.react
	# if target.IsInterruptible() ArcaneInterruptActions()
	#stop_burn_phase,if=prev_gcd.evocation&burn_phase_duration>gcd.max
	if PreviousGCDSpell(evocation) and GetStateDuration(burn_phase) > GCD() and GetState(burn_phase) > 0 SetState(burn_phase 0)
	#cold_snap,if=health.pct<30
	# if HealthPercent() < 30 Spell(cold_snap)
	#time_warp,if=target.health.pct<25|time>5
	# if { target.HealthPercent() < 25 or TimeInCombat() > 5 } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) Spell(time_warp)

	unless False(raid_event_movement_exists) and ArcaneMovementCdPostConditions() or TotemRemaining(rune_of_power) < 2 * { 100 / { 100 + SpellHaste() } } and Spell(rune_of_power)
	{
		#mirror_image
		Spell(mirror_image)
		#cold_snap,if=buff.presence_of_mind.down&cooldown.presence_of_mind.remains>75
		if BuffExpires(presence_of_mind_buff) and SpellCooldown(presence_of_mind) > 75 Spell(cold_snap)
		#call_action_list,name=aoe,if=active_enemies>=5
		if Enemies() >= 5 ArcaneAoeCdActions()

		unless Enemies() >= 5 and ArcaneAoeCdPostConditions()
		{
			#call_action_list,name=init_burn,if=!burn_phase
			if not GetState(burn_phase) > 0 ArcaneInitBurnCdActions()
			#call_action_list,name=burn,if=burn_phase
			if GetState(burn_phase) > 0 ArcaneBurnCdActions()

			unless GetState(burn_phase) > 0 and ArcaneBurnCdPostConditions()
			{
				#call_action_list,name=conserve
				ArcaneConserveCdActions()
			}
		}
	}
}

### actions.aoe

AddFunction ArcaneAoeMainActions
{
	#nether_tempest,cycle_targets=1,if=buff.arcane_charge.stack=4&(active_dot.nether_tempest=0|(ticking&remains<3.6))
	if DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } Spell(nether_tempest)
	#supernova
	Spell(supernova)
	#arcane_explosion,if=prev_gcd.evocation
	if PreviousGCDSpell(evocation) and target.Distance(less 15) Spell(arcane_explosion)
	#arcane_missiles,if=set_bonus.tier17_4pc&active_enemies<10&buff.arcane_charge.stack=4&buff.arcane_instability.react
	if ArmorSetBonus(T17 4) and Enemies() < 10 and DebuffStacks(arcane_charge_debuff) == 4 and BuffPresent(arcane_instability_buff) and NotMoving() Spell(arcane_missiles)
	#arcane_missiles,target_if=debuff.mark_of_doom.remains>2*spell_haste+(target.distance%20),if=buff.arcane_missiles.react
	if BuffPresent(arcane_missiles_buff) and NotMoving() Spell(arcane_missiles)
	#nether_tempest,cycle_targets=1,if=talent.arcane_orb.enabled&buff.arcane_charge.stack=4&ticking&remains<cooldown.arcane_orb.remains
	if Talent(arcane_orb_talent) and DebuffStacks(arcane_charge_debuff) == 4 and target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < SpellCooldown(arcane_orb) Spell(nether_tempest)
	#arcane_barrage,if=buff.arcane_charge.stack=4
	if DebuffStacks(arcane_charge_debuff) == 4 Spell(arcane_barrage)
	#arcane_explosion
	if target.Distance(less 15) Spell(arcane_explosion)
}

AddFunction ArcaneAoeShortCdActions
{
	unless DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } and Spell(nether_tempest) or Spell(supernova)
	{
		#arcane_orb,if=buff.arcane_charge.stack<4
		if DebuffStacks(arcane_charge_debuff) < 4 Spell(arcane_orb)

		unless PreviousGCDSpell(evocation) and Spell(arcane_explosion) or ArmorSetBonus(T17 4) and Enemies() < 10 and DebuffStacks(arcane_charge_debuff) == 4 and BuffPresent(arcane_instability_buff) and Spell(arcane_missiles) or BuffPresent(arcane_missiles_buff) and Spell(arcane_missiles) or Talent(arcane_orb_talent) and DebuffStacks(arcane_charge_debuff) == 4 and target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < SpellCooldown(arcane_orb) and Spell(nether_tempest) or DebuffStacks(arcane_charge_debuff) == 4 and Spell(arcane_barrage)
		{
			#cone_of_cold,if=glyph.cone_of_cold.enabled
			if Glyph(glyph_of_cone_of_cold) and target.Distance(less 12) Spell(cone_of_cold)
		}
	}
}

AddFunction ArcaneAoeShortCdPostConditions
{
	DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } and Spell(nether_tempest) or Spell(supernova) or PreviousGCDSpell(evocation) and Spell(arcane_explosion) or ArmorSetBonus(T17 4) and Enemies() < 10 and DebuffStacks(arcane_charge_debuff) == 4 and BuffPresent(arcane_instability_buff) and Spell(arcane_missiles) or BuffPresent(arcane_missiles_buff) and Spell(arcane_missiles) or Talent(arcane_orb_talent) and DebuffStacks(arcane_charge_debuff) == 4 and target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < SpellCooldown(arcane_orb) and Spell(nether_tempest) or DebuffStacks(arcane_charge_debuff) == 4 and Spell(arcane_barrage) or Spell(arcane_explosion)
}

AddFunction ArcaneAoeCdActions
{
	#call_action_list,name=cooldowns
	ArcaneCooldownsCdActions()

	unless DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } and Spell(nether_tempest) or Spell(supernova) or DebuffStacks(arcane_charge_debuff) < 4 and Spell(arcane_orb) or PreviousGCDSpell(evocation) and Spell(arcane_explosion)
	{
		#evocation,interrupt_if=mana.pct>96,if=mana.pct<85-2.5*buff.arcane_charge.stack
		if ManaPercent() < 85 - 2.5 * DebuffStacks(arcane_charge_debuff) and NotMoving() Spell(evocation)
	}
}

AddFunction ArcaneAoeCdPostConditions
{
	DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } and Spell(nether_tempest) or Spell(supernova) or DebuffStacks(arcane_charge_debuff) < 4 and Spell(arcane_orb) or PreviousGCDSpell(evocation) and Spell(arcane_explosion) or ArmorSetBonus(T17 4) and Enemies() < 10 and DebuffStacks(arcane_charge_debuff) == 4 and BuffPresent(arcane_instability_buff) and Spell(arcane_missiles) or BuffPresent(arcane_missiles_buff) and Spell(arcane_missiles) or Talent(arcane_orb_talent) and DebuffStacks(arcane_charge_debuff) == 4 and target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < SpellCooldown(arcane_orb) and Spell(nether_tempest) or DebuffStacks(arcane_charge_debuff) == 4 and Spell(arcane_barrage) or Glyph(glyph_of_cone_of_cold) and Spell(cone_of_cold) or Spell(arcane_explosion)
}

### actions.burn

AddFunction ArcaneBurnMainActions
{
	#call_action_list,name=init_crystal,if=talent.prismatic_crystal.enabled&cooldown.prismatic_crystal.up
	# if Talent(prismatic_crystal_talent) and not SpellCooldown(prismatic_crystal) > 0 ArcaneInitCrystalMainActions()
	#call_action_list,name=crystal_sequence,if=talent.prismatic_crystal.enabled&pet.prismatic_crystal.active
	# if Talent(prismatic_crystal_talent) and TotemPresent(prismatic_crystal) ArcaneCrystalSequenceMainActions()
	#arcane_missiles,if=buff.arcane_missiles.react=3
	if BuffStacks(arcane_missiles_buff) == 3 Spell(arcane_missiles)
	#arcane_missiles,if=set_bonus.tier17_4pc&buff.arcane_instability.react&buff.arcane_instability.remains<action.arcane_blast.execute_time
	if ArmorSetBonus(T17 4) and BuffPresent(arcane_instability_buff) and BuffRemaining(arcane_instability_buff) < ExecuteTime(arcane_blast) Spell(arcane_missiles)
	#supernova,if=target.time_to_die<8|charges=2
	if target.TimeToDie() < 8 or Charges(supernova) == 2 Spell(supernova)
	#nether_tempest,cycle_targets=1,if=target!=pet.prismatic_crystal&buff.arcane_charge.stack=4&(active_dot.nether_tempest=0|(ticking&remains<3.6))
	if not target.Name(prismatic_crystal) and DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } Spell(nether_tempest)
	#arcane_barrage,if=talent.arcane_orb.enabled&active_enemies>=3&buff.arcane_charge.stack=4&(cooldown.arcane_orb.remains<gcd.max|prev_gcd.arcane_orb)
	if Talent(arcane_orb_talent) and Enemies() >= 3 and DebuffStacks(arcane_charge_debuff) == 4 and { SpellCooldown(arcane_orb) < GCD() or PreviousGCDSpell(arcane_orb) } Spell(arcane_barrage)
	#arcane_blast,if=buff.arcane_charge.stack=4&mana.pct>93
	if DebuffStacks(arcane_charge_debuff) == 4 and ManaPercent() > 93 Spell(arcane_blast)
	#arcane_missiles,if=buff.arcane_charge.stack=4&(mana.pct>70|!cooldown.evocation.up|target.time_to_die<15)
	if DebuffStacks(arcane_charge_debuff) == 4 and { ManaPercent() > 70 or not { not SpellCooldown(evocation) > 0 } or target.TimeToDie() < 15 } Spell(arcane_missiles)
	#supernova,if=mana.pct>70&mana.pct<96
	if ManaPercent() > 70 and ManaPercent() < 96 Spell(supernova)
	#arcane_blast
	Spell(arcane_blast)
}

AddFunction ArcaneBurnShortCdActions
{
	#call_action_list,name=init_crystal,if=talent.prismatic_crystal.enabled&cooldown.prismatic_crystal.up
	if Talent(prismatic_crystal_talent) and not SpellCooldown(prismatic_crystal) > 0 ArcaneInitCrystalShortCdActions()

	unless Talent(prismatic_crystal_talent) and not SpellCooldown(prismatic_crystal) > 0 and ArcaneInitCrystalShortCdPostConditions()
	{
		#call_action_list,name=crystal_sequence,if=talent.prismatic_crystal.enabled&pet.prismatic_crystal.active
		if Talent(prismatic_crystal_talent) and TotemPresent(prismatic_crystal) ArcaneCrystalSequenceShortCdActions()

		unless Talent(prismatic_crystal_talent) and TotemPresent(prismatic_crystal) and ArcaneCrystalSequenceShortCdPostConditions()
		{
			unless BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or ArmorSetBonus(T17 4) and BuffPresent(arcane_instability_buff) and BuffRemaining(arcane_instability_buff) < ExecuteTime(arcane_blast) and Spell(arcane_missiles) or { target.TimeToDie() < 8 or Charges(supernova) == 2 } and Spell(supernova) or not target.Name(prismatic_crystal) and DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } and Spell(nether_tempest)
			{
				#arcane_orb,if=buff.arcane_charge.stack<4
				if DebuffStacks(arcane_charge_debuff) < 4 Spell(arcane_orb)

				unless Talent(arcane_orb_talent) and Enemies() >= 3 and DebuffStacks(arcane_charge_debuff) == 4 and { SpellCooldown(arcane_orb) < GCD() or PreviousGCDSpell(arcane_orb) } and Spell(arcane_barrage)
				{
					#presence_of_mind,if=mana.pct>96&(!talent.prismatic_crystal.enabled|!cooldown.prismatic_crystal.up)
					if ManaPercent() > 96 and { not Talent(prismatic_crystal_talent) or not { not SpellCooldown(prismatic_crystal) > 0 } } Spell(presence_of_mind)

					unless DebuffStacks(arcane_charge_debuff) == 4 and ManaPercent() > 93 and Spell(arcane_blast) or DebuffStacks(arcane_charge_debuff) == 4 and { ManaPercent() > 70 or not { not SpellCooldown(evocation) > 0 } or target.TimeToDie() < 15 } and Spell(arcane_missiles) or ManaPercent() > 70 and ManaPercent() < 96 and Spell(supernova)
					{
						#presence_of_mind,if=!talent.prismatic_crystal.enabled|!cooldown.prismatic_crystal.up
						if not Talent(prismatic_crystal_talent) or not { not SpellCooldown(prismatic_crystal) > 0 } Spell(presence_of_mind)
					}
				}
			}
		}
	}
}

AddFunction ArcaneBurnShortCdPostConditions
{
	Talent(prismatic_crystal_talent) and not SpellCooldown(prismatic_crystal) > 0 and ArcaneInitCrystalShortCdPostConditions() or Talent(prismatic_crystal_talent) and TotemPresent(prismatic_crystal) and ArcaneCrystalSequenceShortCdPostConditions() or BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or ArmorSetBonus(T17 4) and BuffPresent(arcane_instability_buff) and BuffRemaining(arcane_instability_buff) < ExecuteTime(arcane_blast) and Spell(arcane_missiles) or { target.TimeToDie() < 8 or Charges(supernova) == 2 } and Spell(supernova) or not target.Name(prismatic_crystal) and DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } and Spell(nether_tempest) or Talent(arcane_orb_talent) and Enemies() >= 3 and DebuffStacks(arcane_charge_debuff) == 4 and { SpellCooldown(arcane_orb) < GCD() or PreviousGCDSpell(arcane_orb) } and Spell(arcane_barrage) or DebuffStacks(arcane_charge_debuff) == 4 and ManaPercent() > 93 and Spell(arcane_blast) or DebuffStacks(arcane_charge_debuff) == 4 and { ManaPercent() > 70 or not { not SpellCooldown(evocation) > 0 } or target.TimeToDie() < 15 } and Spell(arcane_missiles) or ManaPercent() > 70 and ManaPercent() < 96 and Spell(supernova) or Spell(arcane_blast)
}

AddFunction ArcaneBurnCdActions
{
	#call_action_list,name=init_crystal,if=talent.prismatic_crystal.enabled&cooldown.prismatic_crystal.up
	if Talent(prismatic_crystal_talent) and not SpellCooldown(prismatic_crystal) > 0 ArcaneInitCrystalCdActions()

	unless Talent(prismatic_crystal_talent) and not SpellCooldown(prismatic_crystal) > 0 and ArcaneInitCrystalCdPostConditions()
	{
		#call_action_list,name=crystal_sequence,if=talent.prismatic_crystal.enabled&pet.prismatic_crystal.active
		if Talent(prismatic_crystal_talent) and TotemPresent(prismatic_crystal) ArcaneCrystalSequenceCdActions()

		unless Talent(prismatic_crystal_talent) and TotemPresent(prismatic_crystal) and ArcaneCrystalSequenceCdPostConditions()
		{
			#call_action_list,name=cooldowns
			ArcaneCooldownsCdActions()

			unless BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or ArmorSetBonus(T17 4) and BuffPresent(arcane_instability_buff) and BuffRemaining(arcane_instability_buff) < ExecuteTime(arcane_blast) and Spell(arcane_missiles) or { target.TimeToDie() < 8 or Charges(supernova) == 2 } and Spell(supernova) or not target.Name(prismatic_crystal) and DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } and Spell(nether_tempest) or DebuffStacks(arcane_charge_debuff) < 4 and Spell(arcane_orb) or Talent(arcane_orb_talent) and Enemies() >= 3 and DebuffStacks(arcane_charge_debuff) == 4 and { SpellCooldown(arcane_orb) < GCD() or PreviousGCDSpell(arcane_orb) } and Spell(arcane_barrage) or DebuffStacks(arcane_charge_debuff) == 4 and ManaPercent() > 93 and Spell(arcane_blast) or DebuffStacks(arcane_charge_debuff) == 4 and { ManaPercent() > 70 or not { not SpellCooldown(evocation) > 0 } or target.TimeToDie() < 15 } and Spell(arcane_missiles) or ManaPercent() > 70 and ManaPercent() < 96 and Spell(supernova)
			{
				#evocation,interrupt_if=mana.pct>100-10%spell_haste,if=target.time_to_die>10&mana.pct<30+2.5*active_enemies*(9-active_enemies)-(40*(t18_class_trinket&buff.arcane_power.up))
				if target.TimeToDie() > 10 and ManaPercent() < 30 and NotMoving() Spell(evocation)

				unless Spell(arcane_blast)
				{
					#evocation
					if NotMoving() Spell(evocation)
				}
			}
		}
	}
}

AddFunction ArcaneBurnCdPostConditions
{
	Talent(prismatic_crystal_talent) and not SpellCooldown(prismatic_crystal) > 0 and ArcaneInitCrystalCdPostConditions() or Talent(prismatic_crystal_talent) and TotemPresent(prismatic_crystal) and ArcaneCrystalSequenceCdPostConditions() or BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or ArmorSetBonus(T17 4) and BuffPresent(arcane_instability_buff) and BuffRemaining(arcane_instability_buff) < ExecuteTime(arcane_blast) and Spell(arcane_missiles) or { target.TimeToDie() < 8 or Charges(supernova) == 2 } and Spell(supernova) or not target.Name(prismatic_crystal) and DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } and Spell(nether_tempest) or DebuffStacks(arcane_charge_debuff) < 4 and Spell(arcane_orb) or Talent(arcane_orb_talent) and Enemies() >= 3 and DebuffStacks(arcane_charge_debuff) == 4 and { SpellCooldown(arcane_orb) < GCD() or PreviousGCDSpell(arcane_orb) } and Spell(arcane_barrage) or DebuffStacks(arcane_charge_debuff) == 4 and ManaPercent() > 93 and Spell(arcane_blast) or DebuffStacks(arcane_charge_debuff) == 4 and { ManaPercent() > 70 or not { not SpellCooldown(evocation) > 0 } or target.TimeToDie() < 15 } and Spell(arcane_missiles) or ManaPercent() > 70 and ManaPercent() < 96 and Spell(supernova) or Spell(arcane_blast)
}

### actions.conserve

AddFunction ArcaneConserveMainActions
{
	#arcane_missiles,if=buff.arcane_missiles.react=3|(talent.overpowered.enabled&buff.arcane_power.up&buff.arcane_power.remains<action.arcane_blast.execute_time)
	if BuffStacks(arcane_missiles_buff) == 3 or Talent(overpowered_talent) and BuffPresent(arcane_power_buff) and BuffRemaining(arcane_power_buff) < ExecuteTime(arcane_blast) Spell(arcane_missiles)
	#arcane_missiles,if=set_bonus.tier17_4pc&buff.arcane_instability.react&buff.arcane_instability.remains<action.arcane_blast.execute_time
	if ArmorSetBonus(T17 4) and BuffPresent(arcane_instability_buff) and BuffRemaining(arcane_instability_buff) < ExecuteTime(arcane_blast) Spell(arcane_missiles)
	#nether_tempest,cycle_targets=1,if=target!=pet.prismatic_crystal&buff.arcane_charge.stack=4&(active_dot.nether_tempest=0|(ticking&remains<3.6))
	if not target.Name(prismatic_crystal) and DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } Spell(nether_tempest)
	#supernova,if=target.time_to_die<8|(charges=2&(buff.arcane_power.up|!cooldown.arcane_power.up|!legendary_ring.cooldown.up)&(!talent.prismatic_crystal.enabled|cooldown.prismatic_crystal.remains>8))
	if target.TimeToDie() < 8 or Charges(supernova) == 2 and { BuffPresent(arcane_power_buff) or not { not SpellCooldown(arcane_power) > 0 } or ItemCooldown(legendary_ring_intellect) > 0 } and { not Talent(prismatic_crystal_talent) or SpellCooldown(prismatic_crystal) > 8 } Spell(supernova)
	#arcane_missiles,if=buff.arcane_missiles.react&debuff.mark_of_doom.remains>2*spell_haste+(target.distance%20)
	if BuffPresent(arcane_missiles_buff) and target.DebuffRemaining(mark_of_doom_debuff) > 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 Spell(arcane_missiles)
	#arcane_blast,if=buff.arcane_charge.stack=4&mana.pct>93
	if DebuffStacks(arcane_charge_debuff) == 4 and ManaPercent() > 93 Spell(arcane_blast)
	#arcane_barrage,if=talent.arcane_orb.enabled&active_enemies>=3&buff.arcane_charge.stack=4&(cooldown.arcane_orb.remains<gcd.max|prev_gcd.arcane_orb)
	if Talent(arcane_orb_talent) and Enemies() >= 3 and DebuffStacks(arcane_charge_debuff) == 4 and { SpellCooldown(arcane_orb) < GCD() or PreviousGCDSpell(arcane_orb) } Spell(arcane_barrage)
	#arcane_missiles,if=buff.arcane_charge.stack=4&(!talent.overpowered.enabled|cooldown.arcane_power.remains>10*spell_haste|legendary_ring.cooldown.remains>10*spell_haste)
	if DebuffStacks(arcane_charge_debuff) == 4 and { not Talent(overpowered_talent) or SpellCooldown(arcane_power) > 10 * { 100 / { 100 + SpellHaste() } } or ItemCooldown(legendary_ring_intellect) > 10 * { 100 / { 100 + SpellHaste() } } } Spell(arcane_missiles)
	#supernova,if=mana.pct<96&(buff.arcane_missiles.stack<2|buff.arcane_charge.stack=4)&(buff.arcane_power.up|(charges=1&(cooldown.arcane_power.remains>recharge_time|legendary_ring.cooldown.remains>recharge_time)))&(!talent.prismatic_crystal.enabled|current_target=pet.prismatic_crystal|(charges=1&cooldown.prismatic_crystal.remains>recharge_time+8))
	if ManaPercent() < 96 and { BuffStacks(arcane_missiles_buff) < 2 or DebuffStacks(arcane_charge_debuff) == 4 } and { BuffPresent(arcane_power_buff) or Charges(supernova) == 1 and { SpellCooldown(arcane_power) > SpellChargeCooldown(supernova) or ItemCooldown(legendary_ring_intellect) > SpellChargeCooldown(supernova) } } and { not Talent(prismatic_crystal_talent) or target.Name(prismatic_crystal) or Charges(supernova) == 1 and SpellCooldown(prismatic_crystal) > SpellChargeCooldown(supernova) + 8 } Spell(supernova)
	#nether_tempest,cycle_targets=1,if=target!=pet.prismatic_crystal&buff.arcane_charge.stack=4&(active_dot.nether_tempest=0|(ticking&remains<(10-3*talent.arcane_orb.enabled)*spell_haste))
	if not target.Name(prismatic_crystal) and DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < { 10 - 3 * TalentPoints(arcane_orb_talent) } * { 100 / { 100 + SpellHaste() } } } Spell(nether_tempest)
	#arcane_barrage,if=buff.arcane_charge.stack=4
	if DebuffStacks(arcane_charge_debuff) == 4 Spell(arcane_barrage)
	#arcane_blast
	Spell(arcane_blast)
	#arcane_barrage
	Spell(arcane_barrage)
}

AddFunction ArcaneConserveShortCdActions
{
	unless { BuffStacks(arcane_missiles_buff) == 3 or Talent(overpowered_talent) and BuffPresent(arcane_power_buff) and BuffRemaining(arcane_power_buff) < ExecuteTime(arcane_blast) } and Spell(arcane_missiles) or ArmorSetBonus(T17 4) and BuffPresent(arcane_instability_buff) and BuffRemaining(arcane_instability_buff) < ExecuteTime(arcane_blast) and Spell(arcane_missiles) or not target.Name(prismatic_crystal) and DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } and Spell(nether_tempest) or { target.TimeToDie() < 8 or Charges(supernova) == 2 and { BuffPresent(arcane_power_buff) or not { not SpellCooldown(arcane_power) > 0 } or ItemCooldown(legendary_ring_intellect) > 0 } and { not Talent(prismatic_crystal_talent) or SpellCooldown(prismatic_crystal) > 8 } } and Spell(supernova)
	{
		#arcane_orb,if=buff.arcane_charge.stack<2
		if DebuffStacks(arcane_charge_debuff) < 2 Spell(arcane_orb)
		#presence_of_mind,if=mana.pct>96&(!talent.prismatic_crystal.enabled|!cooldown.prismatic_crystal.up)
		if ManaPercent() > 96 and { not Talent(prismatic_crystal_talent) or not { not SpellCooldown(prismatic_crystal) > 0 } } Spell(presence_of_mind)

		unless BuffPresent(arcane_missiles_buff) and target.DebuffRemaining(mark_of_doom_debuff) > 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 and Spell(arcane_missiles) or DebuffStacks(arcane_charge_debuff) == 4 and ManaPercent() > 93 and Spell(arcane_blast) or Talent(arcane_orb_talent) and Enemies() >= 3 and DebuffStacks(arcane_charge_debuff) == 4 and { SpellCooldown(arcane_orb) < GCD() or PreviousGCDSpell(arcane_orb) } and Spell(arcane_barrage) or DebuffStacks(arcane_charge_debuff) == 4 and { not Talent(overpowered_talent) or SpellCooldown(arcane_power) > 10 * { 100 / { 100 + SpellHaste() } } or ItemCooldown(legendary_ring_intellect) > 10 * { 100 / { 100 + SpellHaste() } } } and Spell(arcane_missiles) or ManaPercent() < 96 and { BuffStacks(arcane_missiles_buff) < 2 or DebuffStacks(arcane_charge_debuff) == 4 } and { BuffPresent(arcane_power_buff) or Charges(supernova) == 1 and { SpellCooldown(arcane_power) > SpellChargeCooldown(supernova) or ItemCooldown(legendary_ring_intellect) > SpellChargeCooldown(supernova) } } and { not Talent(prismatic_crystal_talent) or target.Name(prismatic_crystal) or Charges(supernova) == 1 and SpellCooldown(prismatic_crystal) > SpellChargeCooldown(supernova) + 8 } and Spell(supernova) or not target.Name(prismatic_crystal) and DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < { 10 - 3 * TalentPoints(arcane_orb_talent) } * { 100 / { 100 + SpellHaste() } } } and Spell(nether_tempest) or DebuffStacks(arcane_charge_debuff) == 4 and Spell(arcane_barrage)
		{
			#presence_of_mind,if=buff.arcane_charge.stack<2&mana.pct>93
			if DebuffStacks(arcane_charge_debuff) < 2 and ManaPercent() > 93 Spell(presence_of_mind)
		}
	}
}

AddFunction ArcaneConserveShortCdPostConditions
{
	{ BuffStacks(arcane_missiles_buff) == 3 or Talent(overpowered_talent) and BuffPresent(arcane_power_buff) and BuffRemaining(arcane_power_buff) < ExecuteTime(arcane_blast) } and Spell(arcane_missiles) or ArmorSetBonus(T17 4) and BuffPresent(arcane_instability_buff) and BuffRemaining(arcane_instability_buff) < ExecuteTime(arcane_blast) and Spell(arcane_missiles) or not target.Name(prismatic_crystal) and DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } and Spell(nether_tempest) or { target.TimeToDie() < 8 or Charges(supernova) == 2 and { BuffPresent(arcane_power_buff) or not { not SpellCooldown(arcane_power) > 0 } or ItemCooldown(legendary_ring_intellect) > 0 } and { not Talent(prismatic_crystal_talent) or SpellCooldown(prismatic_crystal) > 8 } } and Spell(supernova) or BuffPresent(arcane_missiles_buff) and target.DebuffRemaining(mark_of_doom_debuff) > 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 and Spell(arcane_missiles) or DebuffStacks(arcane_charge_debuff) == 4 and ManaPercent() > 93 and Spell(arcane_blast) or Talent(arcane_orb_talent) and Enemies() >= 3 and DebuffStacks(arcane_charge_debuff) == 4 and { SpellCooldown(arcane_orb) < GCD() or PreviousGCDSpell(arcane_orb) } and Spell(arcane_barrage) or DebuffStacks(arcane_charge_debuff) == 4 and { not Talent(overpowered_talent) or SpellCooldown(arcane_power) > 10 * { 100 / { 100 + SpellHaste() } } or ItemCooldown(legendary_ring_intellect) > 10 * { 100 / { 100 + SpellHaste() } } } and Spell(arcane_missiles) or ManaPercent() < 96 and { BuffStacks(arcane_missiles_buff) < 2 or DebuffStacks(arcane_charge_debuff) == 4 } and { BuffPresent(arcane_power_buff) or Charges(supernova) == 1 and { SpellCooldown(arcane_power) > SpellChargeCooldown(supernova) or ItemCooldown(legendary_ring_intellect) > SpellChargeCooldown(supernova) } } and { not Talent(prismatic_crystal_talent) or target.Name(prismatic_crystal) or Charges(supernova) == 1 and SpellCooldown(prismatic_crystal) > SpellChargeCooldown(supernova) + 8 } and Spell(supernova) or not target.Name(prismatic_crystal) and DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < { 10 - 3 * TalentPoints(arcane_orb_talent) } * { 100 / { 100 + SpellHaste() } } } and Spell(nether_tempest) or DebuffStacks(arcane_charge_debuff) == 4 and Spell(arcane_barrage) or Spell(arcane_blast) or Spell(arcane_barrage)
}

AddFunction ArcaneConserveCdActions
{
	#call_action_list,name=cooldowns,if=target.time_to_die<15
	if target.TimeToDie() < 15 ArcaneCooldownsCdActions()
}

AddFunction ArcaneConserveCdPostConditions
{
	{ BuffStacks(arcane_missiles_buff) == 3 or Talent(overpowered_talent) and BuffPresent(arcane_power_buff) and BuffRemaining(arcane_power_buff) < ExecuteTime(arcane_blast) } and Spell(arcane_missiles) or ArmorSetBonus(T17 4) and BuffPresent(arcane_instability_buff) and BuffRemaining(arcane_instability_buff) < ExecuteTime(arcane_blast) and Spell(arcane_missiles) or not target.Name(prismatic_crystal) and DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < 3.6 } and Spell(nether_tempest) or { target.TimeToDie() < 8 or Charges(supernova) == 2 and { BuffPresent(arcane_power_buff) or not { not SpellCooldown(arcane_power) > 0 } or ItemCooldown(legendary_ring_intellect) > 0 } and { not Talent(prismatic_crystal_talent) or SpellCooldown(prismatic_crystal) > 8 } } and Spell(supernova) or DebuffStacks(arcane_charge_debuff) < 2 and Spell(arcane_orb) or BuffPresent(arcane_missiles_buff) and target.DebuffRemaining(mark_of_doom_debuff) > 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 and Spell(arcane_missiles) or DebuffStacks(arcane_charge_debuff) == 4 and ManaPercent() > 93 and Spell(arcane_blast) or Talent(arcane_orb_talent) and Enemies() >= 3 and DebuffStacks(arcane_charge_debuff) == 4 and { SpellCooldown(arcane_orb) < GCD() or PreviousGCDSpell(arcane_orb) } and Spell(arcane_barrage) or DebuffStacks(arcane_charge_debuff) == 4 and { not Talent(overpowered_talent) or SpellCooldown(arcane_power) > 10 * { 100 / { 100 + SpellHaste() } } or ItemCooldown(legendary_ring_intellect) > 10 * { 100 / { 100 + SpellHaste() } } } and Spell(arcane_missiles) or ManaPercent() < 96 and { BuffStacks(arcane_missiles_buff) < 2 or DebuffStacks(arcane_charge_debuff) == 4 } and { BuffPresent(arcane_power_buff) or Charges(supernova) == 1 and { SpellCooldown(arcane_power) > SpellChargeCooldown(supernova) or ItemCooldown(legendary_ring_intellect) > SpellChargeCooldown(supernova) } } and { not Talent(prismatic_crystal_talent) or target.Name(prismatic_crystal) or Charges(supernova) == 1 and SpellCooldown(prismatic_crystal) > SpellChargeCooldown(supernova) + 8 } and Spell(supernova) or not target.Name(prismatic_crystal) and DebuffStacks(arcane_charge_debuff) == 4 and { not DebuffCountOnAny(nether_tempest_debuff) > 0 or target.DebuffPresent(nether_tempest_debuff) and target.DebuffRemaining(nether_tempest_debuff) < { 10 - 3 * TalentPoints(arcane_orb_talent) } * { 100 / { 100 + SpellHaste() } } } and Spell(nether_tempest) or DebuffStacks(arcane_charge_debuff) == 4 and Spell(arcane_barrage) or Spell(arcane_blast) or Spell(arcane_barrage)
}

### actions.cooldowns

AddFunction ArcaneCooldownsCdActions
{
	#arcane_power
	Spell(arcane_power)
	#blood_fury
	Spell(blood_fury_sp)
	#berserking
	Spell(berserking)
	#arcane_torrent
	Spell(arcane_torrent_mana)
	#potion,name=draenic_intellect,if=buff.arcane_power.up&(!talent.prismatic_crystal.enabled|pet.prismatic_crystal.active)
	# if BuffPresent(arcane_power_buff) and { not Talent(prismatic_crystal_talent) or TotemPresent(prismatic_crystal) } ArcaneUsePotionIntellect()
	#use_item,slot=finger2
	Item(legendary_ring_intellect usable=1)
	#use_item,slot=trinket1
	# ArcaneUseItemActions()
}

### actions.crystal_sequence

AddFunction ArcaneCrystalSequenceMainActions
{
	#nether_tempest,if=buff.arcane_charge.stack=4&!ticking&pet.prismatic_crystal.remains>8
	if DebuffStacks(arcane_charge_debuff) == 4 and not target.DebuffPresent(nether_tempest_debuff) and TotemRemaining(prismatic_crystal) > 8 Spell(nether_tempest)
	#supernova,if=mana.pct<96
	if ManaPercent() < 96 Spell(supernova)
	#arcane_blast,if=buff.arcane_charge.stack=4&mana.pct>93&pet.prismatic_crystal.remains>cast_time
	if DebuffStacks(arcane_charge_debuff) == 4 and ManaPercent() > 93 and TotemRemaining(prismatic_crystal) > CastTime(arcane_blast) Spell(arcane_blast)
	#arcane_missiles,if=pet.prismatic_crystal.remains>2*spell_haste+(target.distance%20)
	if TotemRemaining(prismatic_crystal) > 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 Spell(arcane_missiles)
	#supernova,if=pet.prismatic_crystal.remains<2*spell_haste+(target.distance%20)
	if TotemRemaining(prismatic_crystal) < 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 Spell(supernova)
	#choose_target,if=pet.prismatic_crystal.remains<action.arcane_blast.cast_time&buff.presence_of_mind.down
	#arcane_blast
	Spell(arcane_blast)
}

AddFunction ArcaneCrystalSequenceShortCdActions
{
	unless DebuffStacks(arcane_charge_debuff) == 4 and not target.DebuffPresent(nether_tempest_debuff) and TotemRemaining(prismatic_crystal) > 8 and Spell(nether_tempest) or ManaPercent() < 96 and Spell(supernova)
	{
		#presence_of_mind,if=cooldown.cold_snap.up|pet.prismatic_crystal.remains<2*spell_haste
		if not SpellCooldown(cold_snap) > 0 or TotemRemaining(prismatic_crystal) < 2 * { 100 / { 100 + SpellHaste() } } Spell(presence_of_mind)
	}
}

AddFunction ArcaneCrystalSequenceShortCdPostConditions
{
	DebuffStacks(arcane_charge_debuff) == 4 and not target.DebuffPresent(nether_tempest_debuff) and TotemRemaining(prismatic_crystal) > 8 and Spell(nether_tempest) or ManaPercent() < 96 and Spell(supernova) or DebuffStacks(arcane_charge_debuff) == 4 and ManaPercent() > 93 and TotemRemaining(prismatic_crystal) > CastTime(arcane_blast) and Spell(arcane_blast) or TotemRemaining(prismatic_crystal) > 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 and Spell(arcane_missiles) or TotemRemaining(prismatic_crystal) < 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 and Spell(supernova) or Spell(arcane_blast)
}

AddFunction ArcaneCrystalSequenceCdActions
{
	#call_action_list,name=cooldowns
	ArcaneCooldownsCdActions()
}

AddFunction ArcaneCrystalSequenceCdPostConditions
{
	DebuffStacks(arcane_charge_debuff) == 4 and not target.DebuffPresent(nether_tempest_debuff) and TotemRemaining(prismatic_crystal) > 8 and Spell(nether_tempest) or ManaPercent() < 96 and Spell(supernova) or DebuffStacks(arcane_charge_debuff) == 4 and ManaPercent() > 93 and TotemRemaining(prismatic_crystal) > CastTime(arcane_blast) and Spell(arcane_blast) or TotemRemaining(prismatic_crystal) > 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 and Spell(arcane_missiles) or TotemRemaining(prismatic_crystal) < 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 and Spell(supernova) or Spell(arcane_blast)
}

### actions.init_burn

AddFunction ArcaneInitBurnMainActions
{
	#start_burn_phase,if=buff.arcane_charge.stack>=4&(legendary_ring.cooldown.remains<gcd.max|legendary_ring.cooldown.remains>target.time_to_die+15|!legendary_ring.has_cooldown)&(cooldown.prismatic_crystal.up|!talent.prismatic_crystal.enabled)&(cooldown.arcane_power.up|(glyph.arcane_power.enabled&cooldown.arcane_power.remains>60))&(cooldown.evocation.remains-2*buff.arcane_missiles.stack*spell_haste-gcd.max*talent.prismatic_crystal.enabled)*0.75*(1-0.1*(cooldown.arcane_power.remains<5))*(1-0.1*(talent.nether_tempest.enabled|talent.supernova.enabled))*(10%action.arcane_blast.execute_time)<mana.pct-20-2.5*active_enemies*(9-active_enemies)+(cooldown.evocation.remains*1.8%spell_haste)
	if DebuffStacks(arcane_charge_debuff) >= 4 and { ItemCooldown(legendary_ring_intellect) < GCD() or ItemCooldown(legendary_ring_intellect) > target.TimeToDie() + 15 or not ItemCooldown(legendary_ring_intellect) > 0 } and { not SpellCooldown(prismatic_crystal) > 0 or not Talent(prismatic_crystal_talent) } and { not SpellCooldown(arcane_power) > 0 or Glyph(glyph_of_arcane_power) and SpellCooldown(arcane_power) > 60 } and { SpellCooldown(evocation) - 2 * BuffStacks(arcane_missiles_buff) * { 100 / { 100 + SpellHaste() } } - GCD() * TalentPoints(prismatic_crystal_talent) } * 0.75 * { 1 - 0.1 * { SpellCooldown(arcane_power) < 5 } } * { 1 - 0.1 * { Talent(nether_tempest_talent) or Talent(supernova_talent) } } * { 10 / ExecuteTime(arcane_blast) } < ManaPercent() - 20 - 2.5 * Enemies() * { 9 - Enemies() } + SpellCooldown(evocation) * 1.8 / { 100 / { 100 + SpellHaste() } } and not GetState(burn_phase) > 0 SetState(burn_phase 1)
}

AddFunction ArcaneInitBurnShortCdActions
{
	#start_burn_phase,if=buff.arcane_charge.stack>=4&(legendary_ring.cooldown.remains<gcd.max|legendary_ring.cooldown.remains>target.time_to_die+15|!legendary_ring.has_cooldown)&(cooldown.prismatic_crystal.up|!talent.prismatic_crystal.enabled)&(cooldown.arcane_power.up|(glyph.arcane_power.enabled&cooldown.arcane_power.remains>60))&(cooldown.evocation.remains-2*buff.arcane_missiles.stack*spell_haste-gcd.max*talent.prismatic_crystal.enabled)*0.75*(1-0.1*(cooldown.arcane_power.remains<5))*(1-0.1*(talent.nether_tempest.enabled|talent.supernova.enabled))*(10%action.arcane_blast.execute_time)<mana.pct-20-2.5*active_enemies*(9-active_enemies)+(cooldown.evocation.remains*1.8%spell_haste)
	if DebuffStacks(arcane_charge_debuff) >= 4 and { ItemCooldown(legendary_ring_intellect) < GCD() or ItemCooldown(legendary_ring_intellect) > target.TimeToDie() + 15 or not ItemCooldown(legendary_ring_intellect) > 0 } and { not SpellCooldown(prismatic_crystal) > 0 or not Talent(prismatic_crystal_talent) } and { not SpellCooldown(arcane_power) > 0 or Glyph(glyph_of_arcane_power) and SpellCooldown(arcane_power) > 60 } and { SpellCooldown(evocation) - 2 * BuffStacks(arcane_missiles_buff) * { 100 / { 100 + SpellHaste() } } - GCD() * TalentPoints(prismatic_crystal_talent) } * 0.75 * { 1 - 0.1 * { SpellCooldown(arcane_power) < 5 } } * { 1 - 0.1 * { Talent(nether_tempest_talent) or Talent(supernova_talent) } } * { 10 / ExecuteTime(arcane_blast) } < ManaPercent() - 20 - 2.5 * Enemies() * { 9 - Enemies() } + SpellCooldown(evocation) * 1.8 / { 100 / { 100 + SpellHaste() } } and not GetState(burn_phase) > 0 SetState(burn_phase 1)
}

AddFunction ArcaneInitBurnCdActions
{
	#start_burn_phase,if=buff.arcane_charge.stack>=4&(legendary_ring.cooldown.remains<gcd.max|legendary_ring.cooldown.remains>target.time_to_die+15|!legendary_ring.has_cooldown)&(cooldown.prismatic_crystal.up|!talent.prismatic_crystal.enabled)&(cooldown.arcane_power.up|(glyph.arcane_power.enabled&cooldown.arcane_power.remains>60))&(cooldown.evocation.remains-2*buff.arcane_missiles.stack*spell_haste-gcd.max*talent.prismatic_crystal.enabled)*0.75*(1-0.1*(cooldown.arcane_power.remains<5))*(1-0.1*(talent.nether_tempest.enabled|talent.supernova.enabled))*(10%action.arcane_blast.execute_time)<mana.pct-20-2.5*active_enemies*(9-active_enemies)+(cooldown.evocation.remains*1.8%spell_haste)
	if DebuffStacks(arcane_charge_debuff) >= 4 and { ItemCooldown(legendary_ring_intellect) < GCD() or ItemCooldown(legendary_ring_intellect) > target.TimeToDie() + 15 or not ItemCooldown(legendary_ring_intellect) > 0 } and { not SpellCooldown(prismatic_crystal) > 0 or not Talent(prismatic_crystal_talent) } and { not SpellCooldown(arcane_power) > 0 or Glyph(glyph_of_arcane_power) and SpellCooldown(arcane_power) > 60 } and { SpellCooldown(evocation) - 2 * BuffStacks(arcane_missiles_buff) * { 100 / { 100 + SpellHaste() } } - GCD() * TalentPoints(prismatic_crystal_talent) } * 0.75 * { 1 - 0.1 * { SpellCooldown(arcane_power) < 5 } } * { 1 - 0.1 * { Talent(nether_tempest_talent) or Talent(supernova_talent) } } * { 10 / ExecuteTime(arcane_blast) } < ManaPercent() - 20 - 2.5 * Enemies() * { 9 - Enemies() } + SpellCooldown(evocation) * 1.8 / { 100 / { 100 + SpellHaste() } } and not GetState(burn_phase) > 0 SetState(burn_phase 1)
}

### actions.init_crystal

AddFunction ArcaneInitCrystalMainActions
{
	#call_action_list,name=conserve,if=buff.arcane_charge.stack<4|(buff.arcane_missiles.react&debuff.mark_of_doom.remains>2*spell_haste+(target.distance%20))
	if DebuffStacks(arcane_charge_debuff) < 4 or BuffPresent(arcane_missiles_buff) and target.DebuffRemaining(mark_of_doom_debuff) > 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 ArcaneConserveMainActions()
	#arcane_missiles,if=buff.arcane_missiles.react&t18_class_trinket
	if BuffPresent(arcane_missiles_buff) and HasTrinket(t18_class_trinket) Spell(arcane_missiles)
}

AddFunction ArcaneInitCrystalShortCdActions
{
	#call_action_list,name=conserve,if=buff.arcane_charge.stack<4|(buff.arcane_missiles.react&debuff.mark_of_doom.remains>2*spell_haste+(target.distance%20))
	if DebuffStacks(arcane_charge_debuff) < 4 or BuffPresent(arcane_missiles_buff) and target.DebuffRemaining(mark_of_doom_debuff) > 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 ArcaneConserveShortCdActions()

	unless { DebuffStacks(arcane_charge_debuff) < 4 or BuffPresent(arcane_missiles_buff) and target.DebuffRemaining(mark_of_doom_debuff) > 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 } and ArcaneConserveShortCdPostConditions() or BuffPresent(arcane_missiles_buff) and HasTrinket(t18_class_trinket) and Spell(arcane_missiles)
	{
		#prismatic_crystal
		# Spell(prismatic_crystal)
	}
}

AddFunction ArcaneInitCrystalShortCdPostConditions
{
	{ DebuffStacks(arcane_charge_debuff) < 4 or BuffPresent(arcane_missiles_buff) and target.DebuffRemaining(mark_of_doom_debuff) > 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 } and ArcaneConserveShortCdPostConditions() or BuffPresent(arcane_missiles_buff) and HasTrinket(t18_class_trinket) and Spell(arcane_missiles)
}

AddFunction ArcaneInitCrystalCdActions
{
	#call_action_list,name=conserve,if=buff.arcane_charge.stack<4|(buff.arcane_missiles.react&debuff.mark_of_doom.remains>2*spell_haste+(target.distance%20))
	if DebuffStacks(arcane_charge_debuff) < 4 or BuffPresent(arcane_missiles_buff) and target.DebuffRemaining(mark_of_doom_debuff) > 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 ArcaneConserveCdActions()
}

AddFunction ArcaneInitCrystalCdPostConditions
{
	{ DebuffStacks(arcane_charge_debuff) < 4 or BuffPresent(arcane_missiles_buff) and target.DebuffRemaining(mark_of_doom_debuff) > 2 * { 100 / { 100 + SpellHaste() } } + target.Distance() / 20 } and ArcaneConserveCdPostConditions() or BuffPresent(arcane_missiles_buff) and HasTrinket(t18_class_trinket) and Spell(arcane_missiles) or Spell(prismatic_crystal)
}

### actions.movement

AddFunction ArcaneMovementShortCdActions
{
	#blink,if=movement.distance>10
	# if 0 > 10 Spell(blink)
	#blazing_speed,if=movement.remains>0
	# if 0 > 0 Spell(blazing_speed)
	#ice_floes,if=buff.ice_floes.down&(raid_event.movement.distance>0|raid_event.movement.in<2*spell_haste)
	# if BuffExpires(ice_floes_buff) and { 0 > 0 or 600 < 2 * { 100 / { 100 + SpellHaste() } } } Spell(ice_floes)
}

AddFunction ArcaneMovementCdPostConditions
{
	0 > 10 and Spell(blink) or BuffExpires(ice_floes_buff) and { 0 > 0 or 600 < 2 * { 100 / { 100 + SpellHaste() } } } and Spell(ice_floes)
}

### actions.precombat

AddFunction ArcanePrecombatMainActions
{
	#flask,type=greater_draenic_intellect_flask
	#food,type=buttered_sturgeon
	#arcane_brilliance
	if BuffExpires(critical_strike_buff any=1) or BuffExpires(spell_power_multiplier_buff any=1) Spell(arcane_brilliance)
	#arcane_blast
	Spell(arcane_blast)
}

AddFunction ArcanePrecombatShortCdActions
{
	unless { BuffExpires(critical_strike_buff any=1) or BuffExpires(spell_power_multiplier_buff any=1) } and Spell(arcane_brilliance)
	{
		#snapshot_stats
		#rune_of_power,if=buff.rune_of_power.remains<150
		# if TotemRemaining(rune_of_power) < 150 Spell(rune_of_power)
	}
}

AddFunction ArcanePrecombatShortCdPostConditions
{
	{ BuffExpires(critical_strike_buff any=1) or BuffExpires(spell_power_multiplier_buff any=1) } and Spell(arcane_brilliance) or Spell(arcane_blast)
}

AddFunction ArcanePrecombatCdActions
{
	unless { BuffExpires(critical_strike_buff any=1) or BuffExpires(spell_power_multiplier_buff any=1) } and Spell(arcane_brilliance) or TotemRemaining(rune_of_power) < 150 and Spell(rune_of_power)
	{
		#mirror_image
		Spell(mirror_image)
		#potion,name=draenic_intellect
		# ArcaneUsePotionIntellect()
	}
}

AddFunction ArcanePrecombatCdPostConditions
{
	{ BuffExpires(critical_strike_buff any=1) or BuffExpires(spell_power_multiplier_buff any=1) } and Spell(arcane_brilliance) or TotemRemaining(rune_of_power) < 150 and Spell(rune_of_power) or Spell(arcane_blast)
}
]]

	OvaleScripts:RegisterScript("MAGE", "arcane", name, desc, code, "script")
end
