#path for current script
Set-Variable ScriptPath -Value $MyInvocation.MyCommand.Path -Option Constant
#invocation path and invoke command
$storage = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
$invoke  = "powershell /nologo /file $($ScriptPath)"
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
