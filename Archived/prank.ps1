<#Prank details;
1. copy files onto server - just run this prank on unlocked computers
2. when someone walks away from unlocked computer, run prank.ps1
3. Changes background color to black
4. Changes background picture to CL warning
5. Minimizes all windows on screen
6. Locks the workstation
#>

###
######Step 1: Change BG color
###
.\changeColor.ps1

###
###### Step 2: Change BG image
###
.\changeBack.ps1

###
###### Step 3: Minimize windows
###
$shell = New-Object -ComObject "Shell.Application"
$shell.minimizeall()

###
###### Step 4: Lock workstation
###

$shell = New-Object -com "Wscript.Shell"
$shell.Run("%windir%\System32\rundll32.exe user32.dll,LockWorkStation")

###
###### Step 5: Pop up window display
.\displayImage.ps1