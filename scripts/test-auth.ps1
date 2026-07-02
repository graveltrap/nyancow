$envPath = Join-Path $PSScriptRoot "..\.env"
$token = $null
foreach ($line in Get-Content $envPath) {
  if ($line -match '^\s*DISCORD_BOT_TOKEN\s*=\s*(.+?)\s*$') { $token = $matches[1] }
}
$headers = @{ Authorization = "Bot $token" }
try {
  $me = Invoke-RestMethod -Uri "https://discord.com/api/v10/users/@me" -Headers $headers -Method Get
  Write-Output "Bot identity OK: $($me.username)"
} catch {
  Write-Output "AUTH FAILED: $($_.Exception.Message)"
  Write-Output $_.ErrorDetails.Message
}
