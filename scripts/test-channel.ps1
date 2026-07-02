param([Parameter(Mandatory=$true)][string]$ChannelId)
$envPath = Join-Path $PSScriptRoot "..\.env"
$token = $null
foreach ($line in Get-Content $envPath) {
  if ($line -match '^\s*DISCORD_BOT_TOKEN\s*=\s*(.+?)\s*$') { $token = $matches[1] }
}
$headers = @{ Authorization = "Bot $token" }
try {
  $chan = Invoke-RestMethod -Uri "https://discord.com/api/v10/channels/$ChannelId" -Headers $headers -Method Get
  Write-Output "Channel OK: $($chan.name) (type $($chan.type)) in guild $($chan.guild_id)"
} catch {
  Write-Output "CHANNEL LOOKUP FAILED: $($_.Exception.Message)"
  Write-Output $_.ErrorDetails.Message
}
