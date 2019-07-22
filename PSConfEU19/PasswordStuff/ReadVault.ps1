<#
.Synopsis
   Read Password Vault
.DESCRIPTION
   Read Windows Password Vault
.EXAMPLE
   Read-PasswordVault
#>
function Read-PasswordVault{
    [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
    (new-object Windows.Security.Credentials.PasswordVault).RetrieveAll()|%{$_.RetrievePassword();$_|select Username,password}
    }
#End

