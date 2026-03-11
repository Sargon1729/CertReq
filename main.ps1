. ./config.ps1

function Write-Log {

    param(
        [string]$Message
    )
    $date = get-date -Format "dd/MM/yyyy hh:mm:ss"
    "$date $Message" | Out-File $LOGFILE -Append -Encoding ascii
    Write-Host "$date $Message" -ForegroundColor Yellow
}

Write-Log "Script started by $(whoami)"

###############################################################################

Import-Module PSPKI

##############################################################################


foreach ($folder in (gci $PKIRoot)) {
    if ($folder.name -like "csr -*") {

        if ((gci $folder.FullName) -ne $null) {

            Write-Log "CSRs found in $folder"

            try {

                foreach ($csr in (gci $folder.FullName)) {

                    $template = $folder.name -split ("CSR - ")
                    $date = Get-Date -Format "dd-MM-yyyy-HH-mm-ss"

                    try{
                        $request = certreq -submit -attrib "CertificateTemplate:$template" -config - $csr.FullName
                        }

                    catch {
                        Write-Log "Could not sign CSR at Certerq"
                        }

                    $RequestID = $request[3].Split(" ")[1]
                    $ca = Get-CertificationAuthority -name $ca

                    Get-PendingRequest -CertificationAuthority $ca -Property "RawRequest" -RequestID $RequestID | Approve-CertificateRequest

                    Get-IssuedRequest -CertificationAuthority $ca -RequestID $requestID | Receive-Certificate -Path $certfolder -Force

                    #rename cert
                    $certname = $certfolder + "\" + "RequestID_$requestID.cer"
                    $newcertname = $certfolder + "\" + "SC_" + ( $csr | select-object -ExpandProperty name).split(".")[0] + ".cer"
                    Rename-Item -Path $certname -NewName  $newcertname

                    #move csr
                    $newcsrpath = "$Completed_csr_path\$csr" + "-$date"
                    Move-Item $csr.FullName -Destination $newcsrpath
                    Write-Log "$CSR signed, Certificate can be found in $newcertname"


                }

            }

            catch {
                Write-Log "Something went wrong when trying to sign the CSR $csr, possibly file was not the correct extension or corrupt"
            }




        }

        Else {
            Write-Log "No CSRs to sign in folder $folder"
        }



    }



}

Read-host "Press any key to close"





