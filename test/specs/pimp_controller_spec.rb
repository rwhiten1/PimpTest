require "spec"
require File.dirname(__FILE__) + "/../../lib/pimp_controller"

include Controllers
describe "Pimp Controller" do

  before(:each) do
    @html_doc = <<-DOCUMENT
<html>
    <head>
        <title>Pimp your tests</title>
        <style type="text/css">
            body {
                padding: 0;
                margin: 0;
                background: #FFF;
                font: 100.01% / 1.3 Verdana, Arial, sans-serif;
            }


            h1 {
                font: lighter 200% "Trebuchet MS", Arial sans-serif;
                color: #208BE1
            }

            h1, p {
                margin: 0;
                padding: 10px 20px
            }

            div#menu {
                float: left;
                width: 100%;
                padding-top: 120px;
                background: #006666;
                /*border-width: 0px 0px 0px 2px;
                border-style: solid;
                border-color: #909090;*/
            }

            /* CSS for the navigation */
            ul#nav, ul#nav li {
                list-style-type: none;
                margin: 0;
                padding: 0
            }

            ul#nav {

                margin-left: 200px;
                width: 650px
            }

            ul#nav li {
                float: left;
                margin-right: 3px;
                text-align: center
            }

            ul#nav a {
                float: left;
                width: 7em;
                padding: 5px 0;
                background: #E7F1F8;
                text-decoration: none;
                color: #666
            }

            ul#nav a:hover {
                background: #FFA826;
                color: #FFF
            }

            ul#nav li.activelink a, ul#nav li.activelink a:hover {
                background: #FFF;
                color: #003
            }


</style>
       <script type="text/javascript" src="scripts/niftycube.js"></script>
       <link rel="StyleSheet" href="stylesheets/active_sheet.css" type="text/css" media="screen"/>
      <script type="text/javascript">
            window.onload=function(){
            //Nifty("div#list","big");
            Nifty("ul#nav a","small transparent top");
            //Nifty("ul#test_books a","normal all")
            }
      </script>
    </head>

<body>
  <div id="header">
  <h2 id="title" class="white-text">Pimp Those Tests!</h2>
    <div id="menu">
        <ul id="nav">
            <li><a href="#">Run All</a></li>
            <li><a href="#">Config</a></li>
            <li><a href="#">Variables</a></li>
            <li><a href="#">Properties</a></li>
            <li><a href="#">Add</a></li>
        </ul>
    </div>
    <div id="breadcrumb">
        <ul>
          <li><a href="/HomePage">HomePage</a></li>
          <li>&#187;<a href="/HomePage/HelloTest">HelloTest</a></li>
      </ul>
    </div>
  </div>
    <div class="left">
        <h4>Fixture Repository</h4>
        <ul class="fixtures">
            <li><a href="#">Fixture 1</a></li>
            <li><a href="#">Fixture 2</a></li>
            <li><a href="#">Fixture 3</a></li>
            <li><a href="#">Fixture 4</a></li>
        </ul>
    </div>
    <div class="content">
<div class="text" id="text_1">
<p>This is some text that will go on the page.  It will be<br/> stuck inside a paragraph tag.  All newlines will be replaced<br/> with &lt;br&gt; tags.<br/></p>
</div>
<br/>
<div class="table" id="table_1">
<a class="table-button"><img  src="images/play_button_small.png" alt="run tests"/></a>
<a class="table-button"><img src="images/edit_small.png" alt="edit table"/></a>
<p>Fixture Class: <strong>mock_fixture</strong></p>
<table cellpadding="0" cellspacing="0">
<thead>
<tr>
<td>var1</td>
<td>var2</td>
<td>var3</td>
<td>var4</td>
<td>run_this_method</td>
</tr>
</thead>
<tr>
<td>data</td>
<td>to</td>
<td>put</td>
<td>in test</td>
<td>expected result</td>
</tr>
</table>

</div>

    </div>
</body>

</html>
    DOCUMENT

    @trail = <<TRAIL
<ul>
          <li><a href="/HomePage">HomePage</a></li>
          <li>&#187;<a href="/HomePage/HelloTest">HelloTest</a></li>
</ul>
TRAIL


    @fix_html = <<FIXTURES
<h4>Fixture Repository</h4>
<ul class="fixtures">
    <li>
      <a href="#" id="fake_fixture" onClick="javascript:displayFixtureList('fake_fixture_list')">fake_fixture&nbsp;&nbsp;&nbsp;&lt;</a>
      <ul class="nested" id="fake_fixture_list">
        <li name="fake_method_one">fake_method_one()</li>
        <li name="fake_method_two">fake_method_two()</li>
      </ul>
    </li>
    <li>
      <a href="#" id="ftp_send_fixture" onClick="javascript:displayFixtureList('ftp_send_fixture_list')">ftp_send_fixture&nbsp;&nbsp;&nbsp;&lt;</a>
      <ul class="nested" id="ftp_send_fixture_list">
        <li name="send_edi_data">send_edi_data()</li>
        <li name="send_text_data">send_text_data()</li>
      </ul>
    </li>
</ul>
FIXTURES
    @trail.gsub!(/\s+/,"")
    @rack_env ={"SERVER_NAME"=>"127.0.0.1", "async.callback"=>"#", "rack.url_scheme"=>"http", "HTTP_ACCEPT_ENCODING"=>"gzip,deflate,sdch", "HTTP_USER_AGENT"=>"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/532.0 (KHTML, like Gecko) Chrome/3.0.195.32 Safari/532.0", "PATH_INFO"=>"/some/resource/to/grab", "rack.run_once"=>false, "rack.input"=>"#", "SCRIPT_NAME"=>"", "SERVER_PROTOCOL"=>"HTTP/1.1", "HTTP_ACCEPT_LANGUAGE"=>"en-US,en;q=0.8", "HTTP_CACHE_CONTROL"=>"max-age=0", "HTTP_HOST"=>"127.0.0.1:8080", "rack.errors"=>"#", "REMOTE_ADDR"=>"127.0.0.1", "REQUEST_PATH"=>"/some/resource/to/grab", "SERVER_SOFTWARE"=>"thin 1.2.4 codename Flaming Astroboy", "HTTP_ACCEPT_CHARSET"=>"ISO-8859-1,utf-8;q=0.7,*;q=0.3", "HTTP_VERSION"=>"HTTP/1.1", "rack.multithread"=>false, "rack.version"=>[1, 0], "async.close"=>"#", "REQUEST_URI"=>"/some/resource/to/grab", "rack.multiprocess"=>false, "SERVER_PORT"=>"8080", "QUERY_STRING"=>"", "GATEWAY_INTERFACE"=>"CGI/1.2", "HTTP_ACCEPT"=>"application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5", "HTTP_CONNECTION"=>"keep-alive", "REQUEST_METHOD"=>"GET"}
    @fix_html.gsub!(/\s+/,"")

  end



  it "should return an html document by combining a page and a layout" do
    controller = PimpController.new() #not sure yet if there needs to be anything initialized\
    #the render function will expect a relative URL
    html = controller.render("HomePage/HelloTest")
    html.should == @html_doc

  end

  it "should respond to a breadcrumb method and render a template" do
    controller = PimpController.new()
    controller.location = "HomePage/HelloTest"
    brd = controller.breadcrumb() #the breadcrumbing is based on the current page URL
    brd.gsub!(/\s+/,"")
    brd.should == @trail

  end

  it "should respond to a fixtures method and render a template" do
    controller = PimpController.new()
    controller.location = "HomePage"
    fix = controller.fixtures() #it really doesn't matter where you are in the app, all fixtures are shown
    fix.gsub!(/\s+/,"")
    fix.should == @fix_html
  end

end