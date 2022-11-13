<#
Поиск компа с указанным именем на всех dhcp-серверах авторизованных в AD , 

поиск проиgзводить на одном из них (DC)
#>
param(
    [String] $HostName,
    [String] $dc
)

Invoke-Command -ComputerName $dc -ScriptBlock {
    param($CompName)
    Get-DhcpServerInDC | 
    %{ 
        $dhcpSrv = $_.DnsName ; 
        try {
            Test-Connection -Count 1 -ComputerName $dhcpSrv -ErrorAction stop | Out-Null ;
            Get-DhcpServerv4Scope -computerName $dhcpSrv | Get-DhcpServerv4Lease -computername $dhcpSrv 
        } catch {
        }
    } | 
    Where-Object -Property HostName -iLike "$CompName.*" | 
    Select-Object -Property @{'n'='DHCPserver';'e'={$dhcpSrv}},* 
} -ArgumentList $HostName 