windows_isos

This is the windows_isos puppet module.

##Module Description

This module allows you to mount and dismount ISOs on windows server.

This module use PowerShell v4.0 commands and should work on Windows 8/8.1, Windows Server 2012/2012R2

Tested on windows server 2012 R2

##Last Fix/Update
V 0.0.1 :
 - Create module
 - Mount/Umount ISO by path
 - Save mounting ISO information in XML file. Better for ulterior use

###Setup Requirements
Depends on the following modules:
['joshcooper/powershell', '>=0.0.6'](https://forge.puppetlabs.com/joshcooper/powershell),
['puppetlabs/stdlib', '>= 4.2.1'](https://forge.puppetlabs.com/puppetlabs/stdlib)

##Usage

Resource: windows_isos
```
	windows_isos{'SQLServer':
	  ensure   => present,
	  isopath  => 'C:\\Users\\Administrator\\Desktop\\SQLServer2012SP1-FullSlipstream-ENU-x64.iso',
	}
```

Parameters:
```
	$ensure               # Present or absent -> mount/unmount ISO. Default to present
	$isopath              # Absolute Iso path. Mandatory
	$xmlpath              # Where to save the file. Default set to C:\\isos.xml. The path must be absolute and contain the file name
```

License
-------
Apache License, Version 2.0

Contact
-------
Jerome RIVIERE

Support
-------

Please log tickets and issues at [GitHub site](https://github.com/ninja-2/windows_isos/issues)
