$HostFile = $null
$AgentFile = $null
$ExeAgentFile = $null
$LocalAgentPath = $null
$ImportHostnames = $null
$Hostnames = @()
$HostnameCount = $null
$WhileCounter = 0
$Credential = $null


Write-Host ("Enter a CSV file path to add required Hostnames: ") -ForegroundColor Green -NoNewline 
$HostFile = Read-Host

Write-Host ("Enter a Mcafee Agent file path: ") -ForegroundColor Green -NoNewline 
$AgentFile = Read-Host
$ExeAgentFile = Split-Path -Path $AgentFile -Leaf -Resolve
$LocalAgentPath = "c:\Windows\Resources\$ExeAgentFile"

$HostnameCount = (Import-Csv -Path $HostFile | Measure-Object).Count
$ImportHostnames = Import-Csv -Path $HostFile
$ImportHostnames |   
ForEach-Object {
  $Hostnames += $_."Hostname"
}


While ($WhileCounter -lt $HostnameCount){ 
  # Copying a Mcafee Agent file to servers
  $DestinationHost = ("\\" + $Hostnames[$WhileCounter] + "\c$\Windows\Resources\")
  Copy-Item –Path $AgentFile –Destination $DestinationHost
  
  # Executing a Mcafee Agent file to servers
  Invoke-Command -ComputerName $Hostnames[$WhileCounter] -ScriptBlock {Start-Process -Wait -FilePath "$Using:LocalAgentPath" -PassThru}

  # Display a succeeded server
  #Write-Host ("The server name " + $Hostnames[$WhileCounter] + " is completed successfully.") -ForegroundColor Green

  $WhileCounter++
}
