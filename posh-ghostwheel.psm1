#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )
    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor

    # Writes the drive portion
    $path_icon = $sl.PromptSymbols.FolderSymbol
    $path = "$(Get-ShortPath -dir $pwd)"
    $path_list = $path.Split($sl.PromptSymbols.PathSeparator)
    if ($path -eq "~") {
        $path_icon = $sl.PromptSymbols.HomeDirectorySymbol
    }
    elseif ($path[0] -eq "~" ) {
        $path_icon = $sl.PromptSymbols.HomeFolderSymbol
    }
    elseif ($path_list.Length -eq 1) {
        $path_icon = $sl.PromptSymbols.DiskSymbol
    }

    $prompt += Write-Prompt -Object "$path_icon " -ForegroundColor Blue -BackgroundColor $sl.Colors.PromptBackgroundColor
    foreach ($path_segment in $path_list) {
        if ($path_segment -eq "~") {
            $seg_color = [ConsoleColor]::Blue
        }
        elseif ($path_segment -eq $sl.PromptSymbols.TruncatedFolderSymbol) {
            $seg_color = [ConsoleColor]::DarkGray
        }
        else {
            $seg_color = $sl.Colors.PromptForegroundColor
        }
        $prompt += Write-Prompt -Object $path_segment -ForegroundColor $seg_color -BackgroundColor $sl.Colors.PromptBackgroundColor
        if ($path_segment -ne $path_list[$path_list.Length - 1]){
            $prompt += Write-Prompt -Object $sl.PromptSymbols.PathSeparator -ForegroundColor DarkGray -BackgroundColor $sl.Colors.PromptBackgroundColor
        }
    }

    # Writes the git status
    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor DarkGray -BackgroundColor $sl.Colors.PromptBackgroundColor
        $prompt += Write-Prompt -Object $themeInfo.VcInfo -BackgroundColor $sl.Colors.PromptBackgroundColor -ForegroundColor $themeInfo.BackgroundColor
    }

    # Writes the postfix to the prompt
    $status = $sl.PromptSymbols.SuccecsCommandSymbol
    if ($lastCommandFailed) {
        $status = "$($global:Error.Count) $($sl.PromptSymbols.FailedCommandSymbol)"
    }
    $env = ""
    if (Test-VirtualEnv) {
        $env += $sl.PromptSymbols.SegmentBackwardSymbol
        $env += "$(Get-VirtualEnvName)$($sl.PromptSymbols.VirtualEnvSymbol)"
    }
    $user_text = ""
    if ($sl.Options.CurrentUser) {
        $user_text = "$($sl.CurrentUser) "
    }
    #check for elevated prompt
    If (Test-Administrator) {
        $user_text += $sl.PromptSymbols.ElevatedSymbol
    }
    else {
        $user_text += $sl.PromptSymbols.UserSymbol
    }

    $prompt += Set-CursorForRightBlockWrite -textLength ($status.Length + $sl.PromptSymbols.OsSymbol.Length + $env.Length + $user_text.Length + 5)
    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $prompt += Write-Prompt -Object "$($status)" -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    } else {
        $prompt += Write-Prompt -Object "$($status)" -ForegroundColor Green -BackgroundColor $sl.Colors.PromptBackgroundColor
    }

    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentBackwardSymbol -ForegroundColor DarkGray -BackgroundColor $sl.Colors.PromptBackgroundColor
        $prompt += Write-Prompt -Object "$(Get-VirtualEnvName) $($sl.PromptSymbols.VirtualEnvSymbol)" -ForegroundColor $sl.Colors.VirtualEnvForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }

    #check for elevated prompt
    $prompt += Write-Prompt $sl.PromptSymbols.SegmentBackwardSymbol -ForegroundColor DarkGray -BackgroundColor $sl.Colors.PromptBackgroundColor
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object $user_text -ForegroundColor $sl.Colors.AdminIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }
    else {
        $prompt += Write-Prompt -Object $user_text -ForegroundColor White -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }
    $prompt += Write-Prompt $sl.PromptSymbols.SegmentBackwardSymbol -ForegroundColor DarkGray -BackgroundColor $sl.Colors.PromptBackgroundColor
    $prompt += Write-Prompt $sl.PromptSymbols.OsSymbol -ForegroundColor Cyan -BackgroundColor $sl.Colors.PromptBackgroundColor

    $prompt += Set-Newline
    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor

    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }
    $prompt += Write-Prompt -Object ($sl.PromptSymbols.PromptIndicator) -ForegroundColor White -BackgroundColor $sl.Colors.PromptBackgroundColor
    $prompt
}

$sl = $global:ThemeSettings #local settingsf101
$sl.Options.OriginSymbols = $true
$sl.Options.CurrentUser = $false
$sl.PromptSymbols.HomeSymbol = "~"
$sl.PromptSymbols.StartSymbol = ' '
$sl.PromptSymbols.FolderSymbol = "$([char]::ConvertFromUtf32(0xf115)) "
$sl.PromptSymbols.HomeDirectorySymbol = "$([char]::ConvertFromUtf32(0xf015)) "
$sl.PromptSymbols.HomeFolderSymbol = "$([char]::ConvertFromUtf32(0xf07c)) "
$sl.GitSymbols.BranchSymbol = [char]::ConvertFromUtf32(0xf126)
$sl.PromptSymbols.PromptIndicator = "$([char]::ConvertFromUtf32(0xF101)) "
$sl.PromptSymbols.SegmentForwardSymbol = "$([char]::ConvertFromUtf32(0xf460)) "
$sl.PromptSymbols.SegmentBackwardSymbol = "$([char]::ConvertFromUtf32(0xf104)) "
$sl.PromptSymbols.VirtualEnvSymbol = "$([char]::ConvertFromUtf32(0xe235)) "
$sl.PromptSymbols.FailedCommandSymbol = "$([char]::ConvertFromUtf32(0xf071)) "
$sl.PromptSymbols.SuccecsCommandSymbol = "$([char]::ConvertFromUtf32(0xf00c)) "
$sl.PromptSymbols.UserSymbol = "$([char]::ConvertFromUtf32(0xf007)) "
$sl.PromptSymbols.ElevatedSymbol = "$([char]::ConvertFromUtf32(0x26A1)) "
$sl.PromptSymbols.OsSymbol = "$([char]::ConvertFromUtf32(0xf17a)) "
$sl.PromptSymbols.UNCSymbol = [char]::ConvertFromUtf32(0x00a7)
$sl.PromptSymbols.TruncatedFolderSymbol = [char]::ConvertFromUtf32(0x2026)
$sl.PromptSymbols.DiskSymbol = [char]::ConvertFromUtf32(0xff524)
$sl.Colors.PromptForegroundColor = [ConsoleColor]::Cyan
$sl.Colors.PromptBackgroundColor = (Get-Host).UI.RawUI.BackgroundColor
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::DarkBlue
Set-PSReadLineOption -PromptText $sl.PromptSymbols.PromptIndicator