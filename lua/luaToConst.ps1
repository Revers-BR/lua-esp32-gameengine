param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("header","luac")]
    [string]$m,

    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$InputFiles
)

function Show-Usage {
    Write-Host "Usage: .\script.ps1 -m <mode> <input_lua_file(s)>"
    Write-Host "  -m <mode>    Mode: header or luac"
    Write-Host "Example: .\script.ps1 -m header .\bouncingBall.lua"
    Write-Host "Example: .\script.ps1 -m header .\file1.lua .\file2.lua"
    Write-Host "Example: .\script.ps1 -m luac .\bouncingBall.lua"
    Write-Host "Note: If you are using mode=luac, make sure luac32.exe is in the same directory as this script."
    exit 1
}

if (-not $m -or -not $InputFiles) {
    Show-Usage
}

$ExeDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($m -eq "header") {

    $OutputFile = Join-Path $ExeDir "..\include\luaScript.h"
    $OutputFile = [System.IO.Path]::GetFullPath($OutputFile)

    $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($OutputFile, "", $Utf8NoBom)
    "#ifndef LUASCRIPT_H" | Out-File $OutputFile -Append
    "#define LUASCRIPT_H" | Out-File $OutputFile -Append
    "" | Out-File $OutputFile -Append
    "const char* lua_scripts[] = {" | Out-File $OutputFile -Append

    foreach ($InputFile in $InputFiles) {

        if (-not (Test-Path $InputFile)) {
            Write-Host "Error: Input file '$InputFile' does not exist."
            exit 1
        }

        $LuacPath = Join-Path $ExeDir "luac32.exe"

        $process = Start-Process -FilePath $LuacPath -ArgumentList "-p `"$InputFile`"" -NoNewWindow -Wait -PassThru
        if ($process.ExitCode -ne 0) {
            Write-Host "Error: luac32 failed to compile '$InputFile'."
            exit 1
        }

        '  R"(' | Out-File $OutputFile -Append

        Get-Content $InputFile |
            ForEach-Object {
                $_ -replace "    ", "  " `
                   -replace "--.*$", ""
            } |
            Where-Object { $_.Trim() -ne "" } |
            Out-File $OutputFile -Append

        ')"' | Out-File $OutputFile -Append
        "  ," | Out-File $OutputFile -Append
    }

    "  nullptr" | Out-File $OutputFile -Append
    "};" | Out-File $OutputFile -Append
    "" | Out-File $OutputFile -Append

    "const char* script_names[] = {" | Out-File $OutputFile -Append

    foreach ($InputFile in $InputFiles) {

        $FileName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)

        # Split camel case
        $Formatted = [regex]::Replace($FileName, '([a-z])([A-Z])', '$1 $2')

        # Capitalize words
        $Formatted = ($Formatted -split ' ') | ForEach-Object {
            if ($_.Length -gt 1) {
                $_.Substring(0,1).ToUpper() + $_.Substring(1)
            } else {
                $_.ToUpper()
            }
        }

        $FinalName = $Formatted -join " "

        "  `"$FinalName`"," | Out-File $OutputFile -Append
    }

    "  nullptr" | Out-File $OutputFile -Append
    "};" | Out-File $OutputFile -Append
    "" | Out-File $OutputFile -Append
    "#endif // LUASCRIPT_H" | Out-File $OutputFile -Append

    $content = (Get-Content $OutputFile -Raw) -replace "`r`n", "`n"
    $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($OutputFile, $content, $Utf8NoBom)

}
elseif ($m -eq "luac") {

    if ($InputFiles.Count -ne 1) {
        Write-Host "Error: Only one input file allowed in luac mode."
        exit 1
    }

    $OutputFile = Join-Path $ExeDir "..\data\runtime.luac"
    $OutputFile = [System.IO.Path]::GetFullPath($OutputFile)

    $LuacPath = Join-Path $ExeDir "luac32.exe"

    Start-Process -FilePath $LuacPath `
        -ArgumentList "-s -o `"$OutputFile`" `"$($InputFiles[0])`"" `
        -NoNewWindow -Wait

}
else {
    Write-Host "Unsupported mode: $m"
    exit 1
}