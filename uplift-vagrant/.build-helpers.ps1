
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


function Get-ToolCmd($name) {
    return (Get-Command $name -ErrorAction SilentlyContinue)
}

Function Test-PortInUse
{
    Param(
        [Parameter(Mandatory=$true)]
        [Int] $port
    )

    $socket = New-Object System.Net.Sockets.TcpClient

    try
    {
        $socket.BeginConnect("127.0.0.1", $port, $null, $null) | Out-Null
        # $success = $connect.AsyncWaitHandle.WaitOne(500, $true)

        if ($socket.Connected)
        {
            return $True
        }

        return $False
    } finally {
        if($null -ne $socket) {
            $socket.Close()
            $socket.Dispose()
            $socket = $null
        }
    }
}

Function Get-RandomPort
{
    return Get-Random -Min 8000 -Max 9000
}

Function Get-RandomUsablePort
{
    Param(
        [Int] $maxTries = 100
    );
    $result = -1;
    $tries = 0;
    DO
    {
        $randomPort = Get-RandomPort;
        if (-Not (Test-PortInUse($randomPort)))
        {
            $result = $randomPort;
        }
        $tries += 1;
    } While (($result -lt 0) -and ($tries -lt $maxTries));
    return $result;
}


function Test-HttpUrl($url) {

    Write-BuildInfoMessage "[~] checking url: $url"
    
    $result = Invoke-WebRequest "$url" `
        -UseBasicParsing `
        -DisableKeepAlive `
        -Method HEAD 

    if($result.StatusCode -eq 200) {
        Write-BuildInfoMessage  "[+] StatusCode: $($result.StatusCode) for url: $url"
    } else {
        throw "[!] StatusCode: $($result.StatusCode), expected 200!"
    }
}

function Start-LocalHttpServer {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "", Scope="Function")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]

    param(
        $port,
        $path
    )

    Write-BuildInfoMessage "[~] Starting http-server to serve packer/vagrant builds"
    Write-BuildInfoMessage " - port : $port"
    Write-BuildInfoMessage " - local: localhost:$port"
    Write-BuildInfoMessage " - vm   : 10.0.2.2:$port"
    Write-BuildInfoMessage " - path : $path"

    if( (Test-Path $path) -eq $False) {
        $errorMessage = " [!] Path does not exist: $path"

        Write-BuildErrorMessage $errorMessage
        throw $errorMessage
    }

    $httpServerTool = Get-ToolCmd("http-server") 

    if($null -eq $httpServerTool) {
        $errMessage = "http-server tool is not here. Use 'npm install http-server -g' to install it - https://www.npmjs.com/package/http-server"
        
        Write-BuildErrorMessage $errMessage
        throw $errMessage
    }

    $job = http-server $path -p $port &

    Write-BuildInfoMessage "Pause 5 sec allowing http-server to start..."
    Start-Sleep 5

    Test-HttpUrl "http://localhost:$port"

    return $job
}