
begin

year=ispan(1994,2014,1)
month=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
nyear=dimsizes(year)
nmon=dimsizes(month)

do iy=0,nyear-1
do im=0,nmon-1

path="GLDAS_NOAH025_D.2.0/"+year(iy)+"/"+month(im)+"/"
files=systemfunc("ls "+path+"GLDAS_NOAH025_D.*.020.nc4")
nfiles=dimsizes(files)
files_a=files(0:14)
files_b=files(15:(nfiles-1))

path_out="GLDAS_NOAH025_15D/"+year(iy)+"/"
system("mkdir -p "+path_out)
fout_a=path_out+"GLDAS_NOAH025_15D_A"+year(iy)+month(im)+"a_0.05deg.nc"
fout_b=path_out+"GLDAS_NOAH025_15D_A"+year(iy)+month(im)+"b_0.05deg.nc" 

do ip=0,1

if (ip.eq.0) then
  f=addfiles(files_a,"r")
elseif (ip.eq.1) then
  f=addfiles(files_b,"r")
end if
print(f)

data1_in=dim_avg_n_Wrap(f[:]->Wind_f_inst,0)
data2_in=dim_avg_n_Wrap(f[:]->Rainf_f_tavg,0)
data3_in=dim_avg_n_Wrap(f[:]->Tair_f_inst,0)
data4_in=dim_avg_n_Wrap(f[:]->Qair_f_inst,0)
data5_in=dim_avg_n_Wrap(f[:]->Psurf_f_inst,0)
data6_in=dim_avg_n_Wrap(f[:]->SWdown_f_tavg,0)
data7_in=dim_avg_n_Wrap(f[:]->LWdown_f_tavg,0)
printVarSummary(data1_in)
delete(f)

lon=data1_in&lon
lat=data1_in&lat

longitude=fspan(-180,180,7200)
latitude=fspan(-90,90,3600)
longitude!0="longitude"
latitude!0="latitude"
longitude@units="degree_east"
latitude@units="degree_north"

;print(longitude)
;print(latitude)

data1=linint2_Wrap(lon,lat,data1_in,True,longitude,latitude,0)
data1!0="latitude"
data1!1="longitude"
data1&latitude=latitude
data1&longitude=longitude
copy_VarAtts(data1_in,data1)
printVarSummary(data1)

data2=linint2_Wrap(lon,lat,data2_in,True,longitude,latitude,0)
data2!0="latitude"
data2!1="longitude"
data2&latitude=latitude
data2&longitude=longitude       
copy_VarAtts(data2_in,data2)
printVarSummary(data2)

data3=linint2_Wrap(lon,lat,data3_in,True,longitude,latitude,0)
data3!0="latitude"
data3!1="longitude"
data3&latitude=latitude
data3&longitude=longitude  
copy_VarAtts(data3_in,data3)
printVarSummary(data3)

data4=linint2_Wrap(lon,lat,data4_in,True,longitude,latitude,0)
data4!0="latitude"
data4!1="longitude"
data4&latitude=latitude
data4&longitude=longitude 
copy_VarAtts(data4_in,data4)
printVarSummary(data4)

data5=linint2_Wrap(lon,lat,data5_in,True,longitude,latitude,0)
data5!0="latitude"
data5!1="longitude"
data5&latitude=latitude
data5&longitude=longitude 
copy_VarAtts(data5_in,data5)
printVarSummary(data5)

data6=linint2_Wrap(lon,lat,data6_in,True,longitude,latitude,0)
data6!0="latitude"
data6!1="longitude"
data6&latitude=latitude
data6&longitude=longitude
copy_VarAtts(data6_in,data6)
printVarSummary(data6)

data7=linint2_Wrap(lon,lat,data7_in,True,longitude,latitude,0)
data7!0="latitude"
data7!1="longitude"
data7&latitude=latitude
data7&longitude=longitude 
copy_VarAtts(data7_in,data7)
printVarSummary(data7)

if (ip.eq.0)then
  system("rm -rf "+fout_a)
  fout=addfile(fout_a,"c")
elseif (ip.eq.1)then
  system("rm -rf "+fout_b)
  fout=addfile(fout_b,"c")
end if
print(fout)

fout->Wind=data1(::-1,:)
fout->Rainf=data2(::-1,:)
fout->Tair=data3(::-1,:)
fout->Qair=data4(::-1,:)
fout->Psurf=data5(::-1,:)
fout->SWdown=data6(::-1,:)
fout->LWdown=data7(::-1,:)

;************************************************
; create plot
;************************************************
if (ip.eq.0)then
  wks = gsn_open_wks("pdf",path_out+"GLDAS_NOAH025_15D.A"+year(iy)+month(im)+"a_0.05deg_test")
elseif (ip.eq.1)then
  wks = gsn_open_wks("pdf",path_out+"GLDAS_NOAH025_15D.A"+year(iy)+month(im)+"b_0.05deg_test")
end if

  cmap = read_colormap_file("BlAqGrYeOrReVi200")

  res                      = True               ; plot mods desired
  res@tiMainString         = "GLDAS_NOAH025_15D"    ; main title
  res@cnFillOn             = True               ; turn on color fill
  res@cnLinesOn        = False                     ; Turn off contour lines
  res@cnFillMode       = "RasterFill"              ; Raster Mode 

  plot = gsn_csm_contour_map(wks,data1(::10,::10), res)     ; create plot
  plot = gsn_csm_contour_map(wks,data2(::10,::10), res)     ; create plot
  plot = gsn_csm_contour_map(wks,data3(::10,::10), res)     ; create plot
  plot = gsn_csm_contour_map(wks,data4(::10,::10), res)     ; create plot
  plot = gsn_csm_contour_map(wks,data5(::10,::10), res)     ; create plot
  plot = gsn_csm_contour_map(wks,data6(::10,::10), res)     ; create plot
  plot = gsn_csm_contour_map(wks,data7(::10,::10), res)     ; create plot

end do

delete(files)
delete(files_a)
delete(files_b)

end do
end do


end
