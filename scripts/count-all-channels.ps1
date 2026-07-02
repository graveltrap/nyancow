<#
Counts messages posted in the last 365 days across every channel in the guild.
Never prints the token.
#>
$envPath = Join-Path $PSScriptRoot "..\.env"
$token = $null
foreach ($line in Get-Content $envPath) {
  if ($line -match '^\s*DISCORD_BOT_TOKEN\s*=\s*(.+?)\s*$') { $token = $matches[1] }
}
$headers = @{
  Authorization = "Bot $token"
  "User-Agent"  = "DiscordBot (https://nyancow.gg, 1.0)"
}
$guildId = "347763631351660544"
$cutoff = (Get-Date).AddDays(-365)

$channels = Invoke-RestMethod -Uri "https://discord.com/api/v10/guilds/$guildId/channels" -Headers $headers -Method Get
$textChannels = $channels | Where-Object { $_.type -ne 4 }

$results = @()

foreach ($ch in $textChannels) {
  $count = 0
  $before = $null
  $hitCutoff = $false
  $errored = $false
  $errorMsg = ""

  do {
    $url = "https://discord.com/api/v10/channels/$($ch.id)/messages?limit=100"
    if ($before) { $url += "&before=$before" }
    try {
      $batch = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop
    } catch {
      $errored = $true
      $errorMsg = $_.Exception.Message
      break
    }
    if ($batch.Count -eq 0) { break }
    foreach ($m in $batch) {
      if ([datetime]$m.timestamp -ge $cutoff) { $count++ } else { $hitCutoff = $true }
    }
    $before = $batch[-1].id
    Start-Sleep -Milliseconds 300
  } while ($batch.Count -eq 100 -and -not $hitCutoff)

  $results += [PSCustomObject]@{
    name  = $ch.name
    id    = $ch.id
    type  = $ch.type
    count = $count
    note  = if ($errored) { "ERROR: $errorMsg" } else { "" }
  }
  Write-Output "$($ch.name): $count"
}

$results | ConvertTo-Json -Depth 5 | Out-File (Join-Path $PSScriptRoot "channel-counts.json") -Encoding utf8
Write-Output "--- DONE ---"
