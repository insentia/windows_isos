# == Class: windows_isos
#
# This module allows you to mount and dismount ISOs on windows server.
#
# This module use PowerShell v4.0 commands and should work on Windows 8.1, Windows Server 2012 R2
#
# Tested on windows server 2012 R2
#
# === Parameters
#
#	$ensure               # Present or absent -> mount/unmount ISO. Default to present
#	$isopath              # Absolute Iso path. Mandatory
#	$xmlpath              # Where to save the file. Default set to C:\\isos.xml. The path must be absolute and contain the file name
#
# === Examples
#
#	windows_isos{'SQLServer':
#	  ensure   => present,
#	  isopath  => 'C:\\Users\\Administrator\\Desktop\\SQLServer2012SP1-FullSlipstream-ENU-x64.iso',
#	}
#
# === Authors
#
# Jerome RIVIERE (www.jerome-riviere.re)
#
# === Copyright
#
# Copyright 2014 Jerome RIVIERE, unless otherwise noted.
#
define windows_isos (
  $ensure  = present,
  $isopath = '',
  $xmlpath = 'C:\\isos.xml',
) {
  if (!defined(File[$xmlpath])){
    file{"$xmlpath":
      content => template('windows_isos/xml.erb'),
      replace => no,
    }
  }
  validate_re($ensure, '^(present|absent)$', 'valid values for mount are \'present\' or \'absent\'')

  if(!empty($isopath)){
    if ($ensure == 'present'){
     exec{"Mount ${name}":
        provider => powershell,
        command  => "Mount-DiskImage -ImagePath '${isopath}'",
        onlyif   => "\$drive = ((Get-DiskImage -ImagePath '${isopath}') | Get-Volume);;if((test-path '${isopath}') -and (\$drive -eq \$null)){}else{exit 1}",
      }
      exec{"Modify XML - ${name}":
        provider => powershell,
        command  => "\$drive = ((Get-DiskImage -ImagePath '${isopath}') | Get-Volume);[xml]\$xml = New-Object system.Xml.XmlDocument;[xml]\$xml = Get-Content '${xmlpath}';foreach(\$iso in \$xml.configuration.isos.iso){if(\$iso.ImagePath -eq '${isopath}'){\$iso.DriveLetter = \$drive.DriveLetter.toString();\$iso.ISOLabel = \$drive.FileSystemLabel.toString();\$xml.save('${xmlpath}');}}",
        onlyif   => "if(test-path ${isopath}){[xml]\$xml = New-Object system.Xml.XmlDocument;[xml]\$xml = Get-Content '${xmlpath}';\$exist=\$false;\$modify=\$false;foreach(\$iso in \$xml.configuration.isos.iso){\$drive = ((Get-DiskImage -ImagePath '${isopath}') | Get-Volume);if(\$iso.ImagePath -eq '${isopath}'){if((\$drive.DriveLetter.toString() -ne \$iso.DriveLetter) -or (\$drive.FileSystemLabel -ne \$iso.ISOLabel)){\$modify = \$true;}}};if(\$modify){}else{exit 1}}else{exit 1}",
      }
      exec{"Add to XML - ${name}":
        provider => powershell,
        command  => "\$drive = ((Get-DiskImage -ImagePath '${isopath}') | Get-Volume);[xml]\$xml = New-Object system.Xml.XmlDocument;[xml]\$xml = Get-Content '${xmlpath}';\$subel = \$xml.CreateElement('iso');(\$xml.configuration.GetElementsByTagName('isos')).AppendChild(\$subel);\$letter = \$xml.CreateAttribute('DriveLetter');\$letter.Value = \$drive.driveletter;\$label = \$xml.CreateAttribute('ISOLabel');\$label.Value = \$drive.FileSystemLabel;\$imagepath = \$xml.CreateAttribute('ImagePath');\$imagepath.Value = '${isopath}';\$subel.Attributes.Append(\$letter);\$subel.Attributes.Append(\$label);\$subel.Attributes.Append(\$imagepath);\$xml.save('${xmlpath}');",
        onlyif   => "if(test-path ${isopath}){[xml]\$xml = New-Object system.Xml.XmlDocument;[xml]\$xml = Get-Content '${xmlpath}';\$exist=\$false;foreach(\$iso in \$xml.configuration.isos.iso){if(\$iso.ImagePath -eq '${isopath}'){\$exist=\$true}}if(\$exist -eq \$True){exit 1}}{exit 1}",
      }
    }else{
      exec{"Dismount ${name}":
        provider => powershell,
        command  => "Dismount-DiskImage -ImagePath '${isopath}'",
        onlyif   => "\$drive = ((Get-DiskImage -ImagePath '${isopath}') | Get-Volume);;if((test-path '${isopath}') -and (\$drive -ne \$null)){}else{exit 1}",
      }
      exec { "Remove from XML - ${name}":
        command     => "[xml]\$xml = New-Object system.Xml.XmlDocument;[xml]\$xml = Get-Content '${xmlpath}';foreach(\$iso in \$xml.configuration.isos.iso){if(\$iso.ImagePath -eq '${isopath}'){\$iso.ParentNode.RemoveChild(\$iso);\$xml.save('${xmlpath}');}}",
        provider    => powershell,
        onlyif      => "if(test-path ${isopath}){[xml]\$xml = New-Object system.Xml.XmlDocument;[xml]\$xml = Get-Content '${xmlpath}';\$exist=\$false;foreach(\$iso in \$xml.configuration.isos.iso){if(\$iso.ImagePath -eq '${isopath}'){\$exist=\$true}}if(\$exist -eq \$False){exit 1}{exit 1}",
      }
    }
  }else{
    warning("The path : '$isopath', for isopath parameter doesn\'t exist or is empty.")
  }
}