# Export-SourceFiles.ps1
# Recursively dump whitelisted source files with a tree into a single text file.
#
# Usage:
#   .\Export-SourceFiles.ps1 -Path "C:\path\to\project"
#   .\Export-SourceFiles.ps1 -Path ".\src"
#   .\Export-SourceFiles.ps1   # default: current directory
#
# Output:
#   <directory_name>.txt
#   例:
#   myproject.txt

param(
    [Alias("RootPath")]
    [string]$Path = (Get-Location).Path
)

# ============================================================
# Resolve path
# ============================================================
$Path = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path

if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    Write-Error "Path does not exist or is not a directory: $Path"
    exit 1
}

# ============================================================
# Output file name
# dirname.txt
# ============================================================
$DirectoryName = Split-Path $Path -Leaf

if ([string]::IsNullOrWhiteSpace($DirectoryName)) {
    $DirectoryName = "source_dump"
}

$OutFile = "$DirectoryName.txt"
$OutputPath = Join-Path (Get-Location).Path $OutFile

# ============================================================
# Whitelist (file extensions)
# ============================================================
$AllowedExtensions = [System.Collections.Generic.HashSet[string]]@(

    # --- Web frontend ---
    ".html", ".htm",
    ".css", ".scss", ".sass", ".less",
    ".js", ".mjs", ".cjs",
    ".ts", ".tsx", ".jsx",
    ".vue", ".svelte",

    # --- Backend / general scripts ---
    ".py",
    ".rb",
    ".php",
    ".java",
    ".kt", ".kts",
    ".go",
    ".rs",
    ".cs",
    ".cpp", ".cc", ".cxx", ".c", ".h", ".hpp",
    ".swift",
    ".scala",
    ".dart",
    ".ex", ".exs",
    ".erl",
    ".hs",
    ".lua",
    ".r",
    ".pl", ".pm",
    ".sh", ".bash", ".zsh",
    ".ps1", ".psm1", ".psd1",

    # --- Data / config ---
    ".json", ".jsonc",
    ".yaml", ".yml",
    ".toml",
    ".sql",
    ".graphql", ".gql",
    ".xml",
    ".csv",
    ".env",
    ".ini", ".cfg", ".conf",

    # --- Docs / markup ---
    ".md", ".mdx",
    ".tex", ".rst"
)

# ============================================================
# Excluded directory names
# ============================================================
$ExcludedDirs = [System.Collections.Generic.HashSet[string]]@(

    # Git
    ".git",

    # Node.js
    "node_modules",

    # Python
    ".venv", "venv", "__pycache__", ".mypy_cache", ".pytest_cache",

    # Build artifacts
    "dist", "build", "out", ".next", ".nuxt",

    # IDE / OS
    ".idea", ".vscode"
)

# ============================================================
# Build tree
# ============================================================
function Build-Tree {

    param(
        [string]$TargetPath,
        [int]$Depth = 1
    )

    $items = Get-ChildItem -LiteralPath $TargetPath |
        Sort-Object { $_.PSIsContainer -eq $false }, Name

    $items = $items | Where-Object {
        -not ($_.PSIsContainer -and $ExcludedDirs.Contains($_.Name))
    }

    foreach ($item in $items) {

        $indent = ("  " * $Depth)

        if ($item.PSIsContainer) {

            Write-Output "$indent$($item.Name)/"

            Build-Tree `
                -TargetPath $item.FullName `
                -Depth ($Depth + 1)

        }
        else {

            Write-Output "$indent$($item.Name)"

        }
    }
}

# ============================================================
# Collect source files
# ============================================================
function Get-SourceFiles {

    param(
        [string]$TargetPath
    )

    $results = @()

    Get-ChildItem -LiteralPath $TargetPath |
        Sort-Object Name |
        ForEach-Object {

            if ($_.PSIsContainer) {

                if (-not $ExcludedDirs.Contains($_.Name)) {

                    $results += Get-SourceFiles `
                        -TargetPath $_.FullName

                }

            }
            else {

                if ($AllowedExtensions.Contains($_.Extension.ToLower())) {

                    $results += $_

                }

            }

        }

    return $results
}

# ============================================================
# Main
# ============================================================
$lines = [System.Collections.Generic.List[string]]::new()

# ============================================================
# TREE
# ============================================================
$lines.Add("<tree>")
$lines.Add("$DirectoryName/")

Build-Tree -TargetPath $Path | ForEach-Object {
    $lines.Add($_)
}

$lines.Add("</tree>")
$lines.Add("")

# ============================================================
# FILE CONTENTS
# ============================================================
$files = Get-SourceFiles -TargetPath $Path

foreach ($file in $files) {

    $relativePath = $file.FullName.Substring($Path.Length)
    $relativePath = $relativePath.TrimStart('\', '/')
    $relativePath = $relativePath -replace '\\', '/'

    $lines.Add("<file path=`"$relativePath`">")

    try {

        $content = Get-Content `
            -LiteralPath $file.FullName `
            -Raw `
            -Encoding UTF8

        if ($null -eq $content) {
            $content = ""
        }

        $lines.Add($content.TrimEnd())

    }
    catch {

        $lines.Add("(read error: $_)")

    }

    $lines.Add("</file>")
    $lines.Add("")

}

# ============================================================
# Write output
# ============================================================
[System.IO.File]::WriteAllLines(
    $OutputPath,
    $lines,
    [System.Text.UTF8Encoding]::new($false)
)

# ============================================================
# Result
# ============================================================
Write-Host ""
Write-Host "========================================"
Write-Host "Export completed"
Write-Host "Output : $OutputPath"
Write-Host "Files  : $($files.Count)"
Write-Host "========================================"
Write-Host ""