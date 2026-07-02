$envPath = Join-Path $PSScriptRoot "..\.env"
$token = $null
foreach ($line in Get-Content $envPath) {
  if ($line -match '^\s*DISCORD_BOT_TOKEN\s*=\s*(.+?)\s*$') { $token = $matches[1] }
}
$headers = @{ Authorization = "Bot $token" }
$guildId = "347763631351660544"
try {
  $channels = Invoke-RestMethod -Uri "https://discord.com/api/v10/guilds/$guildId/channels" -Headers $headers -Method Get
  $channels | Select-Object id, name, type | Format-Table -AutoSize | Out-String -Width 200
} catch {
  Write-Output "FAILED: $($_.Exception.Message)"
  Write-Output $_.ErrorDetails.Message
}
