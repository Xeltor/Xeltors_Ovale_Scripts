local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_arcane"
	local desc = "[Xel][7.2.5] Mage: Arcane"
	local code = [[
Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_mage_spells)

Define(slipstream_talent 5)

# Arcane
AddIcon specialization=1 help=main
{
	if InCombat() InterruptActions()
	
	if InCombat() and target.InRange(arcane_blast) and HasFullControl()
	{
		# Cooldowns
		if Boss() ArcaneDefaultCdActions()
		
		ArcaneDefaultShortCdActions()
		
		ArcaneDefaultMainActions()
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
	{ Speed() == 0 or Talent(slipstream_talent) }
}

### actions.default

AddFunction ArcaneDefaultMainActions
{
	#stop_burn_phase,if=prev_gcd.1.evocation&burn_phase_duration>gcd.max
	if PreviousGCDSpell(evocation) and GetStateDuration(burn_phase) > GCD() and GetState(burn_phase) > 0 SetState(burn_phase 0)
	#call_action_list,name=build,if=buff.arcane_charge.stack<4
	if DebuffStacks(arcane_charge_debuff) < 4 ArcaneBuildMainActions()

	unless DebuffStacks(arcane_charge_debuff) < 4 and ArcaneBuildMainPostConditions()
	{
		#call_action_list,name=init_burn,if=buff.arcane_power.down&buff.arcane_charge.stack=4&(cooldown.mark_of_aluneth.remains=0|cooldown.mark_of_aluneth.remains>20)&(!talent.rune_of_power.enabled|(cooldown.arcane_power.remains<=action.rune_of_power.cast_time|action.rune_of_power.recharge_time<cooldown.arcane_power.remains))|target.time_to_die<45
		if { BuffExpires(arcane_power_buff) and DebuffStacks(arcane_charge_debuff) == 4 and { not SpellCooldown(mark_of_aluneth) > 0 or SpellCooldown(mark_of_aluneth) > 20 } and { not Talent(rune_of_power_talent) or SpellCooldown(arcane_power) <= CastTime(rune_of_power) or SpellChargeCooldown(rune_of_power) < SpellCooldown(arcane_power) } or target.TimeToDie() < 45 } ArcaneInitBurnMainActions()

		unless { BuffExpires(arcane_power_buff) and DebuffStacks(arcane_charge_debuff) == 4 and { not SpellCooldown(mark_of_aluneth) > 0 or SpellCooldown(mark_of_aluneth) > 20 } and { not Talent(rune_of_power_talent) or SpellCooldown(arcane_power) <= CastTime(rune_of_power) or SpellChargeCooldown(rune_of_power) < SpellCooldown(arcane_power) } or target.TimeToDie() < 45 } and ArcaneInitBurnMainPostConditions()
		{
			#call_action_list,name=burn,if=burn_phase
			if GetState(burn_phase) > 0 and Boss() ArcaneBurnMainActions()

			unless GetState(burn_phase) > 0 and Boss() and ArcaneBurnMainPostConditions()
			{
				#call_action_list,name=rop_phase,if=buff.rune_of_power.up&!burn_phase
				if BuffPresent(rune_of_power_buff) and not GetState(burn_phase) > 0 ArcaneRopPhaseMainActions()

				unless BuffPresent(rune_of_power_buff) and not GetState(burn_phase) > 0 and ArcaneRopPhaseMainPostConditions()
				{
					#call_action_list,name=conserve
					ArcaneConserveMainActions()
				}
			}
		}
	}
}

AddFunction ArcaneDefaultMainPostConditions
{
	DebuffStacks(arcane_charge_debuff) < 4 and ArcaneBuildMainPostConditions() or { BuffExpires(arcane_power_buff) and DebuffStacks(arcane_charge_debuff) == 4 and { not SpellCooldown(mark_of_aluneth) > 0 or SpellCooldown(mark_of_aluneth) > 20 } and { not Talent(rune_of_power_talent) or SpellCooldown(arcane_power) <= CastTime(rune_of_power) or SpellChargeCooldown(rune_of_power) < SpellCooldown(arcane_power) } or target.TimeToDie() < 45 } and Boss() and ArcaneInitBurnMainPostConditions() or GetState(burn_phase) > 0 and Boss() and ArcaneBurnMainPostConditions() or BuffPresent(rune_of_power_buff) and not GetState(burn_phase) > 0 and ArcaneRopPhaseMainPostConditions() or ArcaneConserveMainPostConditions()
}

AddFunction ArcaneDefaultShortCdActions
{
	#stop_burn_phase,if=prev_gcd.1.evocation&burn_phase_duration>gcd.max
	if PreviousGCDSpell(evocation) and GetStateDuration(burn_phase) > GCD() and GetState(burn_phase) > 0 SetState(burn_phase 0)
	#mark_of_aluneth,if=cooldown.arcane_power.remains>20
	if SpellCooldown(arcane_power) > 20 Spell(mark_of_aluneth)
	#call_action_list,name=build,if=buff.arcane_charge.stack<4
	if DebuffStacks(arcane_charge_debuff) < 4 ArcaneBuildShortCdActions()

	unless DebuffStacks(arcane_charge_debuff) < 4 and ArcaneBuildShortCdPostConditions()
	{
		#call_action_list,name=init_burn,if=buff.arcane_power.down&buff.arcane_charge.stack=4&(cooldown.mark_of_aluneth.remains=0|cooldown.mark_of_aluneth.remains>20)&(!talent.rune_of_power.enabled|(cooldown.arcane_power.remains<=action.rune_of_power.cast_time|action.rune_of_power.recharge_time<cooldown.arcane_power.remains))|target.time_to_die<45
		if { BuffExpires(arcane_power_buff) and DebuffStacks(arcane_charge_debuff) == 4 and { not SpellCooldown(mark_of_aluneth) > 0 or SpellCooldown(mark_of_aluneth) > 20 } and { not Talent(rune_of_power_talent) or SpellCooldown(arcane_power) <= CastTime(rune_of_power) or SpellChargeCooldown(rune_of_power) < SpellCooldown(arcane_power) } or target.TimeToDie() < 45 } and Boss() ArcaneInitBurnShortCdActions()

		unless { BuffExpires(arcane_power_buff) and DebuffStacks(arcane_charge_debuff) == 4 and { not SpellCooldown(mark_of_aluneth) > 0 or SpellCooldown(mark_of_aluneth) > 20 } and { not Talent(rune_of_power_talent) or SpellCooldown(arcane_power) <= CastTime(rune_of_power) or SpellChargeCooldown(rune_of_power) < SpellCooldown(arcane_power) } or target.TimeToDie() < 45 } and Boss() and ArcaneInitBurnShortCdPostConditions()
		{
			#call_action_list,name=burn,if=burn_phase
			if GetState(burn_phase) > 0 and Boss() ArcaneBurnShortCdActions()

			unless GetState(burn_phase) > 0 and Boss() and ArcaneBurnShortCdPostConditions()
			{
				#call_action_list,name=rop_phase,if=buff.rune_of_power.up&!burn_phase
				if BuffPresent(rune_of_power_buff) and not GetState(burn_phase) > 0 ArcaneRopPhaseShortCdActions()

				unless BuffPresent(rune_of_power_buff) and not GetState(burn_phase) > 0 and ArcaneRopPhaseShortCdPostConditions()
				{
					#call_action_list,name=conserve
					ArcaneConserveShortCdActions()
				}
			}
		}
	}
}

AddFunction ArcaneDefaultShortCdPostConditions
{
	DebuffStacks(arcane_charge_debuff) < 4 and ArcaneBuildShortCdPostConditions() or { BuffExpires(arcane_power_buff) and DebuffStacks(arcane_charge_debuff) == 4 and { not SpellCooldown(mark_of_aluneth) > 0 or SpellCooldown(mark_of_aluneth) > 20 } and { not Talent(rune_of_power_talent) or SpellCooldown(arcane_power) <= CastTime(rune_of_power) or SpellChargeCooldown(rune_of_power) < SpellCooldown(arcane_power) } or target.TimeToDie() < 45 } and Boss() and ArcaneInitBurnShortCdPostConditions() or GetState(burn_phase) > 0 and Boss() and ArcaneBurnShortCdPostConditions() or BuffPresent(rune_of_power_buff) and not GetState(burn_phase) > 0 and ArcaneRopPhaseShortCdPostConditions() or ArcaneConserveShortCdPostConditions()
}

AddFunction ArcaneDefaultCdActions
{
	#counterspell,if=target.debuff.casting.react
	# if target.IsInterruptible() ArcaneInterruptActions()
	#time_warp,if=(buff.bloodlust.down)&((time=0)|(equipped.132410&buff.arcane_power.up&prev_off_gcd.arcane_power)|(target.time_to_die<40))
	# if BuffExpires(burst_haste_buff any=1) and { TimeInCombat() == 0 or HasEquippedItem(132410) and BuffPresent(arcane_power_buff) and PreviousOffGCDSpell(arcane_power) or target.TimeToDie() < 40 } and DebuffExpires(burst_haste_debuff any=1) Spell(time_warp)
	#mirror_image,if=buff.arcane_power.down
	if BuffExpires(arcane_power_buff) Spell(mirror_image)
	#stop_burn_phase,if=prev_gcd.1.evocation&burn_phase_duration>gcd.max
	if PreviousGCDSpell(evocation) and GetStateDuration(burn_phase) > GCD() and GetState(burn_phase) > 0 SetState(burn_phase 0)

	unless SpellCooldown(arcane_power) > 20 and Spell(mark_of_aluneth)
	{
		#call_action_list,name=build,if=buff.arcane_charge.stack<4
		if DebuffStacks(arcane_charge_debuff) < 4 ArcaneBuildCdActions()

		unless DebuffStacks(arcane_charge_debuff) < 4 and ArcaneBuildCdPostConditions()
		{
			#call_action_list,name=init_burn,if=buff.arcane_power.down&buff.arcane_charge.stack=4&(cooldown.mark_of_aluneth.remains=0|cooldown.mark_of_aluneth.remains>20)&(!talent.rune_of_power.enabled|(cooldown.arcane_power.remains<=action.rune_of_power.cast_time|action.rune_of_power.recharge_time<cooldown.arcane_power.remains))|target.time_to_die<45
			if { BuffExpires(arcane_power_buff) and DebuffStacks(arcane_charge_debuff) == 4 and { not SpellCooldown(mark_of_aluneth) > 0 or SpellCooldown(mark_of_aluneth) > 20 } and { not Talent(rune_of_power_talent) or SpellCooldown(arcane_power) <= CastTime(rune_of_power) or SpellChargeCooldown(rune_of_power) < SpellCooldown(arcane_power) } or target.TimeToDie() < 45 } and Boss() ArcaneInitBurnCdActions()

			unless { BuffExpires(arcane_power_buff) and DebuffStacks(arcane_charge_debuff) == 4 and { not SpellCooldown(mark_of_aluneth) > 0 or SpellCooldown(mark_of_aluneth) > 20 } and { not Talent(rune_of_power_talent) or SpellCooldown(arcane_power) <= CastTime(rune_of_power) or SpellChargeCooldown(rune_of_power) < SpellCooldown(arcane_power) } or target.TimeToDie() < 45 } and Boss() and ArcaneInitBurnCdPostConditions()
			{
				#call_action_list,name=burn,if=burn_phase
				if GetState(burn_phase) > 0 and Boss() ArcaneBurnCdActions()

				unless GetState(burn_phase) > 0 and Boss() and ArcaneBurnCdPostConditions()
				{
					#call_action_list,name=rop_phase,if=buff.rune_of_power.up&!burn_phase
					if BuffPresent(rune_of_power_buff) and not GetState(burn_phase) > 0 ArcaneRopPhaseCdActions()

					unless BuffPresent(rune_of_power_buff) and not GetState(burn_phase) > 0 and ArcaneRopPhaseCdPostConditions()
					{
						#call_action_list,name=conserve
						ArcaneConserveCdActions()
					}
				}
			}
		}
	}
}

AddFunction ArcaneDefaultCdPostConditions
{
	SpellCooldown(arcane_power) > 20 and Spell(mark_of_aluneth) or DebuffStacks(arcane_charge_debuff) < 4 and ArcaneBuildCdPostConditions() or { BuffExpires(arcane_power_buff) and DebuffStacks(arcane_charge_debuff) == 4 and { not SpellCooldown(mark_of_aluneth) > 0 or SpellCooldown(mark_of_aluneth) > 20 } and { not Talent(rune_of_power_talent) or SpellCooldown(arcane_power) <= CastTime(rune_of_power) or SpellChargeCooldown(rune_of_power) < SpellCooldown(arcane_power) } or target.TimeToDie() < 45 } and Boss() and ArcaneInitBurnCdPostConditions() or GetState(burn_phase) > 0 and Boss() and ArcaneBurnCdPostConditions() or BuffPresent(rune_of_power_buff) and not GetState(burn_phase) > 0 and ArcaneRopPhaseCdPostConditions() or ArcaneConserveCdPostConditions()
}

### actions.build

AddFunction ArcaneBuildMainActions
{
	#charged_up,if=buff.arcane_charge.stack<=1
	if DebuffStacks(arcane_charge_debuff) <= 1 Spell(charged_up)
	#arcane_missiles,if=buff.arcane_missiles.react=3
	if BuffStacks(arcane_missiles_buff) == 3 and NotMoving() Spell(arcane_missiles)
	#arcane_explosion,if=active_enemies>1
	if Enemies(tagged=1) > 1 and target.Distance(less 10) Spell(arcane_explosion)
	#arcane_blast
	if Speed() == 0 Spell(arcane_blast)
}

AddFunction ArcaneBuildMainPostConditions
{
}

AddFunction ArcaneBuildShortCdActions
{
	unless DebuffStacks(arcane_charge_debuff) <= 1 and Spell(charged_up) or BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles)
	{
		#arcane_orb
		Spell(arcane_orb)
	}
}

AddFunction ArcaneBuildShortCdPostConditions
{
	DebuffStacks(arcane_charge_debuff) <= 1 and Spell(charged_up) or BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or Spell(arcane_blast)
}

AddFunction ArcaneBuildCdActions
{
}

AddFunction ArcaneBuildCdPostConditions
{
	DebuffStacks(arcane_charge_debuff) <= 1 and Spell(charged_up) or BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or Spell(arcane_orb) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or Spell(arcane_blast)
}

### actions.burn

AddFunction ArcaneBurnMainActions
{
	#call_action_list,name=cooldowns
	ArcaneCooldownsMainActions()

	unless ArcaneCooldownsMainPostConditions()
	{
		#charged_up,if=(equipped.132451&buff.arcane_charge.stack<=1)
		if HasEquippedItem(132451) and DebuffStacks(arcane_charge_debuff) <= 1 Spell(charged_up)
		#arcane_missiles,if=buff.arcane_missiles.react=3
		if BuffStacks(arcane_missiles_buff) == 3 and NotMoving() Spell(arcane_missiles)
		#nether_tempest,if=dot.nether_tempest.remains<=2|!ticking
		if target.DebuffRemaining(nether_tempest_debuff) <= 2 or not target.DebuffPresent(nether_tempest_debuff) Spell(nether_tempest)
		#arcane_explosion,if=active_enemies>1&mana.pct%10*execute_time>target.time_to_die
		if Enemies(tagged=1) > 1 and ManaPercent() / 10 * ExecuteTime(arcane_explosion) > target.TimeToDie() and target.Distance(less 10) Spell(arcane_explosion)
		#arcane_missiles,if=buff.arcane_missiles.react>1
		if BuffStacks(arcane_missiles_buff) > 1 and NotMoving() Spell(arcane_missiles)
		#arcane_explosion,if=active_enemies>1&buff.arcane_power.remains>cast_time
		if Enemies(tagged=1) > 1 and BuffRemaining(arcane_power_buff) > CastTime(arcane_explosion) and target.Distance(less 10) Spell(arcane_explosion)
		#arcane_blast,if=buff.presence_of_mind.up|buff.arcane_power.remains>cast_time
		if BuffPresent(presence_of_mind_buff) or { BuffRemaining(arcane_power_buff) > CastTime(arcane_blast) and Speed() == 0 } Spell(arcane_blast)
		#supernova,if=mana.pct<100
		if ManaPercent() < 100 Spell(supernova)
		#arcane_missiles,if=mana.pct>10&(talent.overpowered.enabled|buff.arcane_power.down)
		if ManaPercent() > 10 and { Talent(overpowered_talent) or BuffExpires(arcane_power_buff) } and NotMoving() Spell(arcane_missiles)
		#arcane_explosion,if=active_enemies>1
		if Enemies(tagged=1) > 1 and target.Distance(less 10) Spell(arcane_explosion)
		#arcane_barrage,if=talent.charged_up.enabled&(equipped.132451&cooldown.charged_up.remains=0&mana.pct<(100-(buff.arcane_charge.stack*0.03)))
		if Talent(charged_up_talent) and HasEquippedItem(132451) and not SpellCooldown(charged_up) > 0 and ManaPercent() < 100 - DebuffStacks(arcane_charge_debuff) * 0.03 Spell(arcane_barrage)
		#arcane_blast
		if Speed() == 0 Spell(arcane_blast)
	}
}

AddFunction ArcaneBurnMainPostConditions
{
	ArcaneCooldownsMainPostConditions()
}

AddFunction ArcaneBurnShortCdActions
{
	#call_action_list,name=cooldowns
	ArcaneCooldownsShortCdActions()

	unless ArcaneCooldownsShortCdPostConditions() or HasEquippedItem(132451) and DebuffStacks(arcane_charge_debuff) <= 1 and Spell(charged_up) or BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or { target.DebuffRemaining(nether_tempest_debuff) <= 2 or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest) or Enemies(tagged=1) > 1 and ManaPercent() / 10 * ExecuteTime(arcane_explosion) > target.TimeToDie() and Spell(arcane_explosion)
	{
		#presence_of_mind,if=buff.rune_of_power.remains<=2*action.arcane_blast.execute_time
		if TotemRemaining(rune_of_power) <= 2 * ExecuteTime(arcane_blast) Spell(presence_of_mind)
	}
}

AddFunction ArcaneBurnShortCdPostConditions
{
	ArcaneCooldownsShortCdPostConditions() or HasEquippedItem(132451) and DebuffStacks(arcane_charge_debuff) <= 1 and Spell(charged_up) or BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or { target.DebuffRemaining(nether_tempest_debuff) <= 2 or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest) or Enemies(tagged=1) > 1 and ManaPercent() / 10 * ExecuteTime(arcane_explosion) > target.TimeToDie() and Spell(arcane_explosion) or BuffStacks(arcane_missiles_buff) > 1 and Spell(arcane_missiles) or Enemies(tagged=1) > 1 and BuffRemaining(arcane_power_buff) > CastTime(arcane_explosion) and Spell(arcane_explosion) or { BuffPresent(presence_of_mind_buff) or BuffRemaining(arcane_power_buff) > CastTime(arcane_blast) } and Spell(arcane_blast) or ManaPercent() < 100 and Spell(supernova) or ManaPercent() > 10 and { Talent(overpowered_talent) or BuffExpires(arcane_power_buff) } and Spell(arcane_missiles) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or Talent(charged_up_talent) and HasEquippedItem(132451) and not SpellCooldown(charged_up) > 0 and ManaPercent() < 100 - DebuffStacks(arcane_charge_debuff) * 0.03 and Spell(arcane_barrage) or Spell(arcane_blast)
}

AddFunction ArcaneBurnCdActions
{
	#call_action_list,name=cooldowns
	ArcaneCooldownsCdActions()

	unless ArcaneCooldownsCdPostConditions() or HasEquippedItem(132451) and DebuffStacks(arcane_charge_debuff) <= 1 and Spell(charged_up) or BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or { target.DebuffRemaining(nether_tempest_debuff) <= 2 or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest) or Enemies(tagged=1) > 1 and ManaPercent() / 10 * ExecuteTime(arcane_explosion) > target.TimeToDie() and Spell(arcane_explosion) or BuffStacks(arcane_missiles_buff) > 1 and Spell(arcane_missiles) or Enemies(tagged=1) > 1 and BuffRemaining(arcane_power_buff) > CastTime(arcane_explosion) and Spell(arcane_explosion) or { BuffPresent(presence_of_mind_buff) or BuffRemaining(arcane_power_buff) > CastTime(arcane_blast) } and Spell(arcane_blast) or ManaPercent() < 100 and Spell(supernova) or ManaPercent() > 10 and { Talent(overpowered_talent) or BuffExpires(arcane_power_buff) } and Spell(arcane_missiles) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or Talent(charged_up_talent) and HasEquippedItem(132451) and not SpellCooldown(charged_up) > 0 and ManaPercent() < 100 - DebuffStacks(arcane_charge_debuff) * 0.03 and Spell(arcane_barrage) or Spell(arcane_blast)
	{
		#evocation,interrupt_if=mana.pct>99
		if NotMoving() Spell(evocation)
	}
}

AddFunction ArcaneBurnCdPostConditions
{
	ArcaneCooldownsCdPostConditions() or HasEquippedItem(132451) and DebuffStacks(arcane_charge_debuff) <= 1 and Spell(charged_up) or BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or { target.DebuffRemaining(nether_tempest_debuff) <= 2 or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest) or Enemies(tagged=1) > 1 and ManaPercent() / 10 * ExecuteTime(arcane_explosion) > target.TimeToDie() and Spell(arcane_explosion) or BuffStacks(arcane_missiles_buff) > 1 and Spell(arcane_missiles) or Enemies(tagged=1) > 1 and BuffRemaining(arcane_power_buff) > CastTime(arcane_explosion) and Spell(arcane_explosion) or { BuffPresent(presence_of_mind_buff) or BuffRemaining(arcane_power_buff) > CastTime(arcane_blast) } and Spell(arcane_blast) or ManaPercent() < 100 and Spell(supernova) or ManaPercent() > 10 and { Talent(overpowered_talent) or BuffExpires(arcane_power_buff) } and Spell(arcane_missiles) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or Talent(charged_up_talent) and HasEquippedItem(132451) and not SpellCooldown(charged_up) > 0 and ManaPercent() < 100 - DebuffStacks(arcane_charge_debuff) * 0.03 and Spell(arcane_barrage) or Spell(arcane_blast)
}

### actions.conserve

AddFunction ArcaneConserveMainActions
{
	#arcane_missiles,if=buff.arcane_missiles.react=3
	if BuffStacks(arcane_missiles_buff) == 3 and NotMoving() Spell(arcane_missiles)
	#arcane_blast,if=mana.pct>99
	if ManaPercent() > 99 and Speed() == 0 Spell(arcane_blast)
	#nether_tempest,if=(refreshable|!ticking)
	if target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) Spell(nether_tempest)
	#arcane_blast,if=buff.rhonins_assaulting_armwraps.up&equipped.132413
	if BuffPresent(rhonins_assaulting_armwraps_buff) and HasEquippedItem(132413) and Speed() == 0 Spell(arcane_blast)
	#arcane_missiles
	if NotMoving() Spell(arcane_missiles)
	#supernova,if=mana.pct<100
	if ManaPercent() < 100 Spell(supernova)
	#arcane_explosion,if=mana.pct>=82&equipped.132451&active_enemies>1
	if ManaPercent() >= 82 and HasEquippedItem(132451) and Enemies(tagged=1) > 1 and target.Distance(less 10) Spell(arcane_explosion)
	#arcane_blast,if=mana.pct>=82&equipped.132451
	if ManaPercent() >= 82 and HasEquippedItem(132451) and Speed() == 0 Spell(arcane_blast)
	#arcane_barrage,if=mana.pct<100&cooldown.arcane_power.remains>5
	if ManaPercent() < 100 and SpellCooldown(arcane_power) > 5 Spell(arcane_barrage)
	#arcane_explosion,if=active_enemies>1
	if Enemies(tagged=1) > 1 and target.Distance(less 10) Spell(arcane_explosion)
	#arcane_blast
	if Speed() == 0 Spell(arcane_blast)
}

AddFunction ArcaneConserveMainPostConditions
{
}

AddFunction ArcaneConserveShortCdActions
{
}

AddFunction ArcaneConserveShortCdPostConditions
{
	BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or ManaPercent() > 99 and Spell(arcane_blast) or { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest) or BuffPresent(rhonins_assaulting_armwraps_buff) and HasEquippedItem(132413) and Spell(arcane_blast) or Spell(arcane_missiles) or ManaPercent() < 100 and Spell(supernova) or ManaPercent() >= 82 and HasEquippedItem(132451) and Enemies(tagged=1) > 1 and Spell(arcane_explosion) or ManaPercent() >= 82 and HasEquippedItem(132451) and Spell(arcane_blast) or ManaPercent() < 100 and SpellCooldown(arcane_power) > 5 and Spell(arcane_barrage) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or Spell(arcane_blast)
}

AddFunction ArcaneConserveCdActions
{
}

AddFunction ArcaneConserveCdPostConditions
{
	BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or ManaPercent() > 99 and Spell(arcane_blast) or { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest) or BuffPresent(rhonins_assaulting_armwraps_buff) and HasEquippedItem(132413) and Spell(arcane_blast) or Spell(arcane_missiles) or ManaPercent() < 100 and Spell(supernova) or ManaPercent() >= 82 and HasEquippedItem(132451) and Enemies(tagged=1) > 1 and Spell(arcane_explosion) or ManaPercent() >= 82 and HasEquippedItem(132451) and Spell(arcane_blast) or ManaPercent() < 100 and SpellCooldown(arcane_power) > 5 and Spell(arcane_barrage) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or Spell(arcane_blast)
}

### actions.cooldowns

AddFunction ArcaneCooldownsMainActions
{
}

AddFunction ArcaneCooldownsMainPostConditions
{
}

AddFunction ArcaneCooldownsShortCdActions
{
	#rune_of_power,if=mana.pct>45&buff.arcane_power.down
	if ManaPercent() > 45 and BuffExpires(arcane_power_buff) Spell(rune_of_power)
}

AddFunction ArcaneCooldownsShortCdPostConditions
{
}

AddFunction ArcaneCooldownsCdActions
{
	unless ManaPercent() > 45 and BuffExpires(arcane_power_buff) and Spell(rune_of_power)
	{
		#arcane_power
		Spell(arcane_power)
		#blood_fury
		Spell(blood_fury_sp)
		#berserking
		Spell(berserking)
		#arcane_torrent
		Spell(arcane_torrent_mana)
		#potion,name=deadly_grace,if=buff.arcane_power.up&(buff.berserking.up|buff.blood_fury.up)
		# if BuffPresent(arcane_power_buff) and { BuffPresent(berserking_buff) or BuffPresent(blood_fury_sp_buff) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(deadly_grace_potion usable=1)
	}
}

AddFunction ArcaneCooldownsCdPostConditions
{
	ManaPercent() > 45 and BuffExpires(arcane_power_buff) and Spell(rune_of_power)
}

### actions.init_burn

AddFunction ArcaneInitBurnMainActions
{
	#nether_tempest,if=dot.nether_tempest.remains<10&(prev_gcd.1.mark_of_aluneth|(talent.rune_of_power.enabled&cooldown.rune_of_power.remains<gcd.max))
	if target.DebuffRemaining(nether_tempest_debuff) < 10 and { PreviousGCDSpell(mark_of_aluneth) or Talent(rune_of_power_talent) and SpellCooldown(rune_of_power) < GCD() } Spell(nether_tempest)
	#start_burn_phase,if=((cooldown.evocation.remains-(2*burn_phase_duration))%2<burn_phase_duration)|cooldown.arcane_power.remains=0|target.time_to_die<55
	if { { SpellCooldown(evocation) - 2 * GetStateDuration(burn_phase) } / 2 < GetStateDuration(burn_phase) or not SpellCooldown(arcane_power) > 0 or target.TimeToDie() < 55 } and not GetState(burn_phase) > 0 SetState(burn_phase 1)
}

AddFunction ArcaneInitBurnMainPostConditions
{
}

AddFunction ArcaneInitBurnShortCdActions
{
	#mark_of_aluneth
	Spell(mark_of_aluneth)

	unless target.DebuffRemaining(nether_tempest_debuff) < 10 and { PreviousGCDSpell(mark_of_aluneth) or Talent(rune_of_power_talent) and SpellCooldown(rune_of_power) < GCD() } and Spell(nether_tempest)
	{
		#rune_of_power
		if Speed() == 0 Spell(rune_of_power)
		#start_burn_phase,if=((cooldown.evocation.remains-(2*burn_phase_duration))%2<burn_phase_duration)|cooldown.arcane_power.remains=0|target.time_to_die<55
		if { { SpellCooldown(evocation) - 2 * GetStateDuration(burn_phase) } / 2 < GetStateDuration(burn_phase) or not SpellCooldown(arcane_power) > 0 or target.TimeToDie() < 55 } and not GetState(burn_phase) > 0 SetState(burn_phase 1)
	}
}

AddFunction ArcaneInitBurnShortCdPostConditions
{
	target.DebuffRemaining(nether_tempest_debuff) < 10 and { PreviousGCDSpell(mark_of_aluneth) or Talent(rune_of_power_talent) and SpellCooldown(rune_of_power) < GCD() } and Spell(nether_tempest)
}

AddFunction ArcaneInitBurnCdActions
{
	unless Spell(mark_of_aluneth) or target.DebuffRemaining(nether_tempest_debuff) < 10 and { PreviousGCDSpell(mark_of_aluneth) or Talent(rune_of_power_talent) and SpellCooldown(rune_of_power) < GCD() } and Spell(nether_tempest) or Spell(rune_of_power)
	{
		#start_burn_phase,if=((cooldown.evocation.remains-(2*burn_phase_duration))%2<burn_phase_duration)|cooldown.arcane_power.remains=0|target.time_to_die<55
		if { { SpellCooldown(evocation) - 2 * GetStateDuration(burn_phase) } / 2 < GetStateDuration(burn_phase) or not SpellCooldown(arcane_power) > 0 or target.TimeToDie() < 55 } and not GetState(burn_phase) > 0 SetState(burn_phase 1)
	}
}

AddFunction ArcaneInitBurnCdPostConditions
{
	Spell(mark_of_aluneth) or target.DebuffRemaining(nether_tempest_debuff) < 10 and { PreviousGCDSpell(mark_of_aluneth) or Talent(rune_of_power_talent) and SpellCooldown(rune_of_power) < GCD() } and Spell(nether_tempest) or Spell(rune_of_power)
}

### actions.precombat

AddFunction ArcanePrecombatMainActions
{
	#flask,type=flask_of_the_whispered_pact
	#food,type=the_hungry_magister
	#augmentation,type=defiled
	#summon_arcane_familiar
	Spell(summon_arcane_familiar)
	#arcane_blast
	Spell(arcane_blast)
}

AddFunction ArcanePrecombatMainPostConditions
{
}

AddFunction ArcanePrecombatShortCdActions
{
}

AddFunction ArcanePrecombatShortCdPostConditions
{
	Spell(summon_arcane_familiar) or Spell(arcane_blast)
}

AddFunction ArcanePrecombatCdActions
{
	unless Spell(summon_arcane_familiar)
	{
		#snapshot_stats
		#mirror_image
		Spell(mirror_image)
		#potion,name=deadly_grace
		# if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(deadly_grace_potion usable=1)
	}
}

AddFunction ArcanePrecombatCdPostConditions
{
	Spell(summon_arcane_familiar) or Spell(arcane_blast)
}

### actions.rop_phase

AddFunction ArcaneRopPhaseMainActions
{
	#arcane_missiles,if=buff.arcane_missiles.react=3
	if BuffStacks(arcane_missiles_buff) == 3 and NotMoving() Spell(arcane_missiles)
	#nether_tempest,if=dot.nether_tempest.remains<=2|!ticking
	if target.DebuffRemaining(nether_tempest_debuff) <= 2 or not target.DebuffPresent(nether_tempest_debuff) Spell(nether_tempest)
	#arcane_missiles,if=buff.arcane_charge.stack=4
	if DebuffStacks(arcane_charge_debuff) == 4 and NotMoving() Spell(arcane_missiles)
	#arcane_explosion,if=active_enemies>1
	if Enemies(tagged=1) > 1 and target.Distance(less 10) Spell(arcane_explosion)
	#arcane_blast,if=mana.pct>45
	if ManaPercent() > 45 and Speed() == 0 Spell(arcane_blast)
	#arcane_barrage
	Spell(arcane_barrage)
}

AddFunction ArcaneRopPhaseMainPostConditions
{
}

AddFunction ArcaneRopPhaseShortCdActions
{
}

AddFunction ArcaneRopPhaseShortCdPostConditions
{
	BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or { target.DebuffRemaining(nether_tempest_debuff) <= 2 or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest) or DebuffStacks(arcane_charge_debuff) == 4 and Spell(arcane_missiles) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or ManaPercent() > 45 and Spell(arcane_blast) or Spell(arcane_barrage)
}

AddFunction ArcaneRopPhaseCdActions
{
}

AddFunction ArcaneRopPhaseCdPostConditions
{
	BuffStacks(arcane_missiles_buff) == 3 and Spell(arcane_missiles) or { target.DebuffRemaining(nether_tempest_debuff) <= 2 or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest) or DebuffStacks(arcane_charge_debuff) == 4 and Spell(arcane_missiles) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or ManaPercent() > 45 and Spell(arcane_blast) or Spell(arcane_barrage)
}
]]

	OvaleScripts:RegisterScript("MAGE", "arcane", name, desc, code, "script")
end
