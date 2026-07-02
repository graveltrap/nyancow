param([string]$ChannelId = "1411861311838490644")
$envPath = Join-Path $PSScriptRoot "..\.env"
$token = $null
foreach ($line in Get-Content $envPath) {
  if ($line -match '^\s*DISCORD_BOT_TOKEN\s*=\s*(.+?)\s*$') { $token = $matches[1] }
}
$headers = @{
  Authorization = "Bot $token"
  "User-Agent"  = "DiscordBot (https://nyancow.gg, 1.0)"
}
$batch = Invoke-RestMethod -Uri "https://discord.com/api/v10/channels/$ChannelId/messages?limit=3" -Headers $headers -Method Get
$batch | ConvertTo-Json -Depth 10
