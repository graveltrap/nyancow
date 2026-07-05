<#
Reads GITHUB_PAT from the sibling .env and queries the latest GitHub Pages build
status/error for graveltrap/nyancow. Never prints the token.
#>
$envPath = Join-Path $PSScriptRoot "..\.env"
if (-not (Test-Path $envPath)) { throw ".env not found at $envPath" }

$token = $null
foreach ($line in Get-Content $envPath) {
  if ($line -match '^\s*GITHUB_PAT\s*=\s*(.+?)\s*$') { $token = $matches[1] }
}
if (-not $token) { throw "GITHUB_PAT not found in .env" }

$headers = @{
  Authorization  = "Bearer $token"
  "User-Agent"   = "nyancow-pages-check"
  Accept         = "application/vnd.github+json"
}

$build = Invoke-RestMethod -Uri "https://api.github.com/repos/graveltrap/nyancow/pages/builds/latest" -Headers $headers
[PSCustomObject]@{
  status     = $build.status
  error      = $build.error.message
  commit     = $build.commit
  created_at = $build.created_at
} | Format-List
