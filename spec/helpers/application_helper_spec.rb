require 'spec_helper'

describe ApplicationHelper do
  include ApplicationHelper

  def current_account
    'some_account'
  end

  def link_to(what, url_options)
    "link to #{what} with #{url_options.inspect}"
  end

  describe "guarded_link_to" do

    let(:link_params) {{:controller => 'some_controller', :action => 'some_action'}} 
    it "authorizes action with action guard" do
      ActionGuard.should_receive(:authorized?).with(current_account, link_params.stringify_keys)
      guarded_link_to 'link_text', link_params
    end
    it "renders the link if authorized" do
      ActionGuard.should_receive(:authorized?).and_return true
      guarded_link_to('link_text', link_params).should == link_to('link_text', link_params)
    end
    it "renders nothing if not authorized" do
      ActionGuard.should_receive(:authorized?).and_return false
      guarded_link_to('link_text', link_params).should == ''
    end
  
  end

  describe "wikinize" do
    it "nil returns empty string"  do
      wikinize(nil).should == ""
    end

    it "empty string returns empty string"  do
      wikinize("").should == ""
    end

    it "simple string is wrapped in <p>"  do
      wikinize("simple string").should == "<p>simple string</p>"
    end

    it "new-line returns <br/>"  do
      wikinize("string\nwith newline").should == "<p>string\n<br />with newline</p>"
    end

    it "2 new-lines return new <p>"  do
      wikinize("string\n\nwith newline").should == "<p>string</p><p>with newline</p>"
    end

    it "*word* returns bold"  do
      wikinize("simple string with *bold* word").should == "<p>simple string with <b>bold</b> word</p>"
    end

    it "*bold not closed returns *"  do
      wikinize("simple string with *bold-not-closed word").should ==
        "<p>simple string with *bold-not-closed word</p>"
    end

    it "*bold not closed within this line returns *"  do
      wikinize("simple string with *bold-not-closed on this line\n *word").should ==
        "<p>simple string with *bold-not-closed on this line\n<br /> *word</p>"
    end

    it "more than 1 bold word"  do
      wikinize("can we have *more* than *only one* bold word?").should ==
        "<p>can we have <b>more</b> than <b>only one</b> bold word?</p>"
    end

    it "bold word at beginning of line"  do
      wikinize("*this* is a bold word?").should ==
        "<p><b>this</b> is a bold word?</p>"
    end

    it "bold word at end of line"  do
      wikinize("this is a bold *word*").should ==
        "<p>this is a bold <b>word</b></p>"
    end

    it "bold word between special chars"  do
      wikinize("this is a bold (*word*)").should ==
        "<p>this is a bold (<b>word</b>)</p>"
    end

    it "_word_ returns italic"  do
      wikinize("simple string with _italic_ word").should ==
        "<p>simple string with <i>italic</i> word</p>"
    end

    it "more than 1 italic word"  do
      wikinize("can we have _more_ than _only one_ italic word?").should ==
        "<p>can we have <i>more</i> than <i>only one</i> italic word?</p>"
    end

    it "italic word at beginning of line"  do
      wikinize("_this_ is a italic word?").should ==
        "<p><i>this</i> is a italic word?</p>"
    end

    it "italic word at end of line"  do
      wikinize("this is a italic _word_").should ==
        "<p>this is a italic <i>word</i></p>"
    end

    it "italic word between special chars"  do
      wikinize("this is a italic (_word_)").should ==
        "<p>this is a italic (<i>word</i>)</p>"
    end

  end

  describe "wikinize links" do
    it "link is displayed in a clickable way"  do
      wikinize("klik hier: http://www.xpday.be").should ==
        "<p>klik hier: <a href=\"http://www.xpday.be\">http://www.xpday.be</a></p>"
    end

    it "link in beginning of line is displayed in a clickable way"  do
      wikinize("http://www.xpday.be").should ==
        "<p><a href=\"http://www.xpday.be\">http://www.xpday.be</a></p>"
    end

    it "link ending by blank is displayed in a clickable way"  do
      wikinize("klik hier: http://www.xpday.be ").should ==
        "<p>klik hier: <a href=\"http://www.xpday.be\">http://www.xpday.be</a> </p>"
    end

    it "link ending by special char is displayed in a clickable way"  do
      wikinize("xpday (http://www.xpday.be) ").should ==
        "<p>xpday (<a href=\"http://www.xpday.be\">http://www.xpday.be</a>) </p>"
    end

    it "link containing / is displayed in a clickable way"  do
      wikinize("xpday (http://www.xpday.be/frontpage ").should ==
        "<p>xpday (<a href=\"http://www.xpday.be/frontpage\">http://www.xpday.be/frontpage</a> </p>"
    end

    it "link with name is displayed in a clickable way"  do
      wikinize("bla [[http://www.xpday.be HOI]]").should ==
        "<p>bla <a href=\"http://www.xpday.be\">HOI</a></p>"
    end

    it "two links on one line are displayed in a clickable way"  do
      wikinize("bla [[http://www.xpday.be HOI]] and [[http://www.atbru.be Agile Tour Brussels]] also").should ==
        "<p>bla <a href=\"http://www.xpday.be\">HOI</a> and <a href=\"http://www.atbru.be\">Agile Tour Brussels</a> also</p>"
    end
    
    it "links in a bulleted list are displayed in a clickable way"  do
      wikinize("* [[http://www.xpday.be HOI]] and\n* [[http://www.atbru.be Agile Tour Brussels]] also").should ==
        "<p><ul><li><a href=\"http://www.xpday.be\">HOI</a> and</li><li><a href=\"http://www.atbru.be\">Agile Tour Brussels</a> also</li></ul></p>"
    end

    it "accepts secure https URLs" do
      wikinize("klik hier: https://github.com/rwestgeest/propile").should ==
        "<p>klik hier: <a href=\"https://github.com/rwestgeest/propile\">https://github.com/rwestgeest/propile</a></p>"
    end

    it "accepts named secure https URLs" do
      wikinize("klik hier: [[https://github.com/rwestgeest/propile Our project]]").should ==
        "<p>klik hier: <a href=\"https://github.com/rwestgeest/propile\">Our project</a></p>"
    end

    it "accepts URLs with an underscore" do
      wikinize("klik hier: http://github.com/rwestgeest/propile_Our").should ==
        "<p>klik hier: <a href=\"http://github.com/rwestgeest/propile_Our\">http://github.com/rwestgeest/propile_Our</a></p>"
    end

    it "accepts URLs with 2 underscores" do
      wikinize("klik hier: http://github.com/rwestgeest/propile_Our_Project").should ==
        "<p>klik hier: <a href=\"http://github.com/rwestgeest/propile_Our_Project\">http://github.com/rwestgeest/propile_Our_Project</a></p>"
    end

    it "accepts URLs with an underscore in braces" do
      wikinize("klik hier: [[http://github.com/rwestgeest/propile_Our project]]").should ==
        "<p>klik hier: <a href=\"http://github.com/rwestgeest/propile_Our\">project</a></p>"
    end

    it "accepts URLs with 2 underscores in braces" do
      wikinize("klik hier: [[http://github_2.com/rwestgeest/propile_Our project]]").should ==
        "<p>klik hier: <a href=\"http://github_2.com/rwestgeest/propile_Our\">project</a></p>"
    end
  end

  describe "wikinize list" do
    it "* starts ul"  do
      wikinize("* een\n* twee").should ==
        "<p><ul><li>een</li><li>twee</li></ul></p>"
    end

    it "ul with string before" do
      wikinize("voila:\n* een\n* twee").should ==
        "<p>voila:\n<br /><ul><li>een</li><li>twee</li></ul></p>"
    end

    it "ul with string after" do
      wikinize("* een\n* twee\nen nog iets").should ==
        "<p><ul><li>een</li><li>twee</li></ul>\n<br />en nog iets</p>"
    end

    it "formats 2 urls in a string correctly"  do
      wikinize("* een\n* twee\nblabla\n* nog \n* en nog").should ==
        "<p><ul><li>een</li><li>twee</li></ul>\n<br />blabla\n<br /><ul><li>nog </li><li>en nog</li></ul></p>"
    end

    it "cleans unprintable characters" do
      dirty = "Magic board on the wall, \x0Bwho is the fairest of them all?"
     
      (w dirty).should == "Magic board on the wall, who is the fairest of them all?"
      (wikinize dirty).should == "<p>Magic board on the wall, who is the fairest of them all?</p>"
    end

  end

  describe "session_presenter_names_no_presenters_EMPTY" do
    let(:link_params) {{:controller => 'some_controller', :action => 'some_action'}} 
    it "session with 0 presenter" do
      session_presenter_names( Session.new ).should == ""
    end
  end

  describe "session_presenter_names" do
    let!(:session) { Session.new } 
    it "empty session returns emtpy names" do
      session_presenter_names(session).should == ""
    end
    context "first presenter email set" do
      let!(:session) { FactoryGirl.build(:session, :first_presenter_email => "presenter_1@example.com", :second_presenter_email => '')}
      it "returns email" do
        session.first_presenter.email.should == "presenter_1@example.com"
	      session_presenter_names(session).should match "link to presenter_1@example.com with #.Presenter .*"
      end
    end
    context "first and second presenter email set" do
      let!(:session) { FactoryGirl.build(:session, :first_presenter_email => "presenter_1@example.com", :second_presenter_email => 'presenter_2@example.com')}
      it "returns 2 emails" do
        session.first_presenter.email.should == "presenter_1@example.com"
        session.second_presenter.email.should == "presenter_2@example.com"
        session_presenter_names(session).should match "link to presenter_1@example.com with #.Presenter.* & link to presenter_2@example.com with #.Presenter.*"
      end
    end
    context "first presenter email and name set, no second presenter" do
      let!(:session) { FactoryGirl.build(:session, :first_presenter_email => "presenter_1@example.com", :second_presenter_email => '')}
      it "returns name" do
        session.first_presenter.name = "Petra The Firstpresenter"
        session_presenter_names(session).should match "link to Petra The Firstpresenter with #.Presenter.*"
      end
    end
    context "first presenter email and name set, second presenter only email" do
      let!(:session) { FactoryGirl.build(:session, :first_presenter_email => "presenter_1@example.com", :second_presenter_email => 'presenter_2@example.com')}
      it "returns name and email" do
        session.first_presenter.name = "Petra The Firstpresenter"
        session_presenter_names(session).should match "link to Petra The Firstpresenter with #.Presenter.* & link to presenter_2@example.com with #.Presenter.*"
      end
    end
    context "both presenters name set" do
      let!(:session) { FactoryGirl.build(:session, :first_presenter_email => "presenter_1@example.com", :second_presenter_email => 'presenter_2@example.com')}
      it "returns 2 names" do
        session.first_presenter.name = "Petra The Firstpresenter"
        session.second_presenter.name = "Peter The Secondpresenter"
        session_presenter_names(session).should match "link to Petra The Firstpresenter with #.Presenter.* & link to Peter The Secondpresenter with #.Presenter.*"
      end
    end
  end

  describe "collapse_button" do 
    context "default initially collapsed" do
      it "returns a string to create a button to use with a div with a unique id" do
        collapse_button("test").should == %q/<input class="collapsebutton" type="button" id="testButton" value='+' onclick="showHide('test')" >/
      end
    end
    context "default initlially no collapsed" do
      it "returns a string to create a button to use with a div with a unique id" do
        collapse_button("test", false).should == %q/<input class="collapsebutton" type="button" id="testButton" value='-' onclick="showHide('test')" >/
      end
    end
  end

end
