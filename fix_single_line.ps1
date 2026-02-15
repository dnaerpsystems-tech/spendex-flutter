# Fix single-line if/for statements
Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $original = $content

    # Fix "if (cond) return;"
    $content = $content -replace '(\s+)if\s*\(([^{][^\n]+?)\)\s+return;', '$1if ($2) {$1  return;$1}'

    # Fix "if (cond) continue;"
    $content = $content -replace '(\s+)if\s*\(([^{][^\n]+?)\)\s+continue;', '$1if ($2) {$1  continue;$1}'

    # Fix "if (cond) break;"
    $content = $content -replace '(\s+)if\s*\(([^{][^\n]+?)\)\s+break;', '$1if ($2) {$1  break;$1}'

    if ($content -ne $original) {
        Set-Content -Path $_.FullName -Value $content -NoNewline
        Write-Host "Fixed: $($_.FullName)"
    }
}
