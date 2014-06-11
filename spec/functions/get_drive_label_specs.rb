#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the get_drive_label function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }
  it "should exist" do
    Puppet::Parser::Functions.function("get_drive_label").should == "function_get_drive_label"
  end

  it "should raise a ParseError if there is less than 2 arguments" do
    lambda { scope.function_get_drive_label([]) }.should( raise_error(Puppet::ParseError))
  end
end
