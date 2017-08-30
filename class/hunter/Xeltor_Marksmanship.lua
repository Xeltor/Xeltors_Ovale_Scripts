local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_marksmanship"
	local desc = "[Xel][7.1] Hunter: Marksmanship"
	local code = [[
# Based on SimulationCraft profile "Hunter_MM_T18M".
#	class=hunter
#	spec=marksmanship
#	talents=1103021

Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_hunter_spells)

Define(counter_shot 147362)

# Marksman
AddIcon specialization=2 help=main
{
	if InCombat() and HasFullControl() and target.Present() and target.InRange(arcane_shot)
	{
		# Silence
		if InCombat() InterruptActions()
		
		# Cooldowns
		if Boss()
		{
			MarksmanshipDefaultCdActions()
		}
		
		# Short Cooldowns
		MarksmanshipDefaultShortCdActions()
		
		# Rotation
		MarksmanshipDefaultMainActions()
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
		if target.InRange(counter_shot) Spell(counter_shot)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_focus)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

AddFunction use_multishot
{
	{ BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Enemies(tagged=1) > 1 or BuffExpires(marking_targets_buff) and BuffExpires(trueshot_buff) and Enemies(tagged=1) > 2
}

AddFunction safe_to_build
{
	target.DebuffExpires(hunters_mark_debuff) or BuffExpires(trueshot_buff) and BuffExpires(marking_targets_buff)
}

### actions.default

AddFunction MarksmanshipDefaultMainActions
{
	#volley,toggle=on
	# if CheckBoxOn(opt_volley) Spell(volley)
	#auto_shot
	#variable,name=safe_to_build,value=debuff.hunters_mark.down|(buff.trueshot.down&buff.marking_targets.down)
	#variable,name=use_multishot,value=((buff.marking_targets.up|buff.trueshot.up)&spell_targets.multishot>1)|(buff.marking_targets.down&buff.trueshot.down&spell_targets.multishot>2)
	#call_action_list,name=open,if=active_enemies=1&time<=15
	if Enemies(tagged=1) == 1 and TimeInCombat() <= 15 MarksmanshipOpenMainActions()

	unless Enemies(tagged=1) == 1 and TimeInCombat() <= 15 and MarksmanshipOpenMainPostConditions()
	{
		#call_action_list,name=cooldowns
		MarksmanshipCooldownsMainActions()

		unless MarksmanshipCooldownsMainPostConditions()
		{
			#call_action_list,name=trueshotaoe,if=(target.time_to_die>=cooldown.trueshot.remains+cooldown.trueshot.duration|target.health.pct<20)&(debuff.hunters_mark.down|(debuff.hunters_mark.remains>cooldown.trueshot.execute_time&debuff.vulnerability.remains>cooldown.trueshot.execute_time&focus+(focus.regen*debuff.vulnerability.remains)>=60&focus+(focus.regen*debuff.hunters_mark.remains)>=60))
			if { target.TimeToDie() >= SpellCooldown(trueshot) + SpellCooldownDuration(trueshot) or target.HealthPercent() < 20 } and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(trueshot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(trueshot) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 60 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 60 } MarksmanshipTrueshotaoeMainActions()

			unless { target.TimeToDie() >= SpellCooldown(trueshot) + SpellCooldownDuration(trueshot) or target.HealthPercent() < 20 } and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(trueshot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(trueshot) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 60 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 60 } and MarksmanshipTrueshotaoeMainPostConditions()
			{
				#black_arrow,if=debuff.hunters_mark.down|(debuff.hunters_mark.remains>execute_time&debuff.vulnerability.remains>execute_time&focus+(focus.regen*debuff.vulnerability.remains)>=70&focus+(focus.regen*debuff.hunters_mark.remains)>=70)
				if target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(black_arrow) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(black_arrow) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 70 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 70 Spell(black_arrow)
				#call_action_list,name=targetdie,if=target.time_to_die<6&active_enemies=1
				if target.TimeToDie() < 6 and Enemies(tagged=1) == 1 MarksmanshipTargetdieMainActions()

				unless target.TimeToDie() < 6 and Enemies(tagged=1) == 1 and MarksmanshipTargetdieMainPostConditions()
				{
					#call_action_list,name=patient_sniper,if=talent.patient_sniper.enabled
					if Talent(patient_sniper_talent) MarksmanshipPatientSniperMainActions()

					unless Talent(patient_sniper_talent) and MarksmanshipPatientSniperMainPostConditions()
					{
						#call_action_list,name=non_patient_sniper,if=!talent.patient_sniper.enabled
						if not Talent(patient_sniper_talent) MarksmanshipNonPatientSniperMainActions()
					}
				}
			}
		}
	}
}

AddFunction MarksmanshipDefaultMainPostConditions
{
	Enemies(tagged=1) == 1 and TimeInCombat() <= 15 and MarksmanshipOpenMainPostConditions() or MarksmanshipCooldownsMainPostConditions() or { target.TimeToDie() >= SpellCooldown(trueshot) + SpellCooldownDuration(trueshot) or target.HealthPercent() < 20 } and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(trueshot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(trueshot) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 60 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 60 } and MarksmanshipTrueshotaoeMainPostConditions() or target.TimeToDie() < 6 and Enemies(tagged=1) == 1 and MarksmanshipTargetdieMainPostConditions() or Talent(patient_sniper_talent) and MarksmanshipPatientSniperMainPostConditions() or not Talent(patient_sniper_talent) and MarksmanshipNonPatientSniperMainPostConditions()
}

AddFunction MarksmanshipDefaultShortCdActions
{
	unless Spell(volley)
	{
		#auto_shot
		#variable,name=safe_to_build,value=debuff.hunters_mark.down|(buff.trueshot.down&buff.marking_targets.down)
		#variable,name=use_multishot,value=((buff.marking_targets.up|buff.trueshot.up)&spell_targets.multishot>1)|(buff.marking_targets.down&buff.trueshot.down&spell_targets.multishot>2)
		#call_action_list,name=open,if=active_enemies=1&time<=15
		if Enemies(tagged=1) == 1 and TimeInCombat() <= 15 MarksmanshipOpenShortCdActions()

		unless Enemies(tagged=1) == 1 and TimeInCombat() <= 15 and MarksmanshipOpenShortCdPostConditions()
		{
			#a_murder_of_crows,if=(target.time_to_die>=cooldown+duration|target.health.pct<20)&(debuff.hunters_mark.down|(debuff.hunters_mark.remains>execute_time&debuff.vulnerability.remains>execute_time&focus+(focus.regen*debuff.vulnerability.remains)>=60&focus+(focus.regen*debuff.hunters_mark.remains)>=60))
			if { target.TimeToDie() >= SpellCooldown(a_murder_of_crows) + BaseDuration(a_murder_of_crows_debuff) or target.HealthPercent() < 20 } and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(a_murder_of_crows) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(a_murder_of_crows) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 60 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 60 } Spell(a_murder_of_crows)
			#call_action_list,name=cooldowns
			MarksmanshipCooldownsShortCdActions()

			unless MarksmanshipCooldownsShortCdPostConditions()
			{
				#call_action_list,name=trueshotaoe,if=(target.time_to_die>=cooldown.trueshot.remains+cooldown.trueshot.duration|target.health.pct<20)&(debuff.hunters_mark.down|(debuff.hunters_mark.remains>cooldown.trueshot.execute_time&debuff.vulnerability.remains>cooldown.trueshot.execute_time&focus+(focus.regen*debuff.vulnerability.remains)>=60&focus+(focus.regen*debuff.hunters_mark.remains)>=60))
				if { target.TimeToDie() >= SpellCooldown(trueshot) + SpellCooldownDuration(trueshot) or target.HealthPercent() < 20 } and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(trueshot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(trueshot) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 60 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 60 } MarksmanshipTrueshotaoeShortCdActions()

				unless { target.TimeToDie() >= SpellCooldown(trueshot) + SpellCooldownDuration(trueshot) or target.HealthPercent() < 20 } and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(trueshot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(trueshot) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 60 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 60 } and MarksmanshipTrueshotaoeShortCdPostConditions() or { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(black_arrow) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(black_arrow) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 70 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 70 } and Spell(black_arrow)
				{
					#barrage,if=(target.time_to_20pct>10|target.health.pct<=20|spell_targets>1)&((buff.trueshot.down|(target.health.pct<=20&buff.bullseye.stack<29)|spell_targets>1)&debuff.hunters_mark.down|(debuff.hunters_mark.remains>execute_time&debuff.vulnerability.remains>execute_time&focus+(focus.regen*debuff.vulnerability.remains)>=90&focus+(focus.regen*debuff.hunters_mark.remains)>=90))
					if { target.TimeToHealthPercent(20) > 10 or target.HealthPercent() <= 20 or Enemies(tagged=1) > 1 } and { { BuffExpires(trueshot_buff) or target.HealthPercent() <= 20 and BuffStacks(bullseye_buff) < 29 or Enemies(tagged=1) > 1 } and target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(barrage) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(barrage) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 90 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 90 } Spell(barrage)
					#call_action_list,name=targetdie,if=target.time_to_die<6&active_enemies=1
					if target.TimeToDie() < 6 and Enemies(tagged=1) == 1 MarksmanshipTargetdieShortCdActions()

					unless target.TimeToDie() < 6 and Enemies(tagged=1) == 1 and MarksmanshipTargetdieShortCdPostConditions()
					{
						#call_action_list,name=patient_sniper,if=talent.patient_sniper.enabled
						if Talent(patient_sniper_talent) MarksmanshipPatientSniperShortCdActions()

						unless Talent(patient_sniper_talent) and MarksmanshipPatientSniperShortCdPostConditions()
						{
							#call_action_list,name=non_patient_sniper,if=!talent.patient_sniper.enabled
							if not Talent(patient_sniper_talent) MarksmanshipNonPatientSniperShortCdActions()
						}
					}
				}
			}
		}
	}
}

AddFunction MarksmanshipDefaultShortCdPostConditions
{
	Spell(volley) or Enemies(tagged=1) == 1 and TimeInCombat() <= 15 and MarksmanshipOpenShortCdPostConditions() or MarksmanshipCooldownsShortCdPostConditions() or { target.TimeToDie() >= SpellCooldown(trueshot) + SpellCooldownDuration(trueshot) or target.HealthPercent() < 20 } and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(trueshot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(trueshot) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 60 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 60 } and MarksmanshipTrueshotaoeShortCdPostConditions() or { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(black_arrow) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(black_arrow) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 70 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 70 } and Spell(black_arrow) or target.TimeToDie() < 6 and Enemies(tagged=1) == 1 and MarksmanshipTargetdieShortCdPostConditions() or Talent(patient_sniper_talent) and MarksmanshipPatientSniperShortCdPostConditions() or not Talent(patient_sniper_talent) and MarksmanshipNonPatientSniperShortCdPostConditions()
}

AddFunction MarksmanshipDefaultCdActions
{
	#auto_shot
	#arcane_torrent,if=focus.deficit>=30&(!talent.sidewinders.enabled|cooldown.sidewinders.charges<2)
	if FocusDeficit() >= 30 and { not Talent(sidewinders_talent) or SpellChargeCooldown(sidewinders) < 2 } Spell(arcane_torrent_focus)
	#counter_shot
	# MarksmanshipInterruptActions()
	#blood_fury
	Spell(blood_fury_ap)
	#berserking
	Spell(berserking)

	unless Spell(volley)
	{
		#auto_shot
		#variable,name=safe_to_build,value=debuff.hunters_mark.down|(buff.trueshot.down&buff.marking_targets.down)
		#variable,name=use_multishot,value=((buff.marking_targets.up|buff.trueshot.up)&spell_targets.multishot>1)|(buff.marking_targets.down&buff.trueshot.down&spell_targets.multishot>2)
		#call_action_list,name=open,if=active_enemies=1&time<=15
		if Enemies(tagged=1) == 1 and TimeInCombat() <= 15 MarksmanshipOpenCdActions()

		unless Enemies(tagged=1) == 1 and TimeInCombat() <= 15 and MarksmanshipOpenCdPostConditions() or { target.TimeToDie() >= SpellCooldown(a_murder_of_crows) + BaseDuration(a_murder_of_crows_debuff) or target.HealthPercent() < 20 } and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(a_murder_of_crows) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(a_murder_of_crows) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 60 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 60 } and Spell(a_murder_of_crows)
		{
			#call_action_list,name=cooldowns
			MarksmanshipCooldownsCdActions()

			unless MarksmanshipCooldownsCdPostConditions()
			{
				#call_action_list,name=trueshotaoe,if=(target.time_to_die>=cooldown.trueshot.remains+cooldown.trueshot.duration|target.health.pct<20)&(debuff.hunters_mark.down|(debuff.hunters_mark.remains>cooldown.trueshot.execute_time&debuff.vulnerability.remains>cooldown.trueshot.execute_time&focus+(focus.regen*debuff.vulnerability.remains)>=60&focus+(focus.regen*debuff.hunters_mark.remains)>=60))
				if { target.TimeToDie() >= SpellCooldown(trueshot) + SpellCooldownDuration(trueshot) or target.HealthPercent() < 20 } and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(trueshot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(trueshot) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 60 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 60 } MarksmanshipTrueshotaoeCdActions()

				unless { target.TimeToDie() >= SpellCooldown(trueshot) + SpellCooldownDuration(trueshot) or target.HealthPercent() < 20 } and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(trueshot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(trueshot) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 60 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 60 } and MarksmanshipTrueshotaoeCdPostConditions() or { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(black_arrow) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(black_arrow) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 70 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 70 } and Spell(black_arrow) or { target.TimeToHealthPercent(20) > 10 or target.HealthPercent() <= 20 or Enemies(tagged=1) > 1 } and { { BuffExpires(trueshot_buff) or target.HealthPercent() <= 20 and BuffStacks(bullseye_buff) < 29 or Enemies(tagged=1) > 1 } and target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(barrage) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(barrage) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 90 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 90 } and Spell(barrage)
				{
					#call_action_list,name=targetdie,if=target.time_to_die<6&active_enemies=1
					if target.TimeToDie() < 6 and Enemies(tagged=1) == 1 MarksmanshipTargetdieCdActions()

					unless target.TimeToDie() < 6 and Enemies(tagged=1) == 1 and MarksmanshipTargetdieCdPostConditions()
					{
						#call_action_list,name=patient_sniper,if=talent.patient_sniper.enabled
						if Talent(patient_sniper_talent) MarksmanshipPatientSniperCdActions()

						unless Talent(patient_sniper_talent) and MarksmanshipPatientSniperCdPostConditions()
						{
							#call_action_list,name=non_patient_sniper,if=!talent.patient_sniper.enabled
							if not Talent(patient_sniper_talent) MarksmanshipNonPatientSniperCdActions()
						}
					}
				}
			}
		}
	}
}

AddFunction MarksmanshipDefaultCdPostConditions
{
	Spell(volley) or Enemies(tagged=1) == 1 and TimeInCombat() <= 15 and MarksmanshipOpenCdPostConditions() or { target.TimeToDie() >= SpellCooldown(a_murder_of_crows) + BaseDuration(a_murder_of_crows_debuff) or target.HealthPercent() < 20 } and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(a_murder_of_crows) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(a_murder_of_crows) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 60 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 60 } and Spell(a_murder_of_crows) or MarksmanshipCooldownsCdPostConditions() or { target.TimeToDie() >= SpellCooldown(trueshot) + SpellCooldownDuration(trueshot) or target.HealthPercent() < 20 } and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(trueshot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(trueshot) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 60 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 60 } and MarksmanshipTrueshotaoeCdPostConditions() or { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(black_arrow) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(black_arrow) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 70 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 70 } and Spell(black_arrow) or { target.TimeToHealthPercent(20) > 10 or target.HealthPercent() <= 20 or Enemies(tagged=1) > 1 } and { { BuffExpires(trueshot_buff) or target.HealthPercent() <= 20 and BuffStacks(bullseye_buff) < 29 or Enemies(tagged=1) > 1 } and target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(barrage) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(barrage) and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 90 and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 90 } and Spell(barrage) or target.TimeToDie() < 6 and Enemies(tagged=1) == 1 and MarksmanshipTargetdieCdPostConditions() or Talent(patient_sniper_talent) and MarksmanshipPatientSniperCdPostConditions() or not Talent(patient_sniper_talent) and MarksmanshipNonPatientSniperCdPostConditions()
}

### actions.cooldowns

AddFunction MarksmanshipCooldownsMainActions
{
}

AddFunction MarksmanshipCooldownsMainPostConditions
{
}

AddFunction MarksmanshipCooldownsShortCdActions
{
}

AddFunction MarksmanshipCooldownsShortCdPostConditions
{
}

AddFunction MarksmanshipCooldownsCdActions
{
	#potion,name=prolonged_power,if=spell_targets.multishot>2&((buff.trueshot.react&buff.bloodlust.react)|buff.bullseye.react>=23|target.time_to_die<62)
	#potion,name=deadly_grace,if=(buff.trueshot.react&buff.bloodlust.react)|buff.bullseye.react>=23|target.time_to_die<31
	#trueshot,if=time<5|buff.bloodlust.react|target.time_to_die>=(cooldown+duration)|buff.bullseye.react>25|target.time_to_die<16
	if TimeInCombat() < 5 or BuffPresent(burst_haste_buff any=1) or target.TimeToDie() >= SpellCooldown(trueshot) + BaseDuration(trueshot_buff) or BuffStacks(bullseye_buff) > 25 or target.TimeToDie() < 16 Spell(trueshot)
}

AddFunction MarksmanshipCooldownsCdPostConditions
{
}

### actions.non_patient_sniper

AddFunction MarksmanshipNonPatientSniperMainActions
{
	#windburst
	Spell(windburst)
	#sidewinders,if=debuff.vulnerability.remains<gcd&time>6
	if target.DebuffRemaining(vulnerability_debuff) < GCD() and TimeInCombat() > 6 Spell(sidewinders)
	#aimed_shot,if=buff.lock_and_load.up&spell_targets.barrage<3
	if BuffPresent(lock_and_load_buff) and Enemies(tagged=1) < 3 Spell(aimed_shot)
	#marked_shot
	Spell(marked_shot)
	#sidewinders,if=((buff.marking_targets.up|buff.trueshot.up)&focus.deficit>70)|charges_fractional>=1.9
	if { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and FocusDeficit() > 70 or Charges(sidewinders count=0) >= 1.9 Spell(sidewinders)
	#arcane_shot,if=!variable.use_multishot&(buff.marking_targets.up|(talent.steady_focus.enabled&(buff.steady_focus.down|buff.steady_focus.remains<2)))
	if not use_multishot() and { BuffPresent(marking_targets_buff) or Talent(steady_focus_talent) and { BuffExpires(steady_focus_buff) or BuffRemaining(steady_focus_buff) < 2 } } Spell(arcane_shot)
	#multishot,if=variable.use_multishot&(buff.marking_targets.up|(talent.steady_focus.enabled&(buff.steady_focus.down|buff.steady_focus.remains<2)))
	if use_multishot() and { BuffPresent(marking_targets_buff) or Talent(steady_focus_talent) and { BuffExpires(steady_focus_buff) or BuffRemaining(steady_focus_buff) < 2 } } Spell(multishot)
	#aimed_shot,if=!talent.piercing_shot.enabled|cooldown.piercing_shot.remains>3
	if not Talent(piercing_shot_talent) or SpellCooldown(piercing_shot) > 3 Spell(aimed_shot)
	#arcane_shot,if=!variable.use_multishot
	if not use_multishot() Spell(arcane_shot)
	#multishot,if=variable.use_multishot
	if use_multishot() Spell(multishot)
}

AddFunction MarksmanshipNonPatientSniperMainPostConditions
{
}

AddFunction MarksmanshipNonPatientSniperShortCdActions
{
	unless Spell(windburst)
	{
		#piercing_shot,if=focus>=100
		if Focus() >= 100 Spell(piercing_shot)
		#sentinel,if=debuff.hunters_mark.down&focus>30&buff.trueshot.down
		if target.DebuffExpires(hunters_mark_debuff) and Focus() > 30 and BuffExpires(trueshot_buff) Spell(sentinel)

		unless target.DebuffRemaining(vulnerability_debuff) < GCD() and TimeInCombat() > 6 and Spell(sidewinders) or BuffPresent(lock_and_load_buff) and Enemies(tagged=1) < 3 and Spell(aimed_shot) or Spell(marked_shot)
		{
			#explosive_shot
			Spell(explosive_shot)
		}
	}
}

AddFunction MarksmanshipNonPatientSniperShortCdPostConditions
{
	Spell(windburst) or target.DebuffRemaining(vulnerability_debuff) < GCD() and TimeInCombat() > 6 and Spell(sidewinders) or BuffPresent(lock_and_load_buff) and Enemies(tagged=1) < 3 and Spell(aimed_shot) or Spell(marked_shot) or { { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and FocusDeficit() > 70 or Charges(sidewinders count=0) >= 1.9 } and Spell(sidewinders) or not use_multishot() and { BuffPresent(marking_targets_buff) or Talent(steady_focus_talent) and { BuffExpires(steady_focus_buff) or BuffRemaining(steady_focus_buff) < 2 } } and Spell(arcane_shot) or use_multishot() and { BuffPresent(marking_targets_buff) or Talent(steady_focus_talent) and { BuffExpires(steady_focus_buff) or BuffRemaining(steady_focus_buff) < 2 } } and Spell(multishot) or { not Talent(piercing_shot_talent) or SpellCooldown(piercing_shot) > 3 } and Spell(aimed_shot) or not use_multishot() and Spell(arcane_shot) or use_multishot() and Spell(multishot)
}

AddFunction MarksmanshipNonPatientSniperCdActions
{
}

AddFunction MarksmanshipNonPatientSniperCdPostConditions
{
	Spell(windburst) or Focus() >= 100 and Spell(piercing_shot) or target.DebuffExpires(hunters_mark_debuff) and Focus() > 30 and BuffExpires(trueshot_buff) and Spell(sentinel) or target.DebuffRemaining(vulnerability_debuff) < GCD() and TimeInCombat() > 6 and Spell(sidewinders) or BuffPresent(lock_and_load_buff) and Enemies(tagged=1) < 3 and Spell(aimed_shot) or Spell(marked_shot) or Spell(explosive_shot) or { { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and FocusDeficit() > 70 or Charges(sidewinders count=0) >= 1.9 } and Spell(sidewinders) or not use_multishot() and { BuffPresent(marking_targets_buff) or Talent(steady_focus_talent) and { BuffExpires(steady_focus_buff) or BuffRemaining(steady_focus_buff) < 2 } } and Spell(arcane_shot) or use_multishot() and { BuffPresent(marking_targets_buff) or Talent(steady_focus_talent) and { BuffExpires(steady_focus_buff) or BuffRemaining(steady_focus_buff) < 2 } } and Spell(multishot) or { not Talent(piercing_shot_talent) or SpellCooldown(piercing_shot) > 3 } and Spell(aimed_shot) or not use_multishot() and Spell(arcane_shot) or use_multishot() and Spell(multishot)
}

### actions.open

AddFunction MarksmanshipOpenMainActions
{
	#arcane_shot,line_cd=16&!talent.patient_sniper.enabled
	if TimeSincePreviousSpell(arcane_shot) > 16 and not Talent(patient_sniper_talent) Spell(arcane_shot)
	#sidewinders,if=(buff.marking_targets.down&buff.trueshot.remains<2)|(charges_fractional>=1.9&focus<80)
	if BuffExpires(marking_targets_buff) and BuffRemaining(trueshot_buff) < 2 or Charges(sidewinders count=0) >= 1.9 and Focus() < 80 Spell(sidewinders)
	#marked_shot
	Spell(marked_shot)
	#aimed_shot,if=(buff.lock_and_load.up&execute_time<debuff.vulnerability.remains)|focus>90&!talent.patient_sniper.enabled&talent.trick_shot.enabled
	if BuffPresent(lock_and_load_buff) and ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) or Focus() > 90 and not Talent(patient_sniper_talent) and Talent(trick_shot_talent) Spell(aimed_shot)
	#aimed_shot,if=buff.lock_and_load.up&execute_time<debuff.vulnerability.remains
	if BuffPresent(lock_and_load_buff) and ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) Spell(aimed_shot)
	#black_arrow
	Spell(black_arrow)
	#arcane_shot
	Spell(arcane_shot)
	#aimed_shot,if=execute_time<debuff.vulnerability.remains
	if ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) Spell(aimed_shot)
	#sidewinders
	Spell(sidewinders)
	#aimed_shot
	Spell(aimed_shot)
}

AddFunction MarksmanshipOpenMainPostConditions
{
}

AddFunction MarksmanshipOpenShortCdActions
{
	#a_murder_of_crows
	Spell(a_murder_of_crows)
	#piercing_shot
	Spell(piercing_shot)
	#explosive_shot
	Spell(explosive_shot)
	#barrage,if=!talent.patient_sniper.enabled
	if not Talent(patient_sniper_talent) Spell(barrage)

	unless TimeSincePreviousSpell(arcane_shot) > 16 and not Talent(patient_sniper_talent) and Spell(arcane_shot) or { BuffExpires(marking_targets_buff) and BuffRemaining(trueshot_buff) < 2 or Charges(sidewinders count=0) >= 1.9 and Focus() < 80 } and Spell(sidewinders) or Spell(marked_shot)
	{
		#barrage,if=buff.bloodlust.up
		if BuffPresent(burst_haste_buff any=1) Spell(barrage)

		unless { BuffPresent(lock_and_load_buff) and ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) or Focus() > 90 and not Talent(patient_sniper_talent) and Talent(trick_shot_talent) } and Spell(aimed_shot) or BuffPresent(lock_and_load_buff) and ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) and Spell(aimed_shot) or Spell(black_arrow)
		{
			#barrage
			Spell(barrage)
		}
	}
}

AddFunction MarksmanshipOpenShortCdPostConditions
{
	TimeSincePreviousSpell(arcane_shot) > 16 and not Talent(patient_sniper_talent) and Spell(arcane_shot) or { BuffExpires(marking_targets_buff) and BuffRemaining(trueshot_buff) < 2 or Charges(sidewinders count=0) >= 1.9 and Focus() < 80 } and Spell(sidewinders) or Spell(marked_shot) or { BuffPresent(lock_and_load_buff) and ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) or Focus() > 90 and not Talent(patient_sniper_talent) and Talent(trick_shot_talent) } and Spell(aimed_shot) or BuffPresent(lock_and_load_buff) and ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) and Spell(aimed_shot) or Spell(black_arrow) or Spell(arcane_shot) or ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) and Spell(aimed_shot) or Spell(sidewinders) or Spell(aimed_shot)
}

AddFunction MarksmanshipOpenCdActions
{
	unless Spell(a_murder_of_crows)
	{
		#trueshot
		Spell(trueshot)
	}
}

AddFunction MarksmanshipOpenCdPostConditions
{
	Spell(a_murder_of_crows) or Spell(piercing_shot) or Spell(explosive_shot) or not Talent(patient_sniper_talent) and Spell(barrage) or TimeSincePreviousSpell(arcane_shot) > 16 and not Talent(patient_sniper_talent) and Spell(arcane_shot) or { BuffExpires(marking_targets_buff) and BuffRemaining(trueshot_buff) < 2 or Charges(sidewinders count=0) >= 1.9 and Focus() < 80 } and Spell(sidewinders) or Spell(marked_shot) or BuffPresent(burst_haste_buff any=1) and Spell(barrage) or { BuffPresent(lock_and_load_buff) and ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) or Focus() > 90 and not Talent(patient_sniper_talent) and Talent(trick_shot_talent) } and Spell(aimed_shot) or BuffPresent(lock_and_load_buff) and ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) and Spell(aimed_shot) or Spell(black_arrow) or Spell(barrage) or Spell(arcane_shot) or ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) and Spell(aimed_shot) or Spell(sidewinders) or Spell(aimed_shot)
}

### actions.patient_sniper

AddFunction MarksmanshipPatientSniperMainActions
{
	#marked_shot,cycle_targets=1,if=(talent.sidewinders.enabled&talent.barrage.enabled&spell_targets>2)|debuff.hunters_mark.remains<2|((debuff.vulnerability.up|talent.sidewinders.enabled)&debuff.vulnerability.remains<gcd)
	if Talent(sidewinders_talent) and Talent(barrage_talent) and Enemies(tagged=1) > 2 or target.DebuffRemaining(hunters_mark_debuff) < 2 or { target.DebuffPresent(vulnerability_debuff) or Talent(sidewinders_talent) } and target.DebuffRemaining(vulnerability_debuff) < GCD() Spell(marked_shot)
	#windburst,if=talent.sidewinders.enabled&(debuff.hunters_mark.down|(debuff.hunters_mark.remains>execute_time&focus+(focus.regen*debuff.hunters_mark.remains)>=50))|buff.trueshot.up
	if Talent(sidewinders_talent) and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(windburst) and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 50 } or BuffPresent(trueshot_buff) Spell(windburst)
	#sidewinders,if=buff.trueshot.up&((buff.marking_targets.down&buff.trueshot.remains<2)|(charges_fractional>=1.9&(focus.deficit>70|spell_targets>1)))
	if BuffPresent(trueshot_buff) and { BuffExpires(marking_targets_buff) and BuffRemaining(trueshot_buff) < 2 or Charges(sidewinders count=0) >= 1.9 and { FocusDeficit() > 70 or Enemies(tagged=1) > 1 } } Spell(sidewinders)
	#multishot,if=buff.marking_targets.up&debuff.hunters_mark.down&variable.use_multishot&focus.deficit>2*spell_targets+gcd*focus.regen
	if BuffPresent(marking_targets_buff) and target.DebuffExpires(hunters_mark_debuff) and use_multishot() and FocusDeficit() > 2 * Enemies(tagged=1) + GCD() * FocusRegenRate() Spell(multishot)
	#aimed_shot,if=buff.lock_and_load.up&buff.trueshot.up&debuff.vulnerability.remains>execute_time
	if BuffPresent(lock_and_load_buff) and BuffPresent(trueshot_buff) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) Spell(aimed_shot)
	#marked_shot,if=buff.trueshot.up&!talent.sidewinders.enabled
	if BuffPresent(trueshot_buff) and not Talent(sidewinders_talent) Spell(marked_shot)
	#arcane_shot,if=buff.trueshot.up
	if BuffPresent(trueshot_buff) Spell(arcane_shot)
	#aimed_shot,if=debuff.hunters_mark.down&debuff.vulnerability.remains>execute_time
	if target.DebuffExpires(hunters_mark_debuff) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) Spell(aimed_shot)
	#aimed_shot,if=talent.sidewinders.enabled&debuff.hunters_mark.remains>execute_time&debuff.vulnerability.remains>execute_time&(buff.lock_and_load.up|(focus+debuff.hunters_mark.remains*focus.regen>=80&focus+focus.regen*debuff.vulnerability.remains>=80))&(!talent.piercing_shot.enabled|cooldown.piercing_shot.remains>5|focus>120)
	if Talent(sidewinders_talent) and target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(aimed_shot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { BuffPresent(lock_and_load_buff) or Focus() + target.DebuffRemaining(hunters_mark_debuff) * FocusRegenRate() >= 80 and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 80 } and { not Talent(piercing_shot_talent) or SpellCooldown(piercing_shot) > 5 or Focus() > 120 } Spell(aimed_shot)
	#aimed_shot,if=!talent.sidewinders.enabled&debuff.hunters_mark.remains>execute_time&debuff.vulnerability.remains>execute_time&(buff.lock_and_load.up|(buff.trueshot.up&focus>=80)|(buff.trueshot.down&focus+debuff.hunters_mark.remains*focus.regen>=80&focus+focus.regen*debuff.vulnerability.remains>=80))&(!talent.piercing_shot.enabled|cooldown.piercing_shot.remains>5|focus>120)
	if not Talent(sidewinders_talent) and target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(aimed_shot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { BuffPresent(lock_and_load_buff) or BuffPresent(trueshot_buff) and Focus() >= 80 or BuffExpires(trueshot_buff) and Focus() + target.DebuffRemaining(hunters_mark_debuff) * FocusRegenRate() >= 80 and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 80 } and { not Talent(piercing_shot_talent) or SpellCooldown(piercing_shot) > 5 or Focus() > 120 } Spell(aimed_shot)
	#windburst,if=!talent.sidewinders.enabled&focus>80&(debuff.hunters_mark.down|(debuff.hunters_mark.remains>execute_time&focus+(focus.regen*debuff.hunters_mark.remains)>=50))
	if not Talent(sidewinders_talent) and Focus() > 80 and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(windburst) and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 50 } Spell(windburst)
	#marked_shot,if=(talent.sidewinders.enabled&spell_targets>1)|focus.deficit<50|buff.trueshot.up|(buff.marking_targets.up&(!talent.sidewinders.enabled|cooldown.sidewinders.charges_fractional>=1.2))
	if Talent(sidewinders_talent) and Enemies(tagged=1) > 1 or FocusDeficit() < 50 or BuffPresent(trueshot_buff) or BuffPresent(marking_targets_buff) and { not Talent(sidewinders_talent) or SpellCharges(sidewinders) >= 1.2 } Spell(marked_shot)
	#sidewinders,if=variable.safe_to_build&((buff.trueshot.up&focus.deficit>70)|charges_fractional>=1.9)
	if safe_to_build() and { BuffPresent(trueshot_buff) and FocusDeficit() > 70 or Charges(sidewinders count=0) >= 1.9 } Spell(sidewinders)
	#sidewinders,if=(buff.marking_targets.up&debuff.hunters_mark.down&buff.trueshot.down)|(cooldown.sidewinders.charges_fractional>1&target.time_to_die<11)
	if BuffPresent(marking_targets_buff) and target.DebuffExpires(hunters_mark_debuff) and BuffExpires(trueshot_buff) or SpellCharges(sidewinders) > 1 and target.TimeToDie() < 11 Spell(sidewinders)
	#arcane_shot,if=variable.safe_to_build&!variable.use_multishot&focus.deficit>5+gcd*focus.regen
	if safe_to_build() and not use_multishot() and FocusDeficit() > 5 + GCD() * FocusRegenRate() Spell(arcane_shot)
	#multishot,if=variable.safe_to_build&variable.use_multishot&focus.deficit>2*spell_targets+gcd*focus.regen
	if safe_to_build() and use_multishot() and FocusDeficit() > 2 * Enemies(tagged=1) + GCD() * FocusRegenRate() Spell(multishot)
	#aimed_shot,if=debuff.vulnerability.down&focus>80&cooldown.windburst.remains>focus.time_to_max
	if target.DebuffExpires(vulnerability_debuff) and Focus() > 80 and SpellCooldown(windburst) > TimeToMaxFocus() Spell(aimed_shot)
}

AddFunction MarksmanshipPatientSniperMainPostConditions
{
}

AddFunction MarksmanshipPatientSniperShortCdActions
{
	unless { Talent(sidewinders_talent) and Talent(barrage_talent) and Enemies(tagged=1) > 2 or target.DebuffRemaining(hunters_mark_debuff) < 2 or { target.DebuffPresent(vulnerability_debuff) or Talent(sidewinders_talent) } and target.DebuffRemaining(vulnerability_debuff) < GCD() } and Spell(marked_shot) or { Talent(sidewinders_talent) and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(windburst) and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 50 } or BuffPresent(trueshot_buff) } and Spell(windburst) or BuffPresent(trueshot_buff) and { BuffExpires(marking_targets_buff) and BuffRemaining(trueshot_buff) < 2 or Charges(sidewinders count=0) >= 1.9 and { FocusDeficit() > 70 or Enemies(tagged=1) > 1 } } and Spell(sidewinders) or BuffPresent(marking_targets_buff) and target.DebuffExpires(hunters_mark_debuff) and use_multishot() and FocusDeficit() > 2 * Enemies(tagged=1) + GCD() * FocusRegenRate() and Spell(multishot) or BuffPresent(lock_and_load_buff) and BuffPresent(trueshot_buff) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and Spell(aimed_shot) or BuffPresent(trueshot_buff) and not Talent(sidewinders_talent) and Spell(marked_shot) or BuffPresent(trueshot_buff) and Spell(arcane_shot) or target.DebuffExpires(hunters_mark_debuff) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and Spell(aimed_shot) or Talent(sidewinders_talent) and target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(aimed_shot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { BuffPresent(lock_and_load_buff) or Focus() + target.DebuffRemaining(hunters_mark_debuff) * FocusRegenRate() >= 80 and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 80 } and { not Talent(piercing_shot_talent) or SpellCooldown(piercing_shot) > 5 or Focus() > 120 } and Spell(aimed_shot) or not Talent(sidewinders_talent) and target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(aimed_shot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { BuffPresent(lock_and_load_buff) or BuffPresent(trueshot_buff) and Focus() >= 80 or BuffExpires(trueshot_buff) and Focus() + target.DebuffRemaining(hunters_mark_debuff) * FocusRegenRate() >= 80 and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 80 } and { not Talent(piercing_shot_talent) or SpellCooldown(piercing_shot) > 5 or Focus() > 120 } and Spell(aimed_shot) or not Talent(sidewinders_talent) and Focus() > 80 and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(windburst) and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 50 } and Spell(windburst) or { Talent(sidewinders_talent) and Enemies(tagged=1) > 1 or FocusDeficit() < 50 or BuffPresent(trueshot_buff) or BuffPresent(marking_targets_buff) and { not Talent(sidewinders_talent) or SpellCharges(sidewinders) >= 1.2 } } and Spell(marked_shot)
	{
		#piercing_shot,if=focus>80
		if Focus() > 80 Spell(piercing_shot)
	}
}

AddFunction MarksmanshipPatientSniperShortCdPostConditions
{
	{ Talent(sidewinders_talent) and Talent(barrage_talent) and Enemies(tagged=1) > 2 or target.DebuffRemaining(hunters_mark_debuff) < 2 or { target.DebuffPresent(vulnerability_debuff) or Talent(sidewinders_talent) } and target.DebuffRemaining(vulnerability_debuff) < GCD() } and Spell(marked_shot) or { Talent(sidewinders_talent) and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(windburst) and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 50 } or BuffPresent(trueshot_buff) } and Spell(windburst) or BuffPresent(trueshot_buff) and { BuffExpires(marking_targets_buff) and BuffRemaining(trueshot_buff) < 2 or Charges(sidewinders count=0) >= 1.9 and { FocusDeficit() > 70 or Enemies(tagged=1) > 1 } } and Spell(sidewinders) or BuffPresent(marking_targets_buff) and target.DebuffExpires(hunters_mark_debuff) and use_multishot() and FocusDeficit() > 2 * Enemies(tagged=1) + GCD() * FocusRegenRate() and Spell(multishot) or BuffPresent(lock_and_load_buff) and BuffPresent(trueshot_buff) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and Spell(aimed_shot) or BuffPresent(trueshot_buff) and not Talent(sidewinders_talent) and Spell(marked_shot) or BuffPresent(trueshot_buff) and Spell(arcane_shot) or target.DebuffExpires(hunters_mark_debuff) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and Spell(aimed_shot) or Talent(sidewinders_talent) and target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(aimed_shot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { BuffPresent(lock_and_load_buff) or Focus() + target.DebuffRemaining(hunters_mark_debuff) * FocusRegenRate() >= 80 and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 80 } and { not Talent(piercing_shot_talent) or SpellCooldown(piercing_shot) > 5 or Focus() > 120 } and Spell(aimed_shot) or not Talent(sidewinders_talent) and target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(aimed_shot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { BuffPresent(lock_and_load_buff) or BuffPresent(trueshot_buff) and Focus() >= 80 or BuffExpires(trueshot_buff) and Focus() + target.DebuffRemaining(hunters_mark_debuff) * FocusRegenRate() >= 80 and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 80 } and { not Talent(piercing_shot_talent) or SpellCooldown(piercing_shot) > 5 or Focus() > 120 } and Spell(aimed_shot) or not Talent(sidewinders_talent) and Focus() > 80 and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(windburst) and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 50 } and Spell(windburst) or { Talent(sidewinders_talent) and Enemies(tagged=1) > 1 or FocusDeficit() < 50 or BuffPresent(trueshot_buff) or BuffPresent(marking_targets_buff) and { not Talent(sidewinders_talent) or SpellCharges(sidewinders) >= 1.2 } } and Spell(marked_shot) or safe_to_build() and { BuffPresent(trueshot_buff) and FocusDeficit() > 70 or Charges(sidewinders count=0) >= 1.9 } and Spell(sidewinders) or { BuffPresent(marking_targets_buff) and target.DebuffExpires(hunters_mark_debuff) and BuffExpires(trueshot_buff) or SpellCharges(sidewinders) > 1 and target.TimeToDie() < 11 } and Spell(sidewinders) or safe_to_build() and not use_multishot() and FocusDeficit() > 5 + GCD() * FocusRegenRate() and Spell(arcane_shot) or safe_to_build() and use_multishot() and FocusDeficit() > 2 * Enemies(tagged=1) + GCD() * FocusRegenRate() and Spell(multishot) or target.DebuffExpires(vulnerability_debuff) and Focus() > 80 and SpellCooldown(windburst) > TimeToMaxFocus() and Spell(aimed_shot)
}

AddFunction MarksmanshipPatientSniperCdActions
{
}

AddFunction MarksmanshipPatientSniperCdPostConditions
{
	{ Talent(sidewinders_talent) and Talent(barrage_talent) and Enemies(tagged=1) > 2 or target.DebuffRemaining(hunters_mark_debuff) < 2 or { target.DebuffPresent(vulnerability_debuff) or Talent(sidewinders_talent) } and target.DebuffRemaining(vulnerability_debuff) < GCD() } and Spell(marked_shot) or { Talent(sidewinders_talent) and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(windburst) and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 50 } or BuffPresent(trueshot_buff) } and Spell(windburst) or BuffPresent(trueshot_buff) and { BuffExpires(marking_targets_buff) and BuffRemaining(trueshot_buff) < 2 or Charges(sidewinders count=0) >= 1.9 and { FocusDeficit() > 70 or Enemies(tagged=1) > 1 } } and Spell(sidewinders) or BuffPresent(marking_targets_buff) and target.DebuffExpires(hunters_mark_debuff) and use_multishot() and FocusDeficit() > 2 * Enemies(tagged=1) + GCD() * FocusRegenRate() and Spell(multishot) or BuffPresent(lock_and_load_buff) and BuffPresent(trueshot_buff) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and Spell(aimed_shot) or BuffPresent(trueshot_buff) and not Talent(sidewinders_talent) and Spell(marked_shot) or BuffPresent(trueshot_buff) and Spell(arcane_shot) or target.DebuffExpires(hunters_mark_debuff) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and Spell(aimed_shot) or Talent(sidewinders_talent) and target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(aimed_shot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { BuffPresent(lock_and_load_buff) or Focus() + target.DebuffRemaining(hunters_mark_debuff) * FocusRegenRate() >= 80 and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 80 } and { not Talent(piercing_shot_talent) or SpellCooldown(piercing_shot) > 5 or Focus() > 120 } and Spell(aimed_shot) or not Talent(sidewinders_talent) and target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(aimed_shot) and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { BuffPresent(lock_and_load_buff) or BuffPresent(trueshot_buff) and Focus() >= 80 or BuffExpires(trueshot_buff) and Focus() + target.DebuffRemaining(hunters_mark_debuff) * FocusRegenRate() >= 80 and Focus() + FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) >= 80 } and { not Talent(piercing_shot_talent) or SpellCooldown(piercing_shot) > 5 or Focus() > 120 } and Spell(aimed_shot) or not Talent(sidewinders_talent) and Focus() > 80 and { target.DebuffExpires(hunters_mark_debuff) or target.DebuffRemaining(hunters_mark_debuff) > ExecuteTime(windburst) and Focus() + FocusRegenRate() * target.DebuffRemaining(hunters_mark_debuff) >= 50 } and Spell(windburst) or { Talent(sidewinders_talent) and Enemies(tagged=1) > 1 or FocusDeficit() < 50 or BuffPresent(trueshot_buff) or BuffPresent(marking_targets_buff) and { not Talent(sidewinders_talent) or SpellCharges(sidewinders) >= 1.2 } } and Spell(marked_shot) or Focus() > 80 and Spell(piercing_shot) or safe_to_build() and { BuffPresent(trueshot_buff) and FocusDeficit() > 70 or Charges(sidewinders count=0) >= 1.9 } and Spell(sidewinders) or { BuffPresent(marking_targets_buff) and target.DebuffExpires(hunters_mark_debuff) and BuffExpires(trueshot_buff) or SpellCharges(sidewinders) > 1 and target.TimeToDie() < 11 } and Spell(sidewinders) or safe_to_build() and not use_multishot() and FocusDeficit() > 5 + GCD() * FocusRegenRate() and Spell(arcane_shot) or safe_to_build() and use_multishot() and FocusDeficit() > 2 * Enemies(tagged=1) + GCD() * FocusRegenRate() and Spell(multishot) or target.DebuffExpires(vulnerability_debuff) and Focus() > 80 and SpellCooldown(windburst) > TimeToMaxFocus() and Spell(aimed_shot)
}

### actions.precombat

AddFunction MarksmanshipPrecombatMainActions
{
	#snapshot_stats
	#potion,name=prolonged_power,if=active_enemies>2
	#potion,name=deadly_grace
	#augmentation,type=defiled
	# Spell(augmentation)
	#windburst
	# Spell(windburst)
}

AddFunction MarksmanshipPrecombatMainPostConditions
{
}

AddFunction MarksmanshipPrecombatShortCdActions
{
	#flask,type=flask_of_the_seventh_demon
	#food,type=nightborne_delicacy_platter
	#summon_pet
	# MarksmanshipSummonPet()
}

AddFunction MarksmanshipPrecombatShortCdPostConditions
{
	Spell(windburst)
}

AddFunction MarksmanshipPrecombatCdActions
{
}

AddFunction MarksmanshipPrecombatCdPostConditions
{
	Spell(windburst)
}

### actions.targetdie

AddFunction MarksmanshipTargetdieMainActions
{
	#marked_shot
	Spell(marked_shot)
	#windburst
	Spell(windburst)
	#aimed_shot,if=debuff.vulnerability.remains>execute_time&target.time_to_die>execute_time
	if target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and target.TimeToDie() > ExecuteTime(aimed_shot) Spell(aimed_shot)
	#sidewinders
	Spell(sidewinders)
	#aimed_shot
	Spell(aimed_shot)
	#arcane_shot
	Spell(arcane_shot)
}

AddFunction MarksmanshipTargetdieMainPostConditions
{
}

AddFunction MarksmanshipTargetdieShortCdActions
{
}

AddFunction MarksmanshipTargetdieShortCdPostConditions
{
	Spell(marked_shot) or Spell(windburst) or target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and target.TimeToDie() > ExecuteTime(aimed_shot) and Spell(aimed_shot) or Spell(sidewinders) or Spell(aimed_shot) or Spell(arcane_shot)
}

AddFunction MarksmanshipTargetdieCdActions
{
}

AddFunction MarksmanshipTargetdieCdPostConditions
{
	Spell(marked_shot) or Spell(windburst) or target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and target.TimeToDie() > ExecuteTime(aimed_shot) and Spell(aimed_shot) or Spell(sidewinders) or Spell(aimed_shot) or Spell(arcane_shot)
}

### actions.trueshotaoe

AddFunction MarksmanshipTrueshotaoeMainActions
{
	#marked_shot
	Spell(marked_shot)
	#aimed_shot,if=(!talent.patient_sniper.enabled|talent.trick_shot.enabled)&spell_targets.multishot=2&buff.lock_and_load.up&execute_time<debuff.vulnerability.remains
	if { not Talent(patient_sniper_talent) or Talent(trick_shot_talent) } and Enemies(tagged=1) == 2 and BuffPresent(lock_and_load_buff) and ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) Spell(aimed_shot)
	#multishot
	Spell(multishot)
}

AddFunction MarksmanshipTrueshotaoeMainPostConditions
{
}

AddFunction MarksmanshipTrueshotaoeShortCdActions
{
	unless Spell(marked_shot)
	{
		#barrage,if=!talent.patient_sniper.enabled
		if not Talent(patient_sniper_talent) Spell(barrage)
		#piercing_shot
		Spell(piercing_shot)
		#explosive_shot
		Spell(explosive_shot)
	}
}

AddFunction MarksmanshipTrueshotaoeShortCdPostConditions
{
	Spell(marked_shot) or { not Talent(patient_sniper_talent) or Talent(trick_shot_talent) } and Enemies(tagged=1) == 2 and BuffPresent(lock_and_load_buff) and ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) and Spell(aimed_shot) or Spell(multishot)
}

AddFunction MarksmanshipTrueshotaoeCdActions
{
}

AddFunction MarksmanshipTrueshotaoeCdPostConditions
{
	Spell(marked_shot) or not Talent(patient_sniper_talent) and Spell(barrage) or Spell(piercing_shot) or Spell(explosive_shot) or { not Talent(patient_sniper_talent) or Talent(trick_shot_talent) } and Enemies(tagged=1) == 2 and BuffPresent(lock_and_load_buff) and ExecuteTime(aimed_shot) < target.DebuffRemaining(vulnerability_debuff) and Spell(aimed_shot) or Spell(multishot)
}
]]

	OvaleScripts:RegisterScript("HUNTER", "marksmanship", name, desc, code, "script")
end
