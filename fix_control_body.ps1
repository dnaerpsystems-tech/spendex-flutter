# PowerShell script to fix control body formatting issues
# Converts single-line if/for statements to multi-line format

$files = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    $modified = $false

    # Pattern 1: if (condition) statement;
    $pattern1 = '(\s+)if\s*\(([^)]+)\)\s+([^{][^;]+;)'
    if ($content -match $pattern1) {
        $content = $content -replace $pattern1, '$1if ($2) {$1  $3$1}'
        $modified = $true
    }

    # Pattern 2: for (init; cond; inc) statement;
    $pattern2 = '(\s+)for\s*\(([^)]+)\)\s+([^{][^;]+;)'
    if ($content -match $pattern2) {
        $content = $content -replace $pattern2, '$1for ($2) {$1  $3$1}'
        $modified = $true
    }

    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Fixed: $($file.FullName)"
    }
}

Write-Host "Done!"
