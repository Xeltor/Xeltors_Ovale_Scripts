local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_arms"
	local desc = "[Xel][7.1] Warrior: Arms"
	local code = [[
# Based on SimulationCraft profile "Warrior_Arms_T19M".
#    class=warrior
#    spec=arms
#    talents=1332311

Include(ovale_common)

Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warrior_spells)

# Arms
AddIcon specialization=1 help=main
{
	if InCombat() InterruptActions()

	if target.InRange(mortal_strike) and HasFullControl()
	{
		# Cooldowns
		if Boss()
		{
			ArmsDefaultCdActions()
		}
		
		# Short Cooldowns
		ArmsDefaultShortCdActions()
		
		# Lazy about it
		Spell(victory_rush)
		
		# Normal rotation
		ArmsDefaultMainActions()
	}
	# Move to the target!
	if target.InRange(charge) and InCombat() and HasFullControl() Spell(heroic_throw)
	if target.InRange(charge) and InCombat() and HasFullControl() and { TimeInCombat() < 6 or Falling() } Spell(charge)
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		if target.InRange(pummel) Spell(pummel)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_rage)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

### actions.default

AddFunction ArmsDefaultMainActions
{
	#battle_cry,if=gcd.remains<0.25&(buff.shattered_defenses.up|cooldown.warbreaker.remains>7&cooldown.colossus_smash.remains>7|cooldown.colossus_smash.remains&debuff.colossus_smash.remains>gcd)|target.time_to_die<=5
	if GCDRemaining() < 0.25 and { BuffPresent(shattered_defenses_buff) or SpellCooldown(warbreaker) > 7 and SpellCooldown(colossus_smash) > 7 or SpellCooldown(colossus_smash) > 0 and target.DebuffRemaining(colossus_smash_debuff) > GCD() } or target.TimeToDie() <= 5 Spell(battle_cry)
	#rend,if=remains<gcd
	if target.DebuffRemaining(rend_debuff) < GCD() Spell(rend)
	#colossus_smash,if=cooldown_react&debuff.colossus_smash.remains<gcd
	if not SpellCooldown(colossus_smash) > 0 and target.DebuffRemaining(colossus_smash_debuff) < GCD() Spell(colossus_smash)
	#overpower,if=buff.overpower.react
	if BuffPresent(overpower_buff) Spell(overpower)
	#run_action_list,name=cleave,if=spell_targets.whirlwind>=2&talent.sweeping_strikes.enabled
	if Enemies(tagged=1) >= 2 and Talent(sweeping_strikes_talent) ArmsCleaveMainActions()

	unless Enemies(tagged=1) >= 2 and Talent(sweeping_strikes_talent) and ArmsCleaveMainPostConditions()
	{
		#run_action_list,name=aoe,if=spell_targets.whirlwind>=5&!talent.sweeping_strikes.enabled
		if Enemies(tagged=1) >= 5 and not Talent(sweeping_strikes_talent) ArmsAoeMainActions()

		unless Enemies(tagged=1) >= 5 and not Talent(sweeping_strikes_talent) and ArmsAoeMainPostConditions()
		{
			#run_action_list,name=execute,target_if=target.health.pct<=20&spell_targets.whirlwind<5
			if target.HealthPercent() <= 20 and Enemies(tagged=1) < 5 ArmsExecuteMainActions()

			unless target.HealthPercent() <= 20 and Enemies(tagged=1) < 5 and ArmsExecuteMainPostConditions()
			{
				#run_action_list,name=single,if=target.health.pct>20
				if target.HealthPercent() > 20 ArmsSingleMainActions()
			}
		}
	}
}

AddFunction ArmsDefaultMainPostConditions
{
	Enemies(tagged=1) >= 2 and Talent(sweeping_strikes_talent) and ArmsCleaveMainPostConditions() or Enemies(tagged=1) >= 5 and not Talent(sweeping_strikes_talent) and ArmsAoeMainPostConditions() or target.HealthPercent() <= 20 and Enemies(tagged=1) < 5 and ArmsExecuteMainPostConditions() or target.HealthPercent() > 20 and ArmsSingleMainPostConditions()
}

AddFunction ArmsDefaultShortCdActions
{
	#charge
	# if CheckBoxOn(opt_melee_range) and target.InRange(charge) Spell(charge)
	#auto_attack
	# ArmsGetInMeleeRange()

	unless { GCDRemaining() < 0.25 and { BuffPresent(shattered_defenses_buff) or SpellCooldown(warbreaker) > 7 and SpellCooldown(colossus_smash) > 7 or SpellCooldown(colossus_smash) > 0 and target.DebuffRemaining(colossus_smash_debuff) > GCD() } or target.TimeToDie() <= 5 } and Spell(battle_cry)
	{
		#heroic_leap
		# if CheckBoxOn(opt_melee_range) and target.InRange(charge) Spell(heroic_leap)

		unless target.DebuffRemaining(rend_debuff) < GCD() and Spell(rend)
		{
			#focused_rage,if=buff.battle_cry_deadly_calm.remains>cooldown.focused_rage.remains&(buff.focused_rage.stack<3|cooldown.mortal_strike.remains)
			if BuffRemaining(battle_cry_deadly_calm_buff) > SpellCooldown(focused_rage) and { BuffStacks(focused_rage_buff) < 3 or SpellCooldown(mortal_strike) > 0 } Spell(focused_rage)

			unless not SpellCooldown(colossus_smash) > 0 and target.DebuffRemaining(colossus_smash_debuff) < GCD() and Spell(colossus_smash)
			{
				#warbreaker,if=debuff.colossus_smash.remains<gcd
				if target.DebuffRemaining(colossus_smash_debuff) < GCD() Spell(warbreaker)
				#ravager
				Spell(ravager)

				unless BuffPresent(overpower_buff) and Spell(overpower)
				{
					#run_action_list,name=cleave,if=spell_targets.whirlwind>=2&talent.sweeping_strikes.enabled
					if Enemies(tagged=1) >= 2 and Talent(sweeping_strikes_talent) ArmsCleaveShortCdActions()

					unless Enemies(tagged=1) >= 2 and Talent(sweeping_strikes_talent) and ArmsCleaveShortCdPostConditions()
					{
						#run_action_list,name=aoe,if=spell_targets.whirlwind>=5&!talent.sweeping_strikes.enabled
						if Enemies(tagged=1) >= 5 and not Talent(sweeping_strikes_talent) ArmsAoeShortCdActions()

						unless Enemies(tagged=1) >= 5 and not Talent(sweeping_strikes_talent) and ArmsAoeShortCdPostConditions()
						{
							#run_action_list,name=execute,target_if=target.health.pct<=20&spell_targets.whirlwind<5
							if target.HealthPercent() <= 20 and Enemies(tagged=1) < 5 ArmsExecuteShortCdActions()

							unless target.HealthPercent() <= 20 and Enemies(tagged=1) < 5 and ArmsExecuteShortCdPostConditions()
							{
								#run_action_list,name=single,if=target.health.pct>20
								if target.HealthPercent() > 20 ArmsSingleShortCdActions()
							}
						}
					}
				}
			}
		}
	}
}

AddFunction ArmsDefaultShortCdPostConditions
{
	{ GCDRemaining() < 0.25 and { BuffPresent(shattered_defenses_buff) or SpellCooldown(warbreaker) > 7 and SpellCooldown(colossus_smash) > 7 or SpellCooldown(colossus_smash) > 0 and target.DebuffRemaining(colossus_smash_debuff) > GCD() } or target.TimeToDie() <= 5 } and Spell(battle_cry) or target.DebuffRemaining(rend_debuff) < GCD() and Spell(rend) or not SpellCooldown(colossus_smash) > 0 and target.DebuffRemaining(colossus_smash_debuff) < GCD() and Spell(colossus_smash) or BuffPresent(overpower_buff) and Spell(overpower) or Enemies(tagged=1) >= 2 and Talent(sweeping_strikes_talent) and ArmsCleaveShortCdPostConditions() or Enemies(tagged=1) >= 5 and not Talent(sweeping_strikes_talent) and ArmsAoeShortCdPostConditions() or target.HealthPercent() <= 20 and Enemies(tagged=1) < 5 and ArmsExecuteShortCdPostConditions() or target.HealthPercent() > 20 and ArmsSingleShortCdPostConditions()
}

AddFunction ArmsDefaultCdActions
{
	#pummel
	# ArmsInterruptActions()
	#potion,name=old_war,if=buff.avatar.up&buff.battle_cry.up&debuff.colossus_smash.up|target.time_to_die<=26
	#blood_fury,if=buff.battle_cry.up|target.time_to_die<=16
	if BuffPresent(battle_cry_buff) or target.TimeToDie() <= 16 Spell(blood_fury_ap)
	#berserking,if=buff.battle_cry.up|target.time_to_die<=11
	if BuffPresent(battle_cry_buff) or target.TimeToDie() <= 11 Spell(berserking)
	#arcane_torrent,if=buff.battle_cry_deadly_calm.down&rage.deficit>40
	if BuffExpires(battle_cry_deadly_calm_buff) and RageDeficit() > 40 Spell(arcane_torrent_rage)

	unless { GCDRemaining() < 0.25 and { BuffPresent(shattered_defenses_buff) or SpellCooldown(warbreaker) > 7 and SpellCooldown(colossus_smash) > 7 or SpellCooldown(colossus_smash) > 0 and target.DebuffRemaining(colossus_smash_debuff) > GCD() } or target.TimeToDie() <= 5 } and Spell(battle_cry)
	{
		#avatar,if=gcd.remains<0.25&(buff.battle_cry.up|cooldown.battle_cry.remains<15)|target.time_to_die<=20
		if GCDRemaining() < 0.25 and { BuffPresent(battle_cry_buff) or SpellCooldown(battle_cry) < 15 } or target.TimeToDie() <= 20 Spell(avatar)
		#use_item,name=gift_of_radiance
		# ArmsUseItemActions()

		unless target.DebuffRemaining(rend_debuff) < GCD() and Spell(rend) or not SpellCooldown(colossus_smash) > 0 and target.DebuffRemaining(colossus_smash_debuff) < GCD() and Spell(colossus_smash) or target.DebuffRemaining(colossus_smash_debuff) < GCD() and Spell(warbreaker) or Spell(ravager) or BuffPresent(overpower_buff) and Spell(overpower)
		{
			#run_action_list,name=cleave,if=spell_targets.whirlwind>=2&talent.sweeping_strikes.enabled
			if Enemies(tagged=1) >= 2 and Talent(sweeping_strikes_talent) ArmsCleaveCdActions()

			unless Enemies(tagged=1) >= 2 and Talent(sweeping_strikes_talent) and ArmsCleaveCdPostConditions()
			{
				#run_action_list,name=aoe,if=spell_targets.whirlwind>=5&!talent.sweeping_strikes.enabled
				if Enemies(tagged=1) >= 5 and not Talent(sweeping_strikes_talent) ArmsAoeCdActions()

				unless Enemies(tagged=1) >= 5 and not Talent(sweeping_strikes_talent) and ArmsAoeCdPostConditions()
				{
					#run_action_list,name=execute,target_if=target.health.pct<=20&spell_targets.whirlwind<5
					if target.HealthPercent() <= 20 and Enemies(tagged=1) < 5 ArmsExecuteCdActions()

					unless target.HealthPercent() <= 20 and Enemies(tagged=1) < 5 and ArmsExecuteCdPostConditions()
					{
						#run_action_list,name=single,if=target.health.pct>20
						if target.HealthPercent() > 20 ArmsSingleCdActions()
					}
				}
			}
		}
	}
}

AddFunction ArmsDefaultCdPostConditions
{
	{ GCDRemaining() < 0.25 and { BuffPresent(shattered_defenses_buff) or SpellCooldown(warbreaker) > 7 and SpellCooldown(colossus_smash) > 7 or SpellCooldown(colossus_smash) > 0 and target.DebuffRemaining(colossus_smash_debuff) > GCD() } or target.TimeToDie() <= 5 } and Spell(battle_cry) or target.DebuffRemaining(rend_debuff) < GCD() and Spell(rend) or not SpellCooldown(colossus_smash) > 0 and target.DebuffRemaining(colossus_smash_debuff) < GCD() and Spell(colossus_smash) or target.DebuffRemaining(colossus_smash_debuff) < GCD() and Spell(warbreaker) or Spell(ravager) or BuffPresent(overpower_buff) and Spell(overpower) or Enemies(tagged=1) >= 2 and Talent(sweeping_strikes_talent) and ArmsCleaveCdPostConditions() or Enemies(tagged=1) >= 5 and not Talent(sweeping_strikes_talent) and ArmsAoeCdPostConditions() or target.HealthPercent() <= 20 and Enemies(tagged=1) < 5 and ArmsExecuteCdPostConditions() or target.HealthPercent() > 20 and ArmsSingleCdPostConditions()
}

### actions.aoe

AddFunction ArmsAoeMainActions
{
	#mortal_strike,if=cooldown_react
	if not SpellCooldown(mortal_strike) > 0 Spell(mortal_strike)
	#execute,if=buff.stone_heart.react
	if BuffPresent(stone_heart_buff) Spell(execute_arms)
	#colossus_smash,if=cooldown_react&buff.shattered_defenses.down&buff.precise_strikes.down
	if not SpellCooldown(colossus_smash) > 0 and BuffExpires(shattered_defenses_buff) and BuffExpires(precise_strikes_buff) Spell(colossus_smash)
	#whirlwind,if=talent.fervor_of_battle.enabled&(debuff.colossus_smash.up|rage.deficit<50)&(!talent.focused_rage.enabled|buff.battle_cry_deadly_calm.up|buff.cleave.up)
	if Talent(fervor_of_battle_talent) and { target.DebuffPresent(colossus_smash_debuff) or RageDeficit() < 50 } and { not Talent(focused_rage_talent) or BuffPresent(battle_cry_deadly_calm_buff) or BuffPresent(cleave_buff) } Spell(whirlwind)
	#rend,if=remains<=duration*0.3
	if target.DebuffRemaining(rend_debuff) <= BaseDuration(rend_debuff) * 0.3 Spell(rend)
	#cleave
	Spell(cleave)
	#execute,if=rage>90
	if Rage() > 90 Spell(execute_arms)
	#whirlwind,if=rage>=40
	if Rage() >= 40 Spell(whirlwind)
}

AddFunction ArmsAoeMainPostConditions
{
}

AddFunction ArmsAoeShortCdActions
{
	unless not SpellCooldown(mortal_strike) > 0 and Spell(mortal_strike) or BuffPresent(stone_heart_buff) and Spell(execute_arms) or not SpellCooldown(colossus_smash) > 0 and BuffExpires(shattered_defenses_buff) and BuffExpires(precise_strikes_buff) and Spell(colossus_smash)
	{
		#warbreaker,if=buff.shattered_defenses.down
		if BuffExpires(shattered_defenses_buff) Spell(warbreaker)

		unless Talent(fervor_of_battle_talent) and { target.DebuffPresent(colossus_smash_debuff) or RageDeficit() < 50 } and { not Talent(focused_rage_talent) or BuffPresent(battle_cry_deadly_calm_buff) or BuffPresent(cleave_buff) } and Spell(whirlwind) or target.DebuffRemaining(rend_debuff) <= BaseDuration(rend_debuff) * 0.3 and Spell(rend)
		{
			#bladestorm
			Spell(bladestorm)

			unless Spell(cleave) or Rage() > 90 and Spell(execute_arms) or Rage() >= 40 and Spell(whirlwind)
			{
				#shockwave
				Spell(shockwave)
				#storm_bolt
				Spell(storm_bolt)
			}
		}
	}
}

AddFunction ArmsAoeShortCdPostConditions
{
	not SpellCooldown(mortal_strike) > 0 and Spell(mortal_strike) or BuffPresent(stone_heart_buff) and Spell(execute_arms) or not SpellCooldown(colossus_smash) > 0 and BuffExpires(shattered_defenses_buff) and BuffExpires(precise_strikes_buff) and Spell(colossus_smash) or Talent(fervor_of_battle_talent) and { target.DebuffPresent(colossus_smash_debuff) or RageDeficit() < 50 } and { not Talent(focused_rage_talent) or BuffPresent(battle_cry_deadly_calm_buff) or BuffPresent(cleave_buff) } and Spell(whirlwind) or target.DebuffRemaining(rend_debuff) <= BaseDuration(rend_debuff) * 0.3 and Spell(rend) or Spell(cleave) or Rage() > 90 and Spell(execute_arms) or Rage() >= 40 and Spell(whirlwind)
}

AddFunction ArmsAoeCdActions
{
}

AddFunction ArmsAoeCdPostConditions
{
	not SpellCooldown(mortal_strike) > 0 and Spell(mortal_strike) or BuffPresent(stone_heart_buff) and Spell(execute_arms) or not SpellCooldown(colossus_smash) > 0 and BuffExpires(shattered_defenses_buff) and BuffExpires(precise_strikes_buff) and Spell(colossus_smash) or BuffExpires(shattered_defenses_buff) and Spell(warbreaker) or Talent(fervor_of_battle_talent) and { target.DebuffPresent(colossus_smash_debuff) or RageDeficit() < 50 } and { not Talent(focused_rage_talent) or BuffPresent(battle_cry_deadly_calm_buff) or BuffPresent(cleave_buff) } and Spell(whirlwind) or target.DebuffRemaining(rend_debuff) <= BaseDuration(rend_debuff) * 0.3 and Spell(rend) or Spell(bladestorm) or Spell(cleave) or Rage() > 90 and Spell(execute_arms) or Rage() >= 40 and Spell(whirlwind) or Spell(shockwave) or Spell(storm_bolt)
}

### actions.cleave

AddFunction ArmsCleaveMainActions
{
	#mortal_strike
	Spell(mortal_strike)
	#execute,if=buff.stone_heart.react
	if BuffPresent(stone_heart_buff) Spell(execute_arms)
	#colossus_smash,if=buff.shattered_defenses.down&buff.precise_strikes.down
	if BuffExpires(shattered_defenses_buff) and BuffExpires(precise_strikes_buff) Spell(colossus_smash)
	#whirlwind,if=talent.fervor_of_battle.enabled&(debuff.colossus_smash.up|rage.deficit<50)&(!talent.focused_rage.enabled|buff.battle_cry_deadly_calm.up|buff.cleave.up)
	if Talent(fervor_of_battle_talent) and { target.DebuffPresent(colossus_smash_debuff) or RageDeficit() < 50 } and { not Talent(focused_rage_talent) or BuffPresent(battle_cry_deadly_calm_buff) or BuffPresent(cleave_buff) } Spell(whirlwind)
	#rend,if=remains<=duration*0.3
	if target.DebuffRemaining(rend_debuff) <= BaseDuration(rend_debuff) * 0.3 Spell(rend)
	#cleave
	Spell(cleave)
	#whirlwind,if=rage>40|buff.cleave.up
	if Rage() > 40 or BuffPresent(cleave_buff) Spell(whirlwind)
}

AddFunction ArmsCleaveMainPostConditions
{
}

AddFunction ArmsCleaveShortCdActions
{
	unless Spell(mortal_strike) or BuffPresent(stone_heart_buff) and Spell(execute_arms) or BuffExpires(shattered_defenses_buff) and BuffExpires(precise_strikes_buff) and Spell(colossus_smash)
	{
		#warbreaker,if=buff.shattered_defenses.down
		if BuffExpires(shattered_defenses_buff) Spell(warbreaker)
		#focused_rage,if=rage>100|buff.battle_cry_deadly_calm.up
		if Rage() > 100 or BuffPresent(battle_cry_deadly_calm_buff) Spell(focused_rage)

		unless Talent(fervor_of_battle_talent) and { target.DebuffPresent(colossus_smash_debuff) or RageDeficit() < 50 } and { not Talent(focused_rage_talent) or BuffPresent(battle_cry_deadly_calm_buff) or BuffPresent(cleave_buff) } and Spell(whirlwind) or target.DebuffRemaining(rend_debuff) <= BaseDuration(rend_debuff) * 0.3 and Spell(rend)
		{
			#bladestorm
			Spell(bladestorm)

			unless Spell(cleave) or { Rage() > 40 or BuffPresent(cleave_buff) } and Spell(whirlwind)
			{
				#shockwave
				Spell(shockwave)
				#storm_bolt
				Spell(storm_bolt)
			}
		}
	}
}

AddFunction ArmsCleaveShortCdPostConditions
{
	Spell(mortal_strike) or BuffPresent(stone_heart_buff) and Spell(execute_arms) or BuffExpires(shattered_defenses_buff) and BuffExpires(precise_strikes_buff) and Spell(colossus_smash) or Talent(fervor_of_battle_talent) and { target.DebuffPresent(colossus_smash_debuff) or RageDeficit() < 50 } and { not Talent(focused_rage_talent) or BuffPresent(battle_cry_deadly_calm_buff) or BuffPresent(cleave_buff) } and Spell(whirlwind) or target.DebuffRemaining(rend_debuff) <= BaseDuration(rend_debuff) * 0.3 and Spell(rend) or Spell(cleave) or { Rage() > 40 or BuffPresent(cleave_buff) } and Spell(whirlwind)
}

AddFunction ArmsCleaveCdActions
{
}

AddFunction ArmsCleaveCdPostConditions
{
	Spell(mortal_strike) or BuffPresent(stone_heart_buff) and Spell(execute_arms) or BuffExpires(shattered_defenses_buff) and BuffExpires(precise_strikes_buff) and Spell(colossus_smash) or BuffExpires(shattered_defenses_buff) and Spell(warbreaker) or Talent(fervor_of_battle_talent) and { target.DebuffPresent(colossus_smash_debuff) or RageDeficit() < 50 } and { not Talent(focused_rage_talent) or BuffPresent(battle_cry_deadly_calm_buff) or BuffPresent(cleave_buff) } and Spell(whirlwind) or target.DebuffRemaining(rend_debuff) <= BaseDuration(rend_debuff) * 0.3 and Spell(rend) or Spell(bladestorm) or Spell(cleave) or { Rage() > 40 or BuffPresent(cleave_buff) } and Spell(whirlwind) or Spell(shockwave) or Spell(storm_bolt)
}

### actions.execute

AddFunction ArmsExecuteMainActions
{
	#mortal_strike,if=cooldown_react&buff.battle_cry.up&buff.focused_rage.stack=3
	if not SpellCooldown(mortal_strike) > 0 and BuffPresent(battle_cry_buff) and BuffStacks(focused_rage_buff) == 3 Spell(mortal_strike)
	#execute,if=buff.battle_cry_deadly_calm.up
	if BuffPresent(battle_cry_deadly_calm_buff) Spell(execute_arms)
	#colossus_smash,if=cooldown_react&buff.shattered_defenses.down
	if not SpellCooldown(colossus_smash) > 0 and BuffExpires(shattered_defenses_buff) Spell(colossus_smash)
	#execute,if=buff.shattered_defenses.up&(rage>=17.6|buff.stone_heart.react)
	if BuffPresent(shattered_defenses_buff) and { Rage() >= 17.6 or BuffPresent(stone_heart_buff) } Spell(execute_arms)
	#mortal_strike,if=cooldown_react&equipped.archavons_heavy_hand&rage<60
	if not SpellCooldown(mortal_strike) > 0 and HasEquippedItem(archavons_heavy_hand) and Rage() < 60 Spell(mortal_strike)
	#execute,if=buff.shattered_defenses.down
	if BuffExpires(shattered_defenses_buff) Spell(execute_arms)
}

AddFunction ArmsExecuteMainPostConditions
{
}

AddFunction ArmsExecuteShortCdActions
{
	unless not SpellCooldown(mortal_strike) > 0 and BuffPresent(battle_cry_buff) and BuffStacks(focused_rage_buff) == 3 and Spell(mortal_strike) or BuffPresent(battle_cry_deadly_calm_buff) and Spell(execute_arms) or not SpellCooldown(colossus_smash) > 0 and BuffExpires(shattered_defenses_buff) and Spell(colossus_smash) or BuffPresent(shattered_defenses_buff) and { Rage() >= 17.6 or BuffPresent(stone_heart_buff) } and Spell(execute_arms) or not SpellCooldown(mortal_strike) > 0 and HasEquippedItem(archavons_heavy_hand) and Rage() < 60 and Spell(mortal_strike) or BuffExpires(shattered_defenses_buff) and Spell(execute_arms)
	{
		#bladestorm,interrupt=1,if=raid_event.adds.in>90|!raid_event.adds.exists|spell_targets.bladestorm_mh>desired_targets
		if 600 > 90 or not False(raid_event_adds_exists) or Enemies(tagged=1) > Enemies(tagged=1) Spell(bladestorm)
	}
}

AddFunction ArmsExecuteShortCdPostConditions
{
	not SpellCooldown(mortal_strike) > 0 and BuffPresent(battle_cry_buff) and BuffStacks(focused_rage_buff) == 3 and Spell(mortal_strike) or BuffPresent(battle_cry_deadly_calm_buff) and Spell(execute_arms) or not SpellCooldown(colossus_smash) > 0 and BuffExpires(shattered_defenses_buff) and Spell(colossus_smash) or BuffPresent(shattered_defenses_buff) and { Rage() >= 17.6 or BuffPresent(stone_heart_buff) } and Spell(execute_arms) or not SpellCooldown(mortal_strike) > 0 and HasEquippedItem(archavons_heavy_hand) and Rage() < 60 and Spell(mortal_strike) or BuffExpires(shattered_defenses_buff) and Spell(execute_arms)
}

AddFunction ArmsExecuteCdActions
{
}

AddFunction ArmsExecuteCdPostConditions
{
	not SpellCooldown(mortal_strike) > 0 and BuffPresent(battle_cry_buff) and BuffStacks(focused_rage_buff) == 3 and Spell(mortal_strike) or BuffPresent(battle_cry_deadly_calm_buff) and Spell(execute_arms) or not SpellCooldown(colossus_smash) > 0 and BuffExpires(shattered_defenses_buff) and Spell(colossus_smash) or BuffPresent(shattered_defenses_buff) and { Rage() >= 17.6 or BuffPresent(stone_heart_buff) } and Spell(execute_arms) or not SpellCooldown(mortal_strike) > 0 and HasEquippedItem(archavons_heavy_hand) and Rage() < 60 and Spell(mortal_strike) or BuffExpires(shattered_defenses_buff) and Spell(execute_arms) or { 600 > 90 or not False(raid_event_adds_exists) or Enemies(tagged=1) > Enemies(tagged=1) } and Spell(bladestorm)
}

### actions.precombat

AddFunction ArmsPrecombatMainActions
{
	#flask,type=countless_armies
	#food,type=fishbrul_special
	#augmentation,type=defiled
	# Spell(augmentation)
}

AddFunction ArmsPrecombatMainPostConditions
{
}

AddFunction ArmsPrecombatShortCdActions
{
}

AddFunction ArmsPrecombatShortCdPostConditions
{
	# Spell(augmentation)
}

AddFunction ArmsPrecombatCdActions
{
}

AddFunction ArmsPrecombatCdPostConditions
{
	# Spell(augmentation)
}

### actions.single

AddFunction ArmsSingleMainActions
{
	#colossus_smash,if=cooldown_react&buff.shattered_defenses.down&(buff.battle_cry.down|buff.battle_cry.up&buff.battle_cry.remains>=gcd)
	if not SpellCooldown(colossus_smash) > 0 and BuffExpires(shattered_defenses_buff) and { BuffExpires(battle_cry_buff) or BuffPresent(battle_cry_buff) and BuffRemaining(battle_cry_buff) >= GCD() } Spell(colossus_smash)
	#mortal_strike,if=cooldown_react&cooldown.battle_cry.remains>8
	if not SpellCooldown(mortal_strike) > 0 and SpellCooldown(battle_cry) > 8 Spell(mortal_strike)
	#execute,if=buff.stone_heart.react
	if BuffPresent(stone_heart_buff) Spell(execute_arms)
	#whirlwind,if=spell_targets.whirlwind>1
	if Enemies(tagged=1) > 1 Spell(whirlwind)
	#slam,if=spell_targets.whirlwind=1
	if Enemies(tagged=1) == 1 Spell(slam)
}

AddFunction ArmsSingleMainPostConditions
{
}

AddFunction ArmsSingleShortCdActions
{
	unless not SpellCooldown(colossus_smash) > 0 and BuffExpires(shattered_defenses_buff) and { BuffExpires(battle_cry_buff) or BuffPresent(battle_cry_buff) and BuffRemaining(battle_cry_buff) >= GCD() } and Spell(colossus_smash)
	{
		#focused_rage,if=!buff.battle_cry_deadly_calm.up&buff.focused_rage.stack<3&!cooldown.colossus_smash.up&(rage>=50|debuff.colossus_smash.down|cooldown.battle_cry.remains<=8)
		if not BuffPresent(battle_cry_deadly_calm_buff) and BuffStacks(focused_rage_buff) < 3 and not { not SpellCooldown(colossus_smash) > 0 } and { Rage() >= 50 or target.DebuffExpires(colossus_smash_debuff) or SpellCooldown(battle_cry) <= 8 } Spell(focused_rage)

		unless not SpellCooldown(mortal_strike) > 0 and SpellCooldown(battle_cry) > 8 and Spell(mortal_strike) or BuffPresent(stone_heart_buff) and Spell(execute_arms) or Enemies(tagged=1) > 1 and Spell(whirlwind) or Enemies(tagged=1) == 1 and Spell(slam)
		{
			#focused_rage,if=equipped.archavons_heavy_hand&buff.focused_rage.stack<3
			if HasEquippedItem(archavons_heavy_hand) and BuffStacks(focused_rage_buff) < 3 Spell(focused_rage)
			#bladestorm,interrupt=1,if=raid_event.adds.in>90|!raid_event.adds.exists|spell_targets.bladestorm_mh>desired_targets
			if 600 > 90 or not False(raid_event_adds_exists) or Enemies(tagged=1) > Enemies(tagged=1) Spell(bladestorm)
		}
	}
}

AddFunction ArmsSingleShortCdPostConditions
{
	not SpellCooldown(colossus_smash) > 0 and BuffExpires(shattered_defenses_buff) and { BuffExpires(battle_cry_buff) or BuffPresent(battle_cry_buff) and BuffRemaining(battle_cry_buff) >= GCD() } and Spell(colossus_smash) or not SpellCooldown(mortal_strike) > 0 and SpellCooldown(battle_cry) > 8 and Spell(mortal_strike) or BuffPresent(stone_heart_buff) and Spell(execute_arms) or Enemies(tagged=1) > 1 and Spell(whirlwind) or Enemies(tagged=1) == 1 and Spell(slam)
}

AddFunction ArmsSingleCdActions
{
}

AddFunction ArmsSingleCdPostConditions
{
	not SpellCooldown(colossus_smash) > 0 and BuffExpires(shattered_defenses_buff) and { BuffExpires(battle_cry_buff) or BuffPresent(battle_cry_buff) and BuffRemaining(battle_cry_buff) >= GCD() } and Spell(colossus_smash) or not SpellCooldown(mortal_strike) > 0 and SpellCooldown(battle_cry) > 8 and Spell(mortal_strike) or BuffPresent(stone_heart_buff) and Spell(execute_arms) or Enemies(tagged=1) > 1 and Spell(whirlwind) or Enemies(tagged=1) == 1 and Spell(slam) or { 600 > 90 or not False(raid_event_adds_exists) or Enemies(tagged=1) > Enemies(tagged=1) } and Spell(bladestorm)
}
]]

	OvaleScripts:RegisterScript("WARRIOR", "arms", name, desc, code, "script")
end
