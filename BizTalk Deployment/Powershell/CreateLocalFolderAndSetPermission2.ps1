param
(
    [string]$folder,
    [string]$username,
    [string]$permissions
)

Write-Host 'Creating folder ' $folder
Write-Host 'Set file permissios for user' $username 'with' $permissions

if (!(Test-Path $folder)) {
    New-Item $folder -type directory }

# Get the folder access rights
$objACL = Get-ACL $folder

# Check to see if we need to modify the folder permissions
$create = $false
$modify = $false
$rule = $objAcl.Access | where { $_.IdentityReference -eq $username }
if (-not $rule) {
    $create = $true
    $modify = $true
    Write-Host $username 'not yet applied on folder'
}
else {
    $currentPermissions = $rule.FileSystemRights.ToString()
    Write-Host 'Current permissions =' $currentPermissions
    foreach ($perm in $permissions.Replace(' ', '').Split(',')) {
        if ($currentPermissions -notmatch $perm ) {
            $modify = $true
            Write-Host ' -- Missing the right:' $perm        
        }
    }
}

if ($modify) {
    # Apply the new folder permissions
    Write-Host (Get-Date -Format o)': Apply the permissions' $permissions 'to' $folder

    $colRights = [System.Security.AccessControl.FileSystemRights]$permissions
    $InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit,ObjectInherit' 
    $PropagationFlag = [System.Security.AccessControl.PropagationFlags]::InheritOnly 
    $objType =[System.Security.AccessControl.AccessControlType]::Allow 
    $objUser = New-Object System.Security.Principal.NTAccount($username) 

    #if (-not $create) {
    #    $PropagationFlag = [System.Security.AccessControl.PropagationFlags]::NoPropagateInherit 
    #}
    #if (($PropagationFlag -band [System.Security.AccessControl.PropagationFlags]::NoPropagateInherit) -eq 1) {
    #    Write-Host 'No need to Propagate change to subfolders and files' 
    #}

    $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
        ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
    $objACL.AddAccessRule($objACE) 
    Set-ACL $folder $objACL
    Write-Host (Get-Date -Format o)': Done'
} 
else {
    Write-Host 'Nothing to change for' $folder
}
