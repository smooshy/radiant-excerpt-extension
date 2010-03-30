require File.dirname(__FILE__) + '/../spec_helper'

describe 'Excerpt' do 
  dataset :pages
  
  describe '<r:excerpt>' do
    it 'should render simple text without HTML tags' do
      tag = '<r:excerpt length="7">simpletest</r:excerpt>'
      expected = %{simp...}
      pages(:home).should render(tag).as(expected)
    end
    
    it "should return all letters if length is larger than the provided text" do
      tag = '<r:excerpt length="10">four</r:excerpt>'
      expected = %{four}
      pages(:home).should render(tag).as(expected)
    end
    
    it "should strip html tags if the strip_html attribute is set" do
      tag = '<r:excerpt length="7" strip_html="true"><p>simpletest</p></r:excerpt>'
      expected = %{simp...}
      pages(:home).should render(tag).as(expected)
    end
    
    it "should close one opened html tags" do
      tag = '<r:excerpt length="10"><p>This is a really long test to test the closing of a paragraph</p></r:excerpt>'
      expected = %{<p>This...</p>}
      pages(:home).should render(tag).as(expected)
    end
    
    it "should remove tags that are not oktags" do
      tag = '<r:excerpt length="300"><div><p><strong>Lorem</strong></p></div> <b><div><span><i>ipsum</i> dolor</span> <a href="#"><em>sit</em> <span class="one">amet</span></a>,</b></div> <blockquote id="ahah">consectetur<br>one wo</blockquote><head></head><body> adipiscing</body> elit<br/>. <article>Cras nibh</article> sapien, aliquam ac fringilla vitae, <embed>dignissim in</embed> velit. Duis tellus metus, posuere vel sodales at, tempor fringilla tellus. Nullam sem diam, malesuada quis mattis et, ullamcorper et metus. Aliquam at turpis ac tortor mollis dictum. Sed ligula sem, dapibus et pulvinar quis, egestas eu libero. Integer viverra eros vel nisl bibendum in varius turpis convallis. Vivamus ac enim mi, id ultrices metus. Aenean tellus dui, varius in congue non, aliquam quis nunc. Duis at cursus nisl. Vestibulum urna eros, congue ut luctus ut, hendrerit ut massa. Cras aliquam tincidunt elit quis ornare. Cras id augue arcu, sit amet malesuada neque. Duis aliquam volutpat tristique. Suspendisse metus nunc, varius eu eleifend vitae, consectetur vitae est.</div></r:excerpt>'
      expected = %{<p><strong>Lorem</strong></p> <b><i>ipsum</i> dolor <a href="#"><em>sit</em> amet</a>,</b> consectetur<br>one wo adipiscing elit<br />. Cras nibh sapien, aliq...}
      pages(:home).should render(tag).as(expected)
    end
    
    it "should use the tags provided if the ok_tags attribute is set" do
      tag = '<r:excerpt length="20" ok_tags="p, div"><div><p>one <a href="#">two</a> <b><i>three</i></b></div></r:excerpt>'
      expected = %{<div><p>one ...</p></div>}
      pages(:home).should render(tag).as(expected)
    end

    it "should use the tags and attributes provided if the ok_tags attribute is set" do
      tag = '<r:excerpt length="40" ok_tags="p class, div"><div><p class="haha">one two <b><i>three</i></b></p></div></r:excerpt>'
      expected = %{<div><p class="haha">one two th...</p></div>}
      pages(:home).should render(tag).as(expected)
    end
    
    it "should default to a length of 200 if length attribute is not used" do
      tag = '<r:excerpt>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce et est et mi viverra vestibulum. Nullam sapien augue, hendrerit eget tristique ut, lacinia a leo. In tristique lacinia venenatis posuere. Lorem ipsum dolor sit amet, consectetur cras amet.</r:excerpt>'
      expected = %{Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce et est et mi viverra vestibulum. Nullam sapien augue, hendrerit eget tristique ut, lacinia a leo. In tristique lacinia venenatis posue...}
      pages(:home).should render(tag).as(expected)
    end
  end
end