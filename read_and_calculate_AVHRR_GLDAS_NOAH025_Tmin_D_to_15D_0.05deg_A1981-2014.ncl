
begin

year=ispan(1982,1988,1)
month=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
nyear=dimsizes(year)
nmon=dimsizes(month)

do iy=0,nyear-1
do im=0,nmon-1

path="GLDAS_NOAH025_D.2.0/"+year(iy)+"/"+month(im)+"/"
files=systemfunc("ls "+path+"GLDAS_NOAH025_D.*.020.Tmin.nc4")
nfiles=dimsizes(files)
files_a=files(0:14)
files_b=files(15:(nfiles-1))

path_out="GLDAS_NOAH025_15D/"+year(iy)+"/"
system("mkdir -p "+path_out)
fout_a=path_out+"GLDAS_NOAH025_15D_A"+year(iy)+month(im)+"a_0.05deg.Tmin.nc"
fout_b=path_out+"GLDAS_NOAH025_15D_A"+year(iy)+month(im)+"b_0.05deg.Tmin.nc" 

do ip=0,1

if (ip.eq.0) then
  f=addfiles(files_a,"r")
elseif (ip.eq.1) then
  f=addfiles(files_b,"r")
end if
print(f)

data1_in=dim_avg_n_Wrap(f[:]->Tair_f_inst,0)
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

if (ip.eq.0)then
  system("rm -rf "+fout_a)
  fout=addfile(fout_a,"c")
elseif (ip.eq.1)then
  system("rm -rf "+fout_b)
  fout=addfile(fout_b,"c")
end if
print(fout)

fout->Tmin=data1(::-1,:)

;************************************************
; create plot
;************************************************
if (ip.eq.0)then
  wks = gsn_open_wks("pdf",path_out+"GLDAS_NOAH025_15D.A"+year(iy)+month(im)+"a_0.05deg_Tmin_test")
elseif (ip.eq.1)then
  wks = gsn_open_wks("pdf",path_out+"GLDAS_NOAH025_15D.A"+year(iy)+month(im)+"b_0.05deg_Tmin_test")
end if

  cmap = read_colormap_file("BlAqGrYeOrReVi200")

  res                      = True               ; plot mods desired
  res@tiMainString         = "GLDAS_NOAH025_15D"    ; main title
  res@cnFillOn             = True               ; turn on color fill
  res@cnLinesOn        = False                     ; Turn off contour lines
  res@cnFillMode       = "RasterFill"              ; Raster Mode 

  plot = gsn_csm_contour_map(wks,data1(::10,::10), res)     ; create plot

end do

delete(files)
delete(files_a)
delete(files_b)

end do
end do


end
