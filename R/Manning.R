fmaManning <- function(ml, runName, dataDir, canProvs, bufferDist, asStudyArea = FALSE) {
  ab <- canProvs[canProvs$NAME_1 == "Alberta", ]
  manning <- extractFMA(ml, "Manning")
  shapefile(manning, filename = file.path(dataDir, "Manning_full.shp"), overwrite = TRUE)

  ## reportingPolygons
  manning.ansr <- postProcess(ml[["Alberta Natural Subregions"]],
                              studyArea = manning, useSAcrs = TRUE,
                              filename2 = file.path(dataDir, "Manning_ANSR.shp"),
                              overwrite = TRUE) %>%
    joinReportingPolygons(., manning)
  manning.caribou <- postProcess(ml[["LandWeb Caribou Ranges"]],
                                 studyArea = manning, useSAcrs = TRUE,
                                 filename2 = file.path(dataDir, "Manning_caribou.shp"),
                                 overwrite = TRUE) %>%
    joinReportingPolygons(., manning)

  ml <- mapAdd(manning, ml, layerName = "Manning", useSAcrs = TRUE, poly = TRUE,
               analysisGroupReportingPolygon = "Manning", isStudyArea = isTRUE(asStudyArea),
               columnNameForLabels = "Name", filename2 = NULL)
  ml <- mapAdd(manning.ansr, ml, layerName = "Manning ANSR", useSAcrs = TRUE, poly = TRUE,
               analysisGroupReportingPolygon = "Manning ANSR",
               columnNameForLabels = "Name", filename2 = NULL)
  ml <- mapAdd(manning.caribou, ml, layerName = "Manning Caribou", useSAcrs = TRUE, poly = TRUE,
               analysisGroupReportingPolygon = "Manning Caribou",
               columnNameForLabels = "Name", filename2 = NULL)

  ## studyArea shouldn't use analysisGroup because it's not a reportingPolygon
  manning_sr <- postProcess(ml[["LandWeb Study Area"]],
                            studyArea = amc::outerBuffer(manning, bufferDist),
                            useSAcrs = TRUE,
                            filename2 = file.path(dataDir, "Manning_SR.shp"),
                            overwrite = TRUE)

  plotFMA(manning, provs = ab, caribou = manning.caribou, xsr = manning_sr,
          title = "Manning", png = file.path(dataDir, "Manning.png"))
  #plotFMA(manning, provs = ab, caribou = manning.caribou, xsr = manning_sr,
  #        title = "Manning", png = NULL)

  if (isTRUE(asStudyArea)) {
    ml <- mapAdd(manning_sr, ml, isStudyArea = TRUE, layerName = "Manning SR",
                 useSAcrs = TRUE, poly = TRUE, studyArea = NULL, # don't crop/mask to studyArea(ml, 2)
                 columnNameForLabels = "NSN", filename2 = NULL)
  }

  return(ml)
}
