require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Persona do
  before(:each) do
    
  end

  it "should know JAN" do
   Persona.called("jan").name.should == "Jan"
   Persona.called("Jan").name.should == "Jan"
   Persona.called("Jan").image.should == "/personas/jan.jpg"
  end

  it "should be able to describe marieke" do
    
    Persona.called("Marieke").short_description.length.should > 0
    Persona.called("Marieke").long_description.split($/).length.should == 3
  end

  it "should be able to find personas in a description" do
    personas = Persona.mentioned_in("this session is intended for philippe, georges (and maybe also Vincent)")
    personas.length.should == 3
    personas[0].name.should == "Philippe"
    personas[1].name.should == "Georges"
    personas[2].name.should == "Vincent"
  end

 
end

