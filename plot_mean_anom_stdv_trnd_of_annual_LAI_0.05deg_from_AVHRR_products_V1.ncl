;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

Startyr=1982
Endyr=2016

year=ispan(Startyr,Endyr,1)
nyear=Endyr-Startyr+1

 model=(/"Ensemble","GIMMS3g","GLASS","GLOBMAP"/)
 nmodel=dimsizes(model)

varname=(/"LAI"/)
nvar=dimsizes(varname)
varname_mean=(/"mean"/)
varname_refm=(/"refm"/)
varname_anom=(/"anom"/)
varname_stdv=(/"stdv"/)
varname_trnd=(/"trnd"/)
varname_prob=(/"prob"/)

longitude=fspan(-180,180,7200)
latitude=fspan(-90,90,3600)
latitude=latitude(::-1)
longitude!0="longitude"
latitude!0="latitude"
longitude@units="degree_east"
latitude@units="degree_north"
nlat=dimsizes(latitude)
nlon=dimsizes(longitude)

data_ann_avg=new((/nmodel,nlat,nlon/),float)
data_ann_avg!0="model"
data_ann_avg!1="latitude"
data_ann_avg!2="longitude"
data_ann_avg&model=ispan(1,nmodel,1)
data_ann_avg&latitude=latitude
data_ann_avg&longitude=longitude

data_ann_ref=data_ann_avg
data_ann_ano=data_ann_avg
data_ann_std=data_ann_avg
data_ann_trd=data_ann_avg
data_ann_prb=data_ann_avg
data_ann_trd_ref=data_ann_avg

lat2d=data_ann_avg
lon2d=data_ann_avg

lat2d=conform_dims(dimsizes(lat2d),latitude,(/1/))
lon2d=conform_dims(dimsizes(lon2d),longitude,(/2/))

dmlat=30  ;;;;; to make plot sparse points, lager num then sparser
dmlon=30

nlatlon=dimsizes(ndtooned(lat2d(0,::dmlat,::dmlon)))

lat1d=new((/nmodel,nlatlon/),float)
lon1d=new((/nmodel,nlatlon/),float)

 do ivar= 0,nvar-1
   print(varname(ivar))

   OutFilePlot = "plot_statistics_of_annual_"+varname(ivar)+"_0.05deg_AVHRR_products_"+Startyr+"-"+Endyr
   plot_mean=new(nmodel,graphic)
   plot_stdv=new(nmodel,graphic)
   plot_trnd=new(nmodel,graphic)
   plot_trnd_ref=new(nmodel,graphic)
   dum=new(nmodel,graphic)
   dum2=new(nmodel,graphic)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  system("rm -rf "+OutFilePlot)
  wks = gsn_open_wks("pdf",OutFilePlot)

  gsn_define_colormap(wks,"MPL_RdYlGn")

 do imodel= 0, nmodel -1

   FilePath="./"
   FileNameAnn="Climatological_statistics_of_annual_"+varname(ivar)+"_of_AVHRR_"+model(imodel)+"_15D_annual_A"+Startyr+"-"+Endyr+"_0.05deg.nc"

   fin=addfile(FilePath+FileNameAnn,"r")
   printVarSummary(fin)

   data_cf_ann_avg=fin->$varname_mean(ivar)$
   data_cf_ann_ref=fin->$varname_refm(ivar)$
   data_cf_ann_std=fin->$varname_stdv(ivar)$
   data_cf_ann_trd=fin->$varname_trnd(ivar)$
   data_cf_ann_prb=fin->$varname_prob(ivar)$

   data_cf_ann_avg=where(data_cf_ann_avg.eq.0,data_cf_ann_avg@_FillValue,data_cf_ann_avg)
   data_cf_ann_ref=where(data_cf_ann_ref.eq.0,data_cf_ann_ref@_FillValue,data_cf_ann_ref)
   data_cf_ann_std=where(data_cf_ann_std.eq.0,data_cf_ann_std@_FillValue,data_cf_ann_std)
   data_cf_ann_trd=where(data_cf_ann_trd.eq.0,data_cf_ann_trd@_FillValue,data_cf_ann_trd)
   data_cf_ann_prb=where(data_cf_ann_prb.eq.0,data_cf_ann_prb@_FillValue,data_cf_ann_prb)

   ; data_cf_ann_trd = data_cf_ann_trd/data_cf_ann_ref*100*10
   ; data_cf_ann_trd@units="%/decade"

   data_ann_avg(imodel,:,:)=data_cf_ann_avg
   data_ann_ref(imodel,:,:)=data_cf_ann_ref
   data_ann_std(imodel,:,:)=data_cf_ann_std
   data_ann_trd(imodel,:,:)=data_cf_ann_trd
   data_ann_prb(imodel,:,:)=data_cf_ann_prb
   data_ann_trd_ref(imodel,:,:)=data_cf_ann_trd/data_cf_ann_ref*100*10 

   data_ann_avg@long_name=data_cf_ann_avg@long_name
   data_ann_ref@long_name=data_cf_ann_ref@long_name
   data_ann_std@long_name=data_cf_ann_std@long_name
   data_ann_trd@long_name=data_cf_ann_trd@long_name
   data_ann_prb@long_name=data_cf_ann_prb@long_name
   data_ann_trd_ref@long_name=data_cf_ann_trd@long_name

   data_ann_avg@units=data_cf_ann_avg@units
   data_ann_ref@units=data_cf_ann_ref@units
   data_ann_std@units=data_cf_ann_std@units
   data_ann_trd@units="m2 m-2 year-1"
   data_ann_prb@units=data_cf_ann_prb@units
   data_ann_trd_ref@units="%/decade"

   psig=0.01
   prob=where(data_cf_ann_prb.le.psig,data_cf_ann_prb,data_cf_ann_prb@_FillValue)
   lat2d(imodel,:,:)=where(prob.le.psig,lat2d(imodel,:,:),lat2d@_FillValue)
   lon2d(imodel,:,:)=where(prob.le.psig,lon2d(imodel,:,:),lon2d@_FillValue)

   lat1d(imodel,:) = ndtooned(lat2d(imodel,::dmlat,::dmlon))
   lon1d(imodel,:) = ndtooned(lon2d(imodel,::dmlat,::dmlon))
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  delete(data_cf_ann_avg)
  delete(data_cf_ann_ref)
  delete(data_cf_ann_std)
  delete(data_cf_ann_trd)
  delete(data_cf_ann_prb)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  res                      = True               ; plot mods desired
  res@gsnDraw              = False        ; do not draw picture
  res@gsnFrame             = False        ; do not advance frame

  res@gsnMaximize          = False
  res@vpKeepAspect         = True
;  res@vpWidthF             = 0.9
;  res@vpHeightF            = 0.7

  res@gsnAddCyclic         = True              ; regional data
  res@mpMinLatF            = -60. ; range to zoom in on
  res@mpMaxLatF            = 90.
  res@mpMinLonF            = -180.
  res@mpMaxLonF            = 180

  res@tiMainFontHeightF    = 0.02
  res@tmXBLabelFontHeightF = 0.017
  res@tmYLLabelFontHeightF = 0.017

  res@lbLabelBarOn         = False            ; turn off individual label bars
  res@tiMainString         = varname(ivar)    ; main title
  res@cnFillOn             = True               ; turn on color fill
  res@cnLinesOn            = False
  res@cnLineLabelsOn       = False
  res@cnFillMode           = "RasterFill"
  res@cnLevelSelectionMode = "ExplicitLevels"

  res@cnLevels = (/0,0.05,0.1,0.2,0.5,0.65,1.,2.,5./)
  res@tiMainString         = model(imodel)
  plot_mean(imodel) = gsn_csm_contour_map(wks,data_ann_avg(imodel,::5,::5), res)

  res@cnLevels = (/0,0.05,0.1,0.2,0.5,0.65,1.,2.,5./)
  res@tiMainString         = model(imodel)
  plot_stdv(imodel) = gsn_csm_contour_map(wks,data_ann_std(imodel,::5,::5), res)

  res@cnLevels = (/-30.,-10.,-3.,-1.,0.,1.,3.,10.,30./)*0.001
  res@tiMainString         = model(imodel)
  plot_trnd(imodel) = gsn_csm_contour_map(wks,data_ann_trd(imodel,::5,::5), res)

  res@cnLevels = (/-30.,-10.,-3.,-1.,0.,1.,3.,10.,30./)
  res@tiMainString         = model(imodel)
  plot_trnd_ref(imodel) = gsn_csm_contour_map(wks,data_ann_trd_ref(imodel,::5,::5), res)

  mkres               = True
  mkres@gsMarkerIndex = 1
  mkres@gsMarkerColor = "black"
  mkres@gsMarkerSizeF = 0.003
  mkres@gsMarkerThicknessF = 0.1

  dum(imodel)=gsn_add_polymarker(wks,plot_trnd(imodel),lon1d(imodel,:),lat1d(imodel,:),mkres)
  dum2(imodel)=gsn_add_polymarker(wks,plot_trnd_ref(imodel),lon1d(imodel,:),lat1d(imodel,:),mkres)
 
end do


; draw panel with white space added
 resP                 = True

 resP@gsnPanelLabelBar          = True                   ; add common colorbar
 resP@lbOrientation             = "Horizontal"      ; ncl default is vertical
 resP@lbLabelFontHeightF        = 0.012          ; set font height of Label Bar labels
 resP@pmLabelBarOrthogonalPosF  = -0.01
 resP@pmLabelBarWidthF          = 0.6               ; default is shorter
 resP@pmLabelBarHeightF         = 0.05               ; default is taller

 resP@gsnPanelYWhiteSpacePercent = 2
; resP@gsnPanelXWhiteSpacePercent = 5

 gsn_panel(wks,plot_mean,(/2,2/),resP)

 gsn_panel(wks,plot_stdv,(/2,2/),resP)

 gsn_panel(wks,plot_trnd,(/2,2/),resP)

 gsn_panel(wks,plot_trnd_ref,(/2,2/),resP)
;;;;;;;;;;;;;;;;;;;;;

end do

end 
