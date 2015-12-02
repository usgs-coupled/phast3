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
# set HEAD
$HEAD=(-split (svn --config-dir C:\Users\jenkins\svn-jenkins st -v configure.ac))[0]
if ([string]::IsNullOrEmpty($Env:REL) -or $Env:REL.CompareTo('HEAD') -eq 0) {
  $Env:REL = $HEAD
}

$Env:VER_TAG="r$Env:REL"
$Env:VER_NUMTAG="-$Env:REL"
$Env:VERSION_LONG="$Env:ver_major.$Env:ver_minor.$Env:ver_patch.$Env:REL"
$Env:VER_UC="$Env:ver_major.$Env:ver_minor.$Env:ver_patch.$Env:REL"
$Env:MSI_VERSION="$Env:ver_major.$Env:ver_minor.$Env:REL"

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
Get-ChildItem -recurse -Include $files -Exclude "CMakeLists.txt" | Remove-Item
Set-Location ..

Write-Output "Cleaning up examples directory"
Get-ChildItem -filter ".\examples\hosts" | Remove-Item
Get-ChildItem -filter ".\examples\Makefile" | Remove-Item
Get-ChildItem -filter ".\examples\run" | Remove-Item
Get-ChildItem -filter ".\examples\schema" | Remove-Item
Get-ChildItem -filter ".\examples\zero.sed" | Remove-Item
Get-ChildItem -filter ".\examples\zero1.sed" | Remove-Item
Get-ChildItem -filter ".\examples\runmpich" | Remove-Item
Get-ChildItem -filter ".\examples\ex4\ex4.restart.gz" | Remove-Item
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

