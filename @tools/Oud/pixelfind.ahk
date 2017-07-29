; Please retrieve bottom coords via AU3_Spy.exe ( x , y in active window )
x := 23
y := 1041

if (%x% = 0 or %y% = 0)
{
	MsgBox Base coordinates not filled in please edit pixelfind and add X and Y coords.
	Exit
}

loop
{
WinWaitActive, World of Warcraft,
	if ( GetKeyState("CapsLock" ,"T") ) {
		PixelGetColor, HBx, %x%, %y% ; Insert In Active Window coords from AU3_Spy.exe
		clipboard =
		clipboard = %HBx%
		Sleep, 100
		SetCapsLockState, Off
		KeyWait, Capslock
		Sleep, 100
		MsgBox, Done. ctrl+v to paste stuff
	}
Sleep, 1000
}