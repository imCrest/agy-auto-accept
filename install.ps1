# agy-auto-accept Windows PowerShell Installer
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Antigravity (agy) Auto-Accept Windows Installer" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$configDir = "$HOME\.gemini\config"
$cliDir = "$HOME\.gemini\antigravity-cli"
$hooksFile = "$configDir\hooks.json"
$settingsFile = "$cliDir\settings.json"

if (!(Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir -Force | Out-Null }
if (!(Test-Path $cliDir)) { New-Item -ItemType Directory -Path $cliDir -Force | Out-Null }

# 1. Setup hooks.json
Write-Host "[1/3] Configuring hooks.json..." -ForegroundColor Yellow
$hooksContent = @'
{
  "auto-approve": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -NoProfile -Command \"Write-Output '{\\\"decision\\\": \\\"allow\\\"}'\""
          }
        ]
      }
    ]
  }
}
'@
Set-Content -Path $hooksFile -Value $hooksContent -Encoding UTF8
Write-Host "  ✔ hooks.json created." -ForegroundColor Green

# 2. Setup settings.json permissions
Write-Host "[2/3] Configuring antigravity-cli/settings.json..." -ForegroundColor Yellow
$settings = @{}
if (Test-Path $settingsFile) {
    try {
        $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json -AsHashtable
    } catch {
        $settings = @{}
    }
}

if (-not $settings.ContainsKey("permissions")) {
    $settings["permissions"] = @{}
}

$currentAllows = @()
if ($settings["permissions"].ContainsKey("allow")) {
    $currentAllows = [System.Collections.ArrayList]@($settings["permissions"]["allow"])
} else {
    $currentAllows = [System.Collections.ArrayList]@()
}

$targets = @("command(*)", "read_file(*)", "write_file(*)", "read_url(*)", "execute_url(*)", "mcp(*)")
foreach ($t in $targets) {
    if (-not $currentAllows.Contains($t)) {
        $currentAllows.Insert(0, $t) | Out-Null
    }
}

$settings["permissions"]["allow"] = $currentAllows
$settings["allowNonWorkspaceAccess"] = $true

$jsonOutput = $settings | ConvertTo-Json -Depth 10
Set-Content -Path $settingsFile -Value $jsonOutput -Encoding UTF8
Write-Host "  ✔ settings.json updated." -ForegroundColor Green

# 3. Setup PowerShell profile alias if possible
Write-Host "[3/3] Checking PowerShell alias..." -ForegroundColor Yellow
try {
    $profileDir = Split-Path -Parent $PROFILE
    if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
    if (!(Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
    $profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    if ($profileContent -notlike "*dangerously-skip-permissions*") {
        Add-Content -Path $PROFILE -Value "`nfunction agy-auto { agy --dangerously-skip-permissions `$args }`nSet-Alias -Name agy -Value agy-auto -Option AllScope -Force -ErrorAction SilentlyContinue"
        Write-Host "  ✔ Alias added to PowerShell profile." -ForegroundColor Green
    } else {
        Write-Host "  ✔ Alias already present in profile." -ForegroundColor Green
    }
} catch {
    Write-Host "  (Profile alias skipped: $($_.Message))" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "✔ Auto-Accept Setup Completed Successfully!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
