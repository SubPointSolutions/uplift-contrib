$srcDir   = "c:/github"

Write-Host "[~] ensuring local src dir: $srcDir"
New-Item -ItemType Directory -Force -Path $srcDir | Out-Null

$spmeta2Repo = "https://github.com/SubPointSolutions/spmeta2.git"

$spmeta2WorkDir = "$srcDir/spmeta2"
$spmeta2Branch  = "dev"

if( (Test-Path $spmeta2WorkDir) -eq $True) {
    
    Write-Host "[~] repository folder exists, fetching latest branch: $spmeta2Branch"

    powershell -Command "cd $spmeta2WorkDir/spmeta2; git checkout $spmeta2Branch; git status"
    if ($LASTEXITCODE -ne 0 ) { throw "Fail to pull the latest branch: $spmeta2Branch" }

} else {
    
    Write-Host "[~] cloning repository: $spmeta2Repo"
    powershell -Command "cd $srcDir; git clone $spmeta2Repo; "
    if ($LASTEXITCODE -ne 0 ) { throw "Fail to clone the repository" }

    Write-Host "[~] fetching latest branch: $spmeta2Branch"
    powershell -Command "cd $srcDir/spmeta2;  git checkout $spmeta2Branch; git status"
    if ($LASTEXITCODE -ne 0 ) { throw "Fail to checkout $spmeta2Branch" }

}

powershell -Command "cd $spmeta2WorkDir/spmeta2/build; .\build.ps1"
if ($LASTEXITCODE -ne 0 ) { throw "Fail build" }