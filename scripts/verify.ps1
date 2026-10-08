param(
    [ValidateSet('Fast', 'Full')]
    [string]$Mode = 'Full'
)

$ErrorActionPreference = 'Stop'
$Root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$RequiredDocs = @('AGENTS.md', 'CURRENT.md', 'ARCHITECTURE.md', 'CODEMAP.md',
    'TESTING.md', 'OPERATIONS.md', 'README.md', 'decisions/README.md', 'sessions/README.md',
    'docs/07-TESTING-AND-ISSUES.md', 'docs/08-MAC-VALIDATION.md', 'docs/09-DEVELOPMENT-STATUS.md')
$Failures = [Collections.Generic.List[string]]::new()

function Get-MarkdownFiles([string]$Directory) {
    foreach ($Item in Get-ChildItem -LiteralPath $Directory -Force) {
        if ($Item.PSIsContainer) {
            if ($Item.Name -notin @('.git', '.build', '.swiftpm', '.dependency-review', 'node_modules', '.venv', 'vendor', 'dist', 'build', '__pycache__')) {
                Get-MarkdownFiles $Item.FullName
            }
        } elseif ($Item.Extension -eq '.md') {
            $Item
        }
    }
}

try {
    $GitRoot = & git -C $Root rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0 -or [IO.Path]::GetFullPath($GitRoot) -ne $Root) {
        $Failures.Add('Git root does not match project root.')
    }
    foreach ($Relative in $RequiredDocs) {
        $Path = Join-Path $Root $Relative
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
            $Failures.Add("Missing document: $Relative")
        } elseif ($Relative -notmatch '/') {
            if (@(Get-Content -LiteralPath $Path -Encoding UTF8).Count -gt 120) {
                $Failures.Add("Root document exceeds 120 lines: $Relative")
            }
        }
    }
    if ($Mode -eq 'Full') {
        Push-Location $Root
        try {
            & python scripts/generate_project.py --check
            if ($LASTEXITCODE -ne 0) { $Failures.Add('Project generation check failed.') }
            & python -m unittest discover -s Tests/Static -v
            if ($LASTEXITCODE -ne 0) { $Failures.Add('Repository static/SQLite tests failed.') }
        } finally { Pop-Location }
        foreach ($File in Get-MarkdownFiles $Root) {
            $Lines = @(Get-Content -LiteralPath $File.FullName -Encoding UTF8)
            if ($File.Name -eq 'AGENTS.md' -and $Lines.Count -gt 120) {
                $Failures.Add("AGENTS exceeds 120 lines: $($File.FullName)")
            }
            if ($File.DirectoryName -eq (Join-Path $Root 'sessions') -and $Lines.Count -gt 80) {
                $Failures.Add("Session exceeds 80 lines: $($File.FullName)")
            }
            # Ignore fenced examples; inspect inline Markdown links and images.
            $Fence = $null
            foreach ($Line in $Lines) {
                if ($Line -match '^\s*(`{3,}|~{3,})') {
                    $Marker = $Matches[1].Substring(0, 1)
                    if ($null -eq $Fence) { $Fence = $Marker }
                    elseif ($Fence -eq $Marker) { $Fence = $null }
                    continue
                }
                if ($null -ne $Fence) { continue }
                foreach ($Match in [regex]::Matches($Line, '\[[^\]]*\]\(([^\s)]+)\)')) {
                    $Target = $Match.Groups[1].Value.Trim('<', '>')
                    if ($Target -match '^(#|[a-zA-Z][a-zA-Z0-9+.-]*:|//)') { continue }
                    $Target = [Uri]::UnescapeDataString(($Target -split '#', 2)[0])
                    if (-not (Test-Path -LiteralPath (Join-Path $File.DirectoryName $Target))) {
                        $Failures.Add("Broken link in $($File.FullName): $Target")
                    }
                }
            }
        }
    }
} catch {
    $Failures.Add($_.Exception.Message)
}

if ($Failures.Count -gt 0) {
    $Failures | ForEach-Object { Write-Output "FAIL: $_" }
    exit 1
}
Write-Output "PASS: $Mode repository verification (Swift/iOS execution not included)."
exit 0
