<#
Reads DISCORD_BOT_TOKEN from the sibling .env file and dumps a channel's messages
(content, author, attachment URLs) to fetch-output.json. Never prints the token.
Usage: powershell -File fetch-channel.ps1 -ChannelId 1411861311838490644
#>
param(
  [Parameter(Mandatory=$true)][string]$ChannelId,
  [int]$Limit = 100
)

$envPath = Join-Path $PSScriptRoot "..\.env"
if (-not (Test-Path $envPath)) { throw ".env not found at $envPath" }

$token = $null
foreach ($line in Get-Content $envPath) {
  if ($line -match '^\s*DISCORD_BOT_TOKEN\s*=\s*(.+?)\s*$') { $token = $matches[1] }
}
if (-not $token) { throw "DISCORD_BOT_TOKEN not found in .env" }

$headers = @{ Authorization = "Bot $token" }
$all = @()
$before = $null

do {
  $url = "https://discord.com/api/v10/channels/$ChannelId/messages?limit=100"
  if ($before) { $url += "&before=$before" }
  $batch = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
  if ($batch.Count -eq 0) { break }
  $all += $batch
  $before = $batch[-1].id
} while ($batch.Count -eq 100 -and $all.Count -lt $Limit)

$simplified = $all | ForEach-Object {
  [PSCustomObject]@{
    author      = $_.author.username
    content     = $_.content
    timestamp   = $_.timestamp
    attachments = $_.attachments | ForEach-Object { $_.url }
  }
}

$outPath = Join-Path $PSScriptRoot "fetch-output.json"
$simplified | ConvertTo-Json -Depth 5 | Out-File -FilePath $outPath -Encoding utf8
Write-Output "Wrote $($simplified.Count) messages to $outPath"
