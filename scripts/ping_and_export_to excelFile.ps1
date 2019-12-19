<# 
Script to ping and report on computers. 
Data reported: ComputerName, IPAddress, MACAddress, DateBuilt, OSVersion, Model, and LastBootTime 
Requires list of computers in text file 
#> 
$ComputerList = ".\computerlist.txt" 
$CSVFile = ".\Ping-Report-$(Get-Date -format yyyyMMdd_hhmmsstt).csv" > 
$LogFile = ".\Ping-Report-$(Get-Date -format yyyyMMdd_hhmmsstt).txt" 
# End Data Entry