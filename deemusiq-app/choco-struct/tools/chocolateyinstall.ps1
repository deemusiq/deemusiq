$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'DeeMusiq-windows-x86_64-setup.exe'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe' #only one of these: exe, msi, msu
  file         = $fileLocation

  softwareName  = 'DeeMusiq*' #part or all of the Display Name as you see it in Programs and Features. It should be enough to be unique
  silentArgs   = '/S' # NSIS
  validExitCodes= @(0)
}

Install-ChocolateyInstallPackage @packageArgs
