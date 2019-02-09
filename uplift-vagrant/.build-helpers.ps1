
function Write-BuildInfoMessage {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Scope="Function")]
    param (
        $msg 
    )

    Write-Host $msg -ForegroundColor Green
}

function Write-BuildDebugMessage {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Scope="Function")]
    param (
        $msg 
    )

    if($ENV:UPLF_LOG_LEVEL -eq "DEBUG") {
        Write-Host $msg -ForegroundColor Blue
    }
}

function Write-BuildErrorMessage {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Scope="Function")]
    param (
        $msg 
    )

    Write-Host $msg -ForegroundColor Red
}

function Write-BuildWarnMessage {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Scope="Function")]
    param (
        $msg 
    )

    Write-Host $msg -ForegroundColor Yellow
}

function Write-BuildWarningMessage {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Scope="Function")]
    param (
        $msg 
    )

    Write-Host $msg -ForegroundColor Yellow
}

function Confirm-ExitCode($code, $message)
{
    if ($code -eq 0) {
        Write-Build Green "Exit code is 0, continue..."
    } else {
        $errorMessage = "Exiting with non-zero code [$code] - $message"

        Write-Build Red  $errorMessage
        throw  $errorMessage
    }
}