<#
Reads GITHUB_PAT from the sibling .env and prints the tail of the failed
deploy job's log for a given Actions job ID. Never prints the token.
Usage: powershell -File get-run-log.ps1 -RunId 28735381613
#>
param([Parameter(Mandatory=$true)][string]$RunId)

$envPath = Join-Path $PSScriptRoot "..\.env"
$token = $null
foreach ($line in Get-Content $envPath) {
  if ($line -match '^\s*GITHUB_PAT\s*=\s*(.+?)\s*$') { $token = $matches[1] }
}
if (-not $token) { throw "GITHUB_PAT not found in .env" }

$headers = @{
  Authorization = "Bearer $token"
  "User-Agent"  = "nyancow-log-check"
  Accept        = "application/vnd.github+json"
}

$jobs = Invoke-RestMethod -Uri "https://api.github.com/repos/graveltrap/nyancow/actions/runs/$RunId/jobs" -Headers $headers
$deployJob = $jobs.jobs | Where-Object { $_.name -eq 'deploy' }
if (-not $deployJob) { throw "deploy job not found" }

try {
  $log = Invoke-WebRequest -Uri "https://api.github.com/repos/graveltrap/nyancow/actions/jobs/$($deployJob.id)/logs" -Headers $headers -UseBasicParsing
  $lines = ($log.Content -split "`n")
  $lines | Select-Object -Last 40
} catch {
  Write-Output "Could not fetch logs: $($_.Exception.Message)"
}
