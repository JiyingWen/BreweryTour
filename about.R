tabPanel("About",
         h3("Your Guide to Craft Beer in Vancouver"),
	HTML(
	'<p style="text-align:justify">Metro Vancouver is a craft beer haven. This R Shiny web application presents 31 craft brewers in the Vancouver area to wet your whistle.
	It also allows the user to customize brewery tours according to their preference. The data for the beer and rating are scraped from <a href="https://www.ratebeer.com/">RateBeer.com</a>.</p>'),
		
	HTML('
	<strong>Author</strong>
	<p>Jiying Wen<br/>
	Statistician | Data Scientist<br/>
	<a href="https://github.com/JiyingWen" target="_blank">Github</a> | 
	<a href="https://www.linkedin.com/in/jiyingwen/" target="_blank">Linkedin</a> <br/>
	</p>'),
	
	fluidRow(
		column(4,
			HTML('<strong>References</strong>
			<p></p><ul>
				<li><a href="http://www.r-project.org/" target="_blank">Coded in R</a></li>
				<li><a href="http://www.rstudio.com/shiny/" target="_blank">Built with the Shiny package</a></li>
				<li>Additional supporting R packages</li>
				<ul>
                    <li><a href="http://rstudio.github.io/shinythemes/" target="_blank">shinythemes</a></li>
                    <li><a href="https://github.com/ebailey78/shinyBS" target="_blank">shinyBS</a></li>
                    <li><a href="http://rstudio.github.io/leaflet/" target="_blank">leaflet</a></li>
				</ul>
				<li>Source code on <a href="https://github.com/JiyingWen" target="_blank">GitHub</a></li>
			</ul>')
		)
	),
	value="about"
)
