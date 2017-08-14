Function Get-TargetResource  {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Path,
        
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure,
        
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [String]$LinetoWrite,

        [Parameter()]
        [uint32]$index
         
    )

    $contents = Get-Content $Path

    if ($PSBoundParameters.ContainsKey("Index")) {
      $Presence = if ($contents[$index] -eq $linetowrite) {"Present"} else {"Absent"}  
      $output = @{
                    Ensure = $Presence;
                    Path = $Path;
                    String = $linetowrite;
                    Index = $index;
                 }

    } else {
       $Presence = if ($contents -contains $linetowrite) {"Present"} else {"Absent"}
       $output = @{
                    Ensure = $Presence;
                    Path = $Path;
                    String = $linetowrite;
                  }
    }

    return $output
}

Function Test-TargetResource {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Path,
        
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present",
        
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [String]$LinetoWrite,

        [Parameter()]
        [uint32]$index
         
    )

    $contents = Get-Content $Path

    if ($PSBoundParameters.ContainsKey("Index")) {
      $Presence = if ($contents[$index] -eq $linetowrite) {"Present"} else {"Absent"}  

    } else {
       $Presence = if ($contents -contains $linetowrite) {"Present"} else {"Absent"}
        
    }

    return $Presence -eq $Ensure
}

Function Set-TargetResource {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Path,
        
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present",
        
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [String]$LinetoWrite,

        [Parameter()]
        [uint32]$index      
         
    )


    $contents = Get-Content $Path

    switch ($Ensure) {
        "Present" {
            if ($PSBoundParameters.ContainsKey("Index")) {
                $NonFixedContents = New-Object System.Collections.ArrayList
                $contents | ForEach-Object { $NonFixedContents.Add($_) | Out-Null } 
                $NonFixedContents.Insert($index,$linetowrite)
                $NonFixedContents | Out-File $Path -Force                  
            } else {
                $contents+=$linetowrite
                $contents | Out-File $Path -Force      
            }
        } 

        "Absent" {
             if ($PSBoundParameters.ContainsKey("Index")) {
                 $NonFixedContents = New-Object System.Collections.ArrayList
                 $contents | ForEach-Object { $NonFixedContents.Add($_) | Out-Null } 
                 If ($contents[$index] -match $linetowrite) {
                    $NonFixedContents.RemoveAt($index)
                    $NonFixedContents | Out-File $Path -Force
                 } else {
                    throw "Could not find $linetowrite in $file at $index"
                 }
             } else {
                 $NonFixedContents = New-Object System.Collections.ArrayList
                 $contents | ForEach-Object { $NonFixedContents.Add($_) | Out-Null } 
                 $index = $NonFixedContents.IndexOf($linetowrite)
                 if ($index -is [uint32]) {
                    $NonFixedContents.RemoveAt($index)
                    $NonFixedContents | Out-File $Path -Force
                 } else {
                    throw "Could not find $linetowrite in $file"
                 }   
             }               
        }

    }    
}

Export-ModuleMember -Function *-TargetResource