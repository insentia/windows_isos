# file_exists.rb
# Simple function that check if a file exist or not
#
# Created by Jerome RIVIERE (www.jerome-riviere.re) (https://github.com/ninja-2)
require "rexml/document"
require "puppet"

module Puppet::Parser::Functions
  newfunction(:get_drive_letter, :type => :rvalue, :doc => <<-EOS
return a drive letter from xml
    EOS
  ) do |args|
    raise(Puppet::ParseError, "get_drive_letter(): Wrong number of arguments " +
      "given (#{args.size} for 2)") if args.size != 2
	if (File.size?(args[0]) != nil)
        doc = REXML::Document.new File.new("#{args[0]}")
        root = doc.root
        isos = root.elements['isos']

        isos.elements.map do | iso |
          imagepath = iso.attributes["ImagePath"]
          if (imagepath == args[1])
            driveletter = iso.attributes["DriveLetter"]
            return driveletter  
          end
        end
    end
  end
end