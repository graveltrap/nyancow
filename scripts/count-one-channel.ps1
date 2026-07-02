param([Parameter(Mandatory=$true)][string]$ChannelId, [string]$Name = "")
$envPath = Join-Path $PSScriptRoot "..\.env"
$token = $null
foreach ($line in Get-Content $envPath) {
  if ($line -match '^\s*DISCORD_BOT_TOKEN\s*=\s*(.+?)\s*$') { $token = $matches[1] }
}
$headers = @{
  Authorization = "Bot $token"
  "User-Agent"  = "DiscordBot (https://nyancow.gg, 1.0)"
}
$cutoff = (Get-Date).AddDays(-365)
$count = 0
$before = $null
$hitCutoff = $false

do {
  $url = "https://discord.com/api/v10/channels/$ChannelId/messages?limit=100"
  if ($before) { $url += "&before=$before" }
  $batch = $null
  $retries = 0
  while ($retries -lt 5) {
    try {
      $batch = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop
      break
    } catch {
      if ($_.Exception.Response.StatusCode.value__ -eq 429) {
        Write-Output "Rate limited, waiting 5s..."
        Start-Sleep -Seconds 5
        $retries++
      } else {
        throw
      }
    }
  }
  if (-not $batch -or $batch.Count -eq 0) { break }
  foreach ($m in $batch) {
    if ([datetime]$m.timestamp -ge $cutoff) { $count++ } else { $hitCutoff = $true }
  }
  $before = $batch[-1].id
  Start-Sleep -Milliseconds 800
} while ($batch.Count -eq 100 -and -not $hitCutoff)

Write-Output "$Name : $count"
