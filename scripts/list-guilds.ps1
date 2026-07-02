$envPath = Join-Path $PSScriptRoot "..\.env"
$token = $null
foreach ($line in Get-Content $envPath) {
  if ($line -match '^\s*DISCORD_BOT_TOKEN\s*=\s*(.+?)\s*$') { $token = $matches[1] }
}
$headers = @{ Authorization = "Bot $token" }
try {
  $guilds = Invoke-RestMethod -Uri "https://discord.com/api/v10/users/@me/guilds" -Headers $headers -Method Get
  $guilds | Select-Object id, name | Format-Table -AutoSize | Out-String -Width 200
} catch {
  Write-Output "FAILED: $($_.Exception.Message)"
  Write-Output $_.ErrorDetails.Message
}
