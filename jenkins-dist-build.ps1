# use gnuwin32 wget NOT alias (wget -> Invoke-WebRequest)
While (Test-Path Alias:wget) {
  Remove-Item Alias:wget
}

# set date
if ([string]::IsNullOrEmpty($Env:DATE)) {
  $Env:DATE = date +%x
}
$Env:RELEASE_DATE = date -d $Env:DATE "+%B %e, %G"
# set ver
if ([string]::IsNullOrEmpty($Env:VER)) {
  $SRC_FILE=(plink -i C:\Users\Public\rsa-key-20151119.ppk charlton@parkplace `
            "cd ftp/phast; ls -t phast-*-*.tar.gz | awk '{if (NR == 1) {print}}'")
  $v = ($SRC_FILE -replace "^phast-", "" -replace "-.*tar.gz$", "") -split "\."
  if ([string]::IsNullOrEmpty($v[2])) {
    $v[2] = 0
  }
  $v[2] = 1 + $v[2]
  $Env:ver_major = $v[0]
  $Env:ver_minor = $v[1]
  $Env:ver_patch = $v[2]
  $Env:VER = $v -join "."
}
else {
  $v = ($Env:VER) -split "\."  
  $Env:ver_major = $v[0]
  $Env:ver_minor = $v[1]
  $Env:ver_patch = $v[2]
}
# set HEAD
[string]$HEAD=(-split (svn --config-dir C:\Users\jenkins\svn-jenkins st -v configure.ac))[0]
if ([string]::IsNullOrEmpty($Env:REL) -or $Env:REL.CompareTo('HEAD') -eq 0) {
  $Env:REL = $HEAD
}

$Env:VER_TAG="r$Env:REL"
$Env:VER_NUMTAG="-$Env:REL"
$Env:VERSION_LONG="$Env:ver_major.$Env:ver_minor.$Env:ver_patch.$Env:REL"
$Env:VER_UC="$Env:ver_major.$Env:ver_minor.$Env:ver_patch.$Env:REL"
$Env:MSI_VERSION="$Env:ver_major.$Env:ver_minor.$Env:REL"
$Env:FULLPKG="$Env:NAME-$Env:VER-$Env:REL"

Write-Output "HEAD=$HEAD"
Write-Output "Env:DATE=$Env:DATE"
Write-Output "Env:RELEASE_DATE=$Env:RELEASE_DATE"
Write-Output "Env:ver_major=$Env:ver_major"
Write-Output "Env:ver_major=$Env:ver_minor"
Write-Output "Env:ver_major=$Env:ver_patch"
Write-Output "Env:VER=$Env:VER"
Write-Output "Env:REL=$Env:REL"
Write-Output "Env:VER_TAG=$Env:VER_TAG"
Write-Output "Env:VER_NUMTAG=$Env:VER_NUMTAG"
Write-Output "Env:VERSION_LONG=$Env:VERSION_LONG"
Write-Output "Env:MSI_VERSION=$Env:MSI_VERSION"
Write-Output "Env:FULLPKG=$Env:FULLPKG"

# create phast-dist-linux build URL
[string]$trigger = 'http://136.177.112.8:8080/job/phast-dist-linux/buildWithParameters'
$trigger += '?DATE='
$trigger += ${Env:DATE} -replace '/','%2f'
$trigger += '&REL='
$trigger += ${Env:REL}
$trigger += '&VER='
$trigger += ${Env:VER}
$trigger += '&delay=0sec'
Write-Output "trigger=$trigger"

# trigger build
wget -S $trigger -O start.html 2> queue.out
[string]$location="$((-Split (cat .\queue.out | Select-String "Location"))[1])api/xml"
Write-Output "location=$location"

# wget until <waitingItem> changes to <leftItem>
do {
  Start-Sleep -s 2
  wget $location -O leftItem.xml 2> $null
} until ((Select-Xml -Path .\leftItem.xml -XPath "/leftItem"))

# verify phast-dist-linux is buildable
[string]$buildable="$((Select-Xml -Path .\leftItem.xml -XPath "/leftItem/buildable").Node.InnerText)"
if ($buildable -contains 'false') {
  throw "*** phast-dist-linux cannot be built ***`n"
}

[string]$build="$((Select-Xml -Path .\leftItem.xml -XPath "/leftItem/executable/url").Node.InnerText)api/xml"
Write-Output "build=$build"

# wget until <freeStyleBuild><building>false</building></freeStyleBuild>
do {
  Start-Sleep -s 20
  wget $build -O freeStyleBuild.xml 2> $null
  [string]$building = (Select-Xml -Path .\freeStyleBuild.xml -XPath "/freeStyleBuild/building").Node.InnerText
  Write-Output "building=$building"
} until($building -contains 'false')

[string]$url=(Select-Xml -Path .\freeStyleBuild.xml -XPath "/freeStyleBuild/url").Node.InnerText
[string]$file=((Select-Xml -Path .\freeStyleBuild.xml -XPath "/freeStyleBuild/artifact") | Select-Object -First 1).Node.relativePath
[string]$download="${url}artifact/${file}"

Write-Output "url=$url"
Write-Output "file=$file"
Write-Output "download=$download"

# download cmake tar.gz file
if (Test-Path -Path "${Env:FULLPKG}.tar.gz" -PathType Leaf) {
  Remove-Item ".\${Env:FULLPKG}.tar.gz"
}
wget $download 2> $null

# untar cmake package
if (Test-Path -Path ".\${Env:FULLPKG}" -PathType Container) {
  Remove-Item ".\${Env:FULLPKG}" -Recurse -Force
}
if (Test-Path -Path ".\${Env:FULLPKG}.tar" -PathType Leaf) {
  Remove-Item ".\${Env:FULLPKG}.tar"
}
& 'C:\Program Files\7-Zip\7z.exe' e "${Env:FULLPKG}.tar.gz"
& 'C:\Program Files\7-Zip\7z.exe' x "${Env:FULLPKG}.tar"
Set-Location "${Env:FULLPKG}"

# copy ctest files
Copy-Item "..\build2012.bat"
Copy-Item "..\build-mpi-2012-64.cmake"
Copy-Item "..\build-mt-2012-64.cmake"
Copy-Item "..\CTestConfig.cmake"

# build cmake 
.\build2012.bat
Set-Location ..

# duplicate build/dist.sh
$sed_files=@('CMakeLists.txt', `
             'doc/phreeqc3-doc/RELEASE.TXT', `
             'src/phast/phast_version.h', `
             'src/phast/PhastFortran/phast_spmd.F90', `
             'src/phasthdf/win32/phasthdf_version.h', `
             'src/phastinput/phastinput_version.h', `
             'README', `
             'RELEASE')
foreach ($file in $sed_files) {
  (Get-Content $file) | Foreach-Object {
    $_ -replace "(#define *PHAST_VER_MAJOR\s*)[0-9]*",        "`${1}$Env:ver_major" `
       -replace "(#define *PHAST_VER_MINOR\s*)[0-9]*",        "`${1}$Env:ver_minor" `
       -replace "(#define *PHAST_VER_PATCH\s*)[0-9]*",        "`${1}$Env:ver_patch" `
       -replace "(#define *PHAST_VER_TAG\s*)[0-9]*",          "`${1}$Env:VER_TAG" `
       -replace "(#define *PHAST_VER_NUMTAG\s*)[0-9]*",       "`${1}$Env:VER_NUMTAG" `
       -replace "(#define *PHAST_VER_REVISION\s*)[0-9]*",     "`${1}$Env:REL" `
       -replace "@VERSION@",                                  "$Env:VER" `
       -replace "@REVISION@",                                 "$Env:REL" `
       -replace "@VER_DATE@",                                 "$Env:RELEASE_DATE" `
       -replace "@RELEASE_DATE@",                             "$Env:RELEASE_DATE" `
       -replace "@VERSION_LONG@",                             "$Env:VERSION_LONG" `
       -replace "@PHREEQC_VER@",                              "$Env:VER" `
       -replace "@PHREEQC_DATE@",                             "$Env:RELEASE_DATE" `
       -replace "@MSI_VERSION@",                              "$Env:MSI_VERSION" `
       -replace "(set\(PHAST_VERSION_MAJOR\s*)\""[0-9]*\""",  "`${1}""$Env:ver_major""" `
       -replace "(set\(PHAST_VERSION_MINOR\s*)\""[0-9]*\""",  "`${1}""$Env:ver_minor""" `
       -replace "(set\(PHAST_VERSION_PATCH\s*)\""[0-9]*\""",  "`${1}""$Env:ver_patch""" `
       -replace "(set\(PHAST_REVISION\s*)\""[0-9]*\""",       "`${1}""$Env:REL""" `
  } | Set-Content $file
}
Write-Output "Making examples clean"
Set-Location examples
$files="*~","*.O.*","*.log","*.h5","*.h5~","abs*","*.h5dump","*.sel","*.xyz*","*backup*","*.txt","*.tsv","Phast.tmp","clean","notes","*.wphast","*.mv"
$excludes="CMakeLists.txt","bedrock.txt","property.mix.xyzt","property.xyzt"
Get-ChildItem -recurse -Include $files -Exclude $excludes | Remove-Item
Set-Location ..

Write-Output "Cleaning up examples directory"
Get-ChildItem -filter ".\examples\hosts" | Remove-Item
Get-ChildItem -filter ".\examples\Makefile" | Remove-Item
Get-ChildItem -filter ".\examples\run" | Remove-Item
Get-ChildItem -filter ".\examples\schema" | Remove-Item
Get-ChildItem -filter ".\examples\zero.sed" | Remove-Item
Get-ChildItem -filter ".\examples\zero1.sed" | Remove-Item
Get-ChildItem -filter ".\examples\runmpich" | Remove-Item
##Get-ChildItem -filter ".\examples\ex4\ex4.restart.gz" | Remove-Item
Get-ChildItem -filter ".\examples\ex5\plume.heads.xyzt" | Remove-Item
Get-ChildItem -filter ".\examples\ex5\runmpich" | Remove-Item
Get-ChildItem -filter ".\examples\print_check_ss\print_check_ss.head.dat" | Remove-Item
Get-ChildItem -filter "bootstrap" | Remove-Item

Write-Output "Cleaning up misc files"
Get-ChildItem -filter "bootstrap" | Remove-Item
Get-ChildItem -Path src -Recurse -Include "*.user" | Remove-Item

Write-Output "Deleting examples that aren't distributed"
Move-Item .\examples .\examples-delete
New-Item .\examples -ItemType directory
Copy-Item .\examples-delete\CMakeLists.txt .\examples\.
Copy-Item .\examples-delete\Makefile.am .\examples\.

$examples="decay","diffusion1d","diffusion2d","disp2d","ex1","ex2","ex3","ex4","ex4_ddl","ex4_noedl","ex4_start_time","ex4_transient","ex4restart","ex5","ex6","kindred4.4","leaky","leakysurface","leakyx","leakyz","linear_bc","linear_ic","mass_balance","notch","phrqex11","property","radial","river","shell","simple","unconf","well","zf"

foreach($ex in $examples){
  Move-Item ".\examples-delete\$ex" ".\examples\$ex"
}
Remove-Item -Recurse .\examples-delete

Write-Output "Cleaning up src/phastinput directory"
Remove-Item -Recurse "src/phastinput/test"

Write-Output "Renaming phreeqc.dat to phast.dat"
Move-Item "database/phreeqc.dat" "database/phast.dat"

# build
Write-Output "Building with VS2005"
$Env:FULLPKG="$Env:NAME-$Env:VER-$Env:REL"
$Env:MSI_SLN=".\msi\msi.sln"
$Env:BOOT_SLN=".\Bootstrapper\PhastBootstrapper.sln"
$MsBuild = "c:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\MsBuild.exe"

# build msi
$msi_opts="$Env:MSI_SLN /t:msi /p:Configuration=Release /p:Platform=x64 /p:TargetName=$Env:FULLPKG-x64 /p:Major=$Env:ver_major /p:Minor=$Env:ver_minor /p:Patch=$Env:ver_patch /p:Build=$Env:REL /verbosity:detailed"
Invoke-Expression "$MsBuild $msi_opts"

# build bootstrap
$boot_opts="$Env:BOOT_SLN /t:PhastBootstrapper /p:Configuration=Release /p:Platform=x64 /p:TargetName=$Env:FULLPKG-x64 /p:Major=$Env:ver_major /p:Minor=$Env:ver_minor /p:Patch=$Env:ver_patch /p:Build=$Env:REL /verbosity:detailed"
Invoke-Expression "$MsBuild $boot_opts"

# set wphast parameters
Remove-Item ".\wphast.properties"
"NAME=phast4windows" | Out-File -FilePath ".\wphast.properties" -Encoding ascii
"DATE=${Env:DATE}"   | Out-File -FilePath ".\wphast.properties" -Encoding ascii -Append
"REL=${Env:REL}"     | Out-File -FilePath ".\wphast.properties" -Encoding ascii -Append
"VER=${Env:VER}"     | Out-File -FilePath ".\wphast.properties" -Encoding ascii -Append
"TAG=trunk"          | Out-File -FilePath ".\wphast.properties" -Encoding ascii -Append
