
begin

year=ispan(1982,2016,1)
month=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
ndayom=(/31,28,31,30,31,30,31,31,30,31,30,31/)
nyear=dimsizes(year)
nmon=dimsizes(month)

flandcover=addfile("IGBP_MODIS_MCD12C1_Majority_Land_Cover_Type_1_Percent_2001_0.05deg.nc","r")
frac_area=(flandcover->Majority_Land_Cover_Type_1_Percent)*0.01  ;;from percentage to fraction
vege_mask=where(frac_area.ge.0.01,1,frac_area@_FillValue)

do iy=0,nyear-1

path="./monthly_LAI_0.05deg/"
fin=addfile(path+"LAI_of_AVHRR_GLASS_15D_monthly_A"+year(iy)+"_0.05deg.nc","r")
LAI=fin->LAI

path_T="./monthly_GLDAS_0.05deg/"
fin_T=addfile(path_T+"tas_of_GLDAS_NOAH025_15D_monthly_A"+year(iy)+"_0.05deg.nc","r")
tas=fin_T->tas

tas@_FillValue=LAI@_FillValue
vege_mask@_FillValue=LAI@_FillValue

mask_gs=where(tas.le.0,tas@_FillValue,1)
mask_gs@_FillValue=LAI@_FillValue
copy_VarCoords(tas,mask_gs)
printVarSummary(mask_gs)

LAI=LAI*mask_gs
printVarSummary(LAI)
LAI@_FillValue=tas@_FillValue

LAI_gs=dim_avg_n_Wrap(LAI,0)
LAI_gs@units="m2 m-2"
LAI_gs=LAI_gs*vege_mask
printVarSummary(LAI_gs)
wgt=cos(LAI&latitude/180.*3.14159)
;print(wgt)

gl_LAI_gs=dim_avg_n_Wrap(dim_avg_wgt_n_Wrap(LAI_gs, wgt, 1, 0),0)
gl_LAI_gs@units="m2 m-2" 
gl_LAI_gs!0="time"
gl_LAI_gs&time=year(iy)
print(gl_LAI_gs)

;===================================================================
; explicitly declare file definition mode. Improve efficiency.
;===================================================================
;setfileoption("nc","Format","NetCDF4Classic")

system("rm -rf LAI_of_AVHRR_GLASS_15D_growing_season_A"+year(iy)+"_0.05deg.nc")
fileout="LAI_of_AVHRR_GLASS_15D_growing_season_A"+year(iy)+"_0.05deg.nc"
fout=addfile(fileout,"c")

   ; create global attributes of the file
   ;===================================================================
   fAtt               = True            ; assign file attributes
   fAtt@title         = "AVHRR GLASS V04"
   fAtt@Conventions   = "None"
   fAtt@creation_date = systemfunc ("date")
   fileattdef(fout, fAtt)      ; copy file attributes

fout->LAI=LAI_gs
fout->LAI_global_mean=gl_LAI_gs

end do

end
