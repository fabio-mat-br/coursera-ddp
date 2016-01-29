library(ggplot2) 
library(Cairo) 
library(shiny)
library("shapefiles")
library("rgl")
if(!file.exists("data/BR_Localidades_2010_v1.dbf")){
  download.file("ftp://geoftp.ibge.gov.br/organizacao_territorial/localidades/Shapefile_SHP/BR_Localidades_2010_v1.dbf", destfile = "BR_Localidades_2010_v1.dbf")
}
dbf <- read.dbf("data/BR_Localidades_2010_v1.dbf", TRUE)
data <- dbf$dbf
rm(dbf)
df_localidades <- data.frame(data$LONG, data$LAT, data$ALT, data$NM_MUNICIP, data$NM_UF)
rm(data)
names(df_localidades) <- c("lon", "lat", "alt", "city", "uf")
df_localidades_selected_g <- df_localidades
mi_la <- min(df_localidades$lat)
ma_la <- max(df_localidades$lat)

mi_lo <- min(df_localidades$lon)
ma_lo <- max(df_localidades$lon)

mi_al <- min(df_localidades$alt, na.rm = TRUE)
ma_al <- max(df_localidades$alt, na.rm = TRUE)

l <- c(lapply(unique(sort(df_localidades$uf)), as.character))
names(l) <- lapply(unique(sort(df_localidades$uf)), as.character)
luf <- c("SELECT" = "SELECT", l)
shinyServer(function(input, output, session) {
  output$brazilPlot <- renderPlot({
    df_localidades_selected <- df_localidades[
      which(
        df_localidades$lat > input$sldLat[1] & df_localidades$lat < input$sldLat[2] &
        df_localidades$lon > input$sldLon[1] & df_localidades$lon < input$sldLon[2] &
        df_localidades$alt > input$sldAlt[1] & df_localidades$alt < input$sldAlt[2]
      ), ]
    if(input$cmbUF != "SELECT"){
      df_localidades_selected <- df_localidades_selected[which(
        df_localidades_selected$uf == input$cmbUF), ]
    }
    if(input$txtCity != ""){
      df_localidades_selected <- df_localidades_selected[
        grep(pattern = toupper(input$txtCity), x = df_localidades_selected$city), ]
      print(df_localidades_selected)
    }
    df_localidades_selected_g <<- df_localidades_selected
    print(dim(df_localidades_selected))
    p <- ggplot(df_localidades_selected, aes(lon, lat))
    p + geom_point(aes(colour = 1 + alt, width=1, height=1)) + 
      xlim(c(-75, -30)) + 
      ylim(c(-35, 10)) + 
      scale_x_continuous(name="Latitude") +
      scale_y_continuous(name="Longitude") +
      scale_colour_gradient("Altitude", low="#006633", high="#FFCC00") 

  })
  updateSelectInput(session, "cmbUF", choices = luf)
  output$hover_info <- renderTable({
    if(!is.null(input$plot_hover)){
      hover = input$plot_hover
      dist = sqrt((hover$x - df_localidades_selected_g$lon)^2 + (hover$y-df_localidades_selected_g$lat)^2)
      if(min(dist) < .2){
        dfn <- df_localidades_selected_g[which.min(dist), ]
        names(dfn) <- c("Longitude", "Latitude", "Altitude", "City Name", "State")
        data.frame(dfn)
      }
    }}) 
  output$dt_tbl <- DT::renderDataTable({
    DT::datatable(df_localidades_selected_g, options = list(lengthMenu = c(5, 10, 20, 50, 150), pageLength = 5, class="foo"))
  })  
})