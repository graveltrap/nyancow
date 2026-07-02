$envPath = Join-Path $PSScriptRoot "..\.env"
$token = $null
foreach ($line in Get-Content $envPath) {
  if ($line -match '^\s*DISCORD_BOT_TOKEN\s*=\s*(.+?)\s*$') { $token = $matches[1] }
}
$headers = @{
  Authorization = "Bot $token"
  "User-Agent"  = "DiscordBot (https://nyancow.gg, 1.0)"
}

$targets = @(
  @{channel="1411861311838490644"; snippet="just submitted the full run"; label="leaderboard-107"},
  @{channel="1411861311838490644"; snippet="missed the leaderboard by 3 seconds"; label="missed-by-3-seconds"},
  @{channel="1411861311838490644"; snippet="i CANNOT believe i forgot about this mount"; label="forgotten-mount"},
  @{channel="1149803350481698846"; snippet="The New Halfway Mark"; label="paragon-300-math"}
)

foreach ($t in $targets) {
  $before = $null
  $found = $null
  for ($i = 0; $i -lt 10 -and -not $found; $i++) {
    $url = "https://discord.com/api/v10/channels/$($t.channel)/messages?limit=100"
    if ($before) { $url += "&before=$before" }
    $batch = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
    if ($batch.Count -eq 0) { break }
    $found = $batch | Where-Object { $_.content -like "*$($t.snippet)*" } | Select-Object -First 1
    $before = $batch[-1].id
    Start-Sleep -Milliseconds 300
  }
  if ($found) {
    Write-Output "$($t.label): channel=$($t.channel) message=$($found.id)"
  } else {
    Write-Output "$($t.label): NOT FOUND"
  }
}
