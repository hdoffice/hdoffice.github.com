require ["mustache","jquery","bootstrap-affix","bootstrap-dropdown","bootstrap-scrollspy"],(Mustache)->
	$(document).ready ()->
		navbar = $(".F-main-navbar-")
		navbar.css("height",navbar.height())
		navbar.children(".F-main-navbar").affix offset:top:navbar.offset().top
		sstpl = '''
			<div class="nav">
				<div class="f-block">
					<ul>
					{{#items}}
						<li>
							<a href="#{{id}}">{{content}}</a>
						</li>
					{{/items}}
					</ul>
				</div>
			</div>
			'''
		ssjson = items:[]
		$("article [id]").each (i,item)->
			ssjson.items.push id:$(item).attr("id"),content:$(item).text()
		scrollspybar = $("#test_bar")
		if scrollspybar.length > 0 
			scrollspybar.html Mustache.render sstpl,ssjson
			scrollspybar.children(".nav").css("padding-top",navbar.height());
			scrollspybar.css("margin-top","-#{navbar.height()}");
			ssheight = scrollspybar.height()+10
			scrollspybar.css("height",ssheight)
			$('body').scrollspy $.extend {},$('body').data(),offset:ssheight
			$("#test_bar li > a").click (event)->
				event.preventDefault()
				$('body').scrollTop $("##{$(this).attr('href').replace(/^#/,'')}").offset().top - ssheight
			scrollspybar.children(".nav").affix offset:top:scrollspybar.offset().top

