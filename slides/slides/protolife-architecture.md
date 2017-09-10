##  ProtoLife architecture

<img src="resources/server-client-methods1.png" alt="Shiny Server message protocol" style="border: none; width: 600px;"/>

<img src="resources/RStudio-Logo-Blue-Gradient.png" alt="RStudio" style="margin-right: 20px; border: none; height: 100px;"/>
<img src="resources/handsontable.png" alt="Handsontable" style="margin-right: 20px; border: none; height: 100px;"/>

note:
    Elm front-end.
    The back-end is a custom-built statistics engine developed in the R language.
    We expose endpoints via a "freemium" web platform named Shiny Server, developed by RStudio.
    Communication between front-end and back-end is through JavaScript (either ports or native code), and
        then via a JavaScript websocket interface that the Shiny Server exposes.
    Our UI also makes abundant use of a Polymer web component that wraps another "freemium" product,
        an interactive JavaScript spreadsheet library called Handsontable.

    Image credits:

        * RStudio logo: https://www.rstudio.com/wp-content/uploads/2014/07/RStudio-Logo-Blue-Gradient.png
        * Handsontable logo: https://avatars0.githubusercontent.com/u/8068250
        * Shiny Server diagram: https://ryouready.files.wordpress.com/2013/11/server-client-methods1.png
