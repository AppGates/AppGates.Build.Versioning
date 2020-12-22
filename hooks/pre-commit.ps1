& 'pre-commit2.ps1'

If($LastExitcode -eq 0){

Write-Host 'Der Exit Code ist wie erwartet 0!' -ForegroundColor Green

} else {

Write-Host 'Der Exit Code ist NICHT 0!' -ForegroundColor Magenta
}

exit 1
