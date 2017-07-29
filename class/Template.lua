Include(ovale_common)
Include(ovale_interrupt)

AddIcon specialization=1 help=main
{
	if target.InRange(frost_strike) and HasFullControl()
	{
		# Interrupt
		if InCombat() and target.Casting(interrupt_list) InterruptActions()
		
		# Cooldowns
		if target.Classification(worldboss) or BuffPresent(burst_haste_buff any=1)
		{
			
		}
		
		# Short Cooldowns
		
		
		# Default Actions
		
		
		# Multi Target
		if CheckBoxOn(aoe)
		{
			# Cooldowns
			if target.Classification(worldboss) or BuffPresent(burst_haste_buff any=1)
			{
				
			}
			
			# Short Cooldowns
			
			
			# Rotation
			
		}
		
		# Single Target
		if CheckBoxOff(aoe)
		{
			# Cooldowns
			if target.Classification(worldboss) or BuffPresent(burst_haste_buff any=1)
			{
				
			}
			
			# Short Cooldowns
			
			
			# Rotation
			
		}
	}
}