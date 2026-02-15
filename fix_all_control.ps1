# Fix ALL single-line control body statements
$files = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
$fixCount = 0

foreach ($file in $files) {
    $lines = Get-Content $file.FullName
    $newLines = @()
    $modified = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        # Match: if (condition) statement; (not starting with {)
        if ($line -match '^(\s+)if\s*\(([^)]+(?:\([^)]*\))*[^)]*)\)\s+([^{][^;]+;)\s*$') {
            $indent = $matches[1]
            $condition = $matches[2]
            $statement = $matches[3]

            $newLines += "$indent" + "if ($condition) {"
            $newLines += "$indent  $statement"
            $newLines += "$indent}"
            $modified = $true
        }
        # Match: for (init; cond; inc) statement;
        elseif ($line -match '^(\s+)for\s*\(([^)]+(?:\([^)]*\))*[^)]*)\)\s+([^{][^;]+;)\s*$') {
            $indent = $matches[1]
            $forLoop = $matches[2]
            $statement = $matches[3]

            $newLines += "$indent" + "for ($forLoop) {"
            $newLines += "$indent  $statement"
            $newLines += "$indent}"
            $modified = $true
        }
        else {
            $newLines += $line
        }
    }

    if ($modified) {
        $newLines | Set-Content $file.FullName
        Write-Host "Fixed: $($file.FullName)"
        $fixCount++
    }
}

Write-Host "`nTotal files fixed: $fixCount"
