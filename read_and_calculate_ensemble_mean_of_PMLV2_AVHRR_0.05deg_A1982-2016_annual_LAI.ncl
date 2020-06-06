begin

year=ispan(1982,2016,1)
nyear=dimsizes(year)

flandcover=addfile("IGBP_MODIS_MCD12C1_Majority_Land_Cover_Type_1_Percent_2001_0.05deg.nc","r")
frac_area=(flandcover->Majority_Land_Cover_Type_1_Percent)*0.01  ;;from percentage to fraction
vege_mask=where(frac_area.ge.0.01,1,frac_area@_FillValue)

do iy=0,nyear-1
path="./annual_LAI_0.05deg/"
fin1=addfile(path+"LAI_of_AVHRR_GIMMS3g_15D_annual_A"+year(iy)+"_0.05deg.nc","r")
LAI1=fin1->LAI

fin2=addfile(path+"LAI_of_AVHRR_GLASS_15D_annual_A"+year(iy)+"_0.05deg.nc","r")
LAI2=fin2->LAI

fin3=addfile(path+"LAI_of_AVHRR_GLOBMAP_15D_annual_A"+year(iy)+"_0.05deg.nc","r")
LAI3=fin3->LAI

LAI_y=(LAI1+LAI2+LAI3)/3
LAI_y@units="m2 m-2"
LAI_y=LAI_y*vege_mask
copy_VarCoords(LAI1,LAI_y)


wgt=cos(LAI_y&latitude/180.*3.14159)
;print(wgt)

gl_LAI_y=dim_avg_n_Wrap(dim_avg_wgt_n_Wrap(LAI_y, wgt, 1, 0),0)
gl_LAI_y@units="m2 m-2"
gl_LAI_y!0="time"
gl_LAI_y&time=year(iy)
print(gl_LAI_y)

;===================================================================
; explicitly declare file definition mode. Improve efficiency.
;===================================================================
;setfileoption("nc","Format","NetCDF4Classic")

system("rm -rf LAI_of_AVHRR_Ensemble_15D_annual_A"+year(iy)+"_0.05deg.nc")
fileout="LAI_of_AVHRR_Ensemble_15D_annual_A"+year(iy)+"_0.05deg.nc"
fout=addfile(fileout,"c")

   ; create global attributes of the file
   ;===================================================================
   fAtt               = True            ; assign file attributes
   fAtt@title         = "AVHRR Ensemble"
   fAtt@Conventions   = "None"
   fAtt@creation_date = systemfunc ("date")
   fileattdef(fout, fAtt)      ; copy file attributes

fout->LAI=LAI_y
fout->LAI_global_mean=gl_LAI_y

end do


end 
