SetTitleMatchMode, 2

WinActivate, World of Warcraft
WinWaitActive, World of Warcraft

Sleep, 100
loop, *.png 
{
	ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *n %A_LoopFileFullPath%
	if (ErrorLevel = 0) {
		clipboard = %FoundX%.%FoundY%
		break
	}
}
Sleep, 1000