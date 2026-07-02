<#
Reads GITHUB_PAT from the sibling .env, pushes the site repo to
github.com/graveltrap/nyancow using it, then immediately strips the token
back out of the git remote config. Never prints the token or the full
remote URL at any point — any error output is redacted before printing.
#>
$siteRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$envPath = Join-Path $siteRoot ".env"

$pat = $null
foreach ($line in Get-Content $envPath) {
  if ($line -match '^\s*GITHUB_PAT\s*=\s*(\S+)\s*$') { $pat = $matches[1] }
}
if (-not $pat) { throw "GITHUB_PAT not found in .env (check for stray '=' or spaces on that line)" }
if ($pat -notmatch '^(github_pat_|ghp_)') {
  throw "GITHUB_PAT doesn't look like a valid token (should start with github_pat_ or ghp_). Check .env formatting."
}
Write-Output "Token format looks valid (prefix: $($pat.Substring(0,11))...)"

Set-Location $siteRoot

$existing = git remote 2>$null
if ($existing -contains "origin") {
  git remote remove origin
}

git remote add origin "https://$pat@github.com/graveltrap/nyancow.git" 2>$null
git branch -M main 2>$null
$pushOutput = git push -u origin main 2>&1 | Out-String
$pushExit = $LASTEXITCODE

# Immediately strip the token out of the remote URL regardless of push outcome
git remote set-url origin "https://github.com/graveltrap/nyancow.git"

$redacted = $pushOutput -replace [regex]::Escape($pat), '***REDACTED***'

if ($pushExit -ne 0) {
  Write-Output "PUSH FAILED (exit $pushExit). Token stripped from remote config regardless. Details:"
  Write-Output $redacted
} else {
  Write-Output "PUSH SUCCEEDED."
}
