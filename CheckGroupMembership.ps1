############################################################################
# Script Title Here
############################################################################

#Description - This is a template, you figure it out
#Author - DS/MP
#Requirements - List things like extra cmdlets etc here, for example Quest cmdlets.
#Date - 12/05/14
#Tested - Y\N

#First - the following lines clear the errors in the current PowerShell Session. 
$error.clear() 

############################################################################
# Global Variables Start 
############################################################################
 
$logFile= "ScriptName";
 
############################################################################
# Global Variables End
############################################################################
 
############################################################################
# Functions Start 
############################################################################
 
#Retrieves the path the script has been run from
function Get-ScriptPath
{     Split-Path $myInvocation.ScriptName
}
 
#Defines functions to be used to output progress. Use these within the script to save time.
function ShowError  ($msg){Write-Host "`n";Write-Host -ForegroundColor Red $msg;   LogErrorToFile  $msg }
function ShowSuccess($msg){Write-Host "`n";Write-Host -ForegroundColor Green  $msg; LogToFile   ($msg)}
function ShowProgress($msg){Write-Host "`n";Write-Host -ForegroundColor Cyan  $msg; LogToFile   ($msg)}
function ShowInfo($msg){Write-Host "`n";Write-Host -ForegroundColor Yellow  $msg; LogToFile   ($msg)}
function LogToFile   ($msg){$msg |Out-File -Append -FilePath $logFile -ErrorAction:SilentlyContinue;}
function LogSuccessToFile   ($msg){"Success: $msg" |Out-File -Append -FilePath $logFile -ErrorAction:SilentlyContinue;}
function LogErrorToFile   ($msg){"Error: $msg" |Out-File -Append -FilePath $logFile -ErrorAction:SilentlyContinue;}
 
############################################################################
# Functions end 
############################################################################
 
############################################################################
#Log file initialization
############################################################################

$start = Get-Date
$timeForFileName = $start.ToString("MM-dd-yyyy_hh-mm-ss")
$CurrentDir = Get-ScriptPath
$LogFolder =  $currentDir+"\Logs";
if( (Test-Path ($LogFolder)) -eq $false)
{
                New-Item $LogFolder -ItemType Directory
                ShowSuccess "Directory $LogFolder created successfully.";
}
 
$logFile = $LogFolder+"\$logFile-$timeForFileName.txt"
ShowProgress "File being created  $logFile";
New-Item $logFile -type file -force -ErrorAction:SilentlyContinue;
 
############################################################################
# Script start   
############################################################################
 
 
ShowProgress "Script started at $start";


filter groups { if ($_.Name -like '*notcorrect*') { $_ } }
$dislists = get-distributiongroup |groups
$dislists

foreach ($group in $dislists){$members+=get-distributiongroupmember $group.name}

$Mailboxes = Get-Mailbox -ResultSize Unlimited

ForEach($mailbox in $mailboxes){
            $error.Clear()
            $global:RecordsProcessed++ 
            $mailboxname = $mailbox.PrimarySMTPAddress
            # Check if the mailbox is a member of any of the groups.
            ShowInfo "checking for membership."
            try{
                if($members.name -contains $mailbox.name){
                    # Member is in one of the groups, hoorah!
                    ShowInfo "User $mailbox.name found in one of the groups."}

                else{
				    # Member is not in a group, Booooo!
                    ShowError "User $mailboxname does not appear in any of the groups"
					$datastring = ($mailboxname)
                    }
                }
            catch{
                ShowError "There was an error "
                $TotalSuccess = $false
                }
            finally{
			    Out-File -FilePath c:\temp\test.csv -InputObject $datastring -Encoding UTF8 -append
                if(!$error){

                    }
                
                }
            }
        

   
 
ShowProgress "------------Processing Ended---------------------"
$end = Get-Date;
ShowProgress "Script ended at $end";
$diff=New-TimeSpan -Start $start -End $end
ShowProgress "Time taken $($diff.Hours)h : $($diff.Minutes)m : $($diff.Seconds)s ";

############################################################################
# Script end   
############################################################################