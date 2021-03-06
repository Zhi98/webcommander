<#
Copyright (c) 2012-2014 VMware, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
#>

<#
	.SYNOPSIS
		Open VM console in browser

	.DESCRIPTION
		This command generates a link to open VM console in the browser.
		The link is valid for only 30 seconds. Once expired, you need to run the
		command again to generate a new link. 
		This command could run against multiple virtual machines.
		VMRC plugin must be installed and activated in your browser. You could install
		PowerCLI 5.8+ to install the plugin.		
		
	.FUNCTIONALITY
		Remote_Console, VM
		
	.NOTES
		AUTHOR: Jerry Liu
		EMAIL: liuj@vmware.com
#>

Param (
	[parameter(
		Mandatory=$true,
		HelpMessage="IP or FQDN of the ESX or VC server where target VM is located"
	)]
	[string]
		$serverAddress, 
	
	[parameter(
		HelpMessage="User name to connect to the server (default is root)"
	)]
	[string]
		$serverUser="root", 
	
	[parameter(
		HelpMessage="Password of the user"
	)]
	[string]
		$serverPassword=$env:defaultPassword, 
	
	[parameter(
		HelpMessage="Name of target VM. Support multiple values seperated by comma and also wildcard. Default is '*'."
	)]
	[string]
		$vmName="*"
)

foreach ($paramKey in $psboundparameters.keys) {
	$oldValue = $psboundparameters.item($paramKey)
	$newValue = [system.web.httputility]::urldecode("$oldValue")
	set-variable -name $paramKey -value $newValue
}

. .\objects.ps1

$vivmList = getVivmList $vmName $serverAddress $serverUser $serverPassword
$vivmList | % {
	writeSeparator
	try {
		$url = Open-VMConsoleWindow -vm $_ -UrlOnly -ea stop
		$url = $url.replace("file:///C:\Program%20Files%20(x86)\VMware\Infrastructure\vSphere%20PowerCLI\","").replace("\","/")
		writeLink $_.name $url
	} catch {
		writeStderr
	}
}