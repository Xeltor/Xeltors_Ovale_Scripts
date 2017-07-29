SetTitleMatchMode, 2

if (%0% < 2)
{
	Exit
}

WinActivate, World of Warcraft
WinWaitActive, World of Warcraft

Sleep, 100
PixelGetColor, HBx, %1%, %2%

clipboard =
clipboard = %HBx%
Sleep, 100