
; ******************************************************************************************
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

f_IGBP=addfile("IGBP_Land_Cover_0.05deg.nc","r")
lon=f_IGBP->longitude
lat=f_IGBP->latitude
landcover=f_IGBP->Majority_Land_Cover_Type_1
printVarSummary(landcover)

nlon=dimsizes(lon)
nlat=dimsizes(lat)

f_LAI=addfile("GIMMS3g_LAI_0.05deg.nc","r")
LAI=tofloat(f_LAI->LAI)
LAI=LAI * 0.001
LAI=where(ismissing(LAI),0.,LAI)
;LAI=where(landcover.le.0,LAI@_FillValue,LAI)

f_GLDAS=addfile("GLDAS_Forcing_0.05deg.nc","r")
prcp=f_GLDAS->Rainf  ;; kg m-2 s-1

prcp=prcp * 86400   ;kg/m2/s to mm/d

LAI@_FillValue=-9999.

LAI=where(ismissing(prcp),LAI@_FillValue,LAI)

;********************************************************
;;IGBP land cover code, var landcover
;********************************************************
;;MODIS 005 IGBP land cover code
;- 0 Water Bodies
;- 1 Evergreen Needleleaf Forest
;- 2 Evergreen Broadleaf Forest
;- 3 Deciduous Needleleaf Forest
;- 4 Deciduous Broadleaf Forest
;- 5 Mixed Forest
;- 6 Closed Shrublands
;- 7 Open Shrublands
;- 8 Woody Savannas
;- 9 Savannas
;- 10 Grasslands
;- 11 Permanent Wetlands
;- 12 Croplands
;- 13 Urban and Built-Up
;- 14 Cropland/Natural Vegetation Mosaic
;- 15 Permanent Snow and Ice
;- 16 Barren or Sparsely Vegetated
;- 17 Unclassified
;;;;;;;;;;;;
;For parameters, we set:
;13 (Urban and Built-Up)           = 5  (mixed forest)
;16 (Barren or Sparsely Vegetated) = 10 (grassland)
;*********************************************************
; * TWO INTERCEPTION PARAMETERS
; * S_sls  : specific canopy rainfall storage capacity per unit leaf area (mm)
; * fER0   : 
; * LAIref
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Initial parameter values for IGBP land cover classifications
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;PMLv2-AVHRR calibrated parameters using AVHRR LAI ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;old for modis lai
;S_sls_raw = (/0.000, 0.123, 0.098, 0.123, 0.069, 0.131,\
;        0.014, 0.014, 0.174, 0.049, 0.114, 0.010,\
;        0.010, 0.131, 0.010, 0.000, 0.114, 0.000/);
;;;;;;;;new for avhrr lai
;S_sls_raw = (/0.000, 0.116, 0.084, 0.084, 0.069, 0.131,\
;        0.014, 0.014, 0.010, 0.022, 0.114, 0.010,\
;        0.010, 0.198, 0.010, 0.000, 0.114, 0.000/);
;S_sls_raw = (/0.000, 0.116, 0.084, 0.084, 0.168, 0.198,\
;        0.014, 0.014, 0.010, 0.022, 0.227, 0.010,\
;        0.010, 0.198, 0.010, 0.000, 0.227, 0.000/);

S_sls_raw = (/0.000, 0.153, 0.098, 0.078, 0.069, 0.099,\
        0.508, 0.508, 0.162, 0.162, 0.162, 0.058,\
        0.058, 0.099, 0.058, 0.000, 0.162, 0.000/);
;;;;;;;;old for modis lai
;fER0_raw = (/0.000, 0.055, 0.085, 0.055, 0.010, 0.010,\
;        0.010, 0.010, 0.109, 0.055, 0.023, 0.010,\
;        0.158, 0.010, 0.158, 0.000, 0.023, 0.000/);
;;;;;;;;new for avhrr lai
;fER0_raw = (/0.000, 0.055, 0.085, 0.055, 0.010, 0.010,\
;        0.010, 0.010, 0.061, 0.055, 0.010, 0.010,\
;        0.092, 0.10, 0.092, 0.000, 0.010, 0.000/);
fER0_raw = (/0.000, 0.200, 0.200, 0.200, 0.010, 0.200,\
        0.050, 0.050, 0.050, 0.050, 0.050, 0.050,\
        0.050, 0.200, 0.050, 0.000, 0.050, 0.000/);
;;;;;;;;
LAIref_raw = (/2.50, 2.50, 2.50, 2.50, 2.50, 1.40,\
        1.40, 1.40, 1.40, 1.40, 1.40, 1.40,\
        1.40, 2.50, 1.40, 1.40, 1.40, 1.40/);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; for each PFTs from IGBP land cover 
LAIref=new((/nlat,nlon/),float)
S_sls=new((/nlat,nlon/),float)
fER0=new((/nlat,nlon/),float)

;;;set init values

 do ipft=0,17
   LAIref=where(landcover.eq.ipft,LAIref_raw(ipft),LAIref)
   S_sls=where(landcover.eq.ipft,S_sls_raw(ipft),S_sls)
   fER0=where(landcover.eq.ipft,fER0_raw(ipft),fER0)
 end do
; print(Alpha)

  ;; Ei, Pi
  fveg = 1. - exp(-LAI/LAIref)
  Sveg = S_sls * LAI
  fER = fER0 * fveg
;  print(fER)
  fveg = where(fveg.le.0,0.0001,fveg)
  fER = where(fER.le.0,0.0001,fER)
  prcp_wet = -log(1.- fER0) *Sveg/ fER 

  ;;Intercepted Evaporation (Ei)
  Ei = where((prcp - prcp_wet).ge.0.,(fveg * prcp_wet + fER * (prcp - prcp_wet)),fveg * prcp)
  Pi = prcp - Ei
  Pi = where(Pi.lt.0.,0.,Pi)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   copy_VarCoords(landcover,Ei)
   copy_VarCoords(landcover,Pi)
   copy_VarCoords(landcover,LAI)

   Ei@long_name="Interception from vegetation canopy"
   Ei@units="mm d-1"
   Pi@long_name="Precipitation into soil--the difference of Prcp and Ei"
   Pi@units="mm d-1"
   LAI@long_name="Leaf area index"
   LAI@units="m-2 m-2" 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Output in NetCDF format
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;===================================================================
   ; explicitly declare file definition mode. Improve efficiency.
   ;===================================================================
   setfileoption("nc","Format","NetCDF4Classic")

   system("rm -rf output_of_Ei_model_NCL_IGBP_GLDAS_AVHRR_15D.nc")
   fout=addfile("output_of_Ei_model_NCL_IGBP_GLDAS_AVHRR_15D.nc","c")

   ; create global attributes of the file
   ;===================================================================
   fAtt               = True            ; assign file attributes
   fAtt@title         = "Output of Ei model in NCL"
   fAtt@Climate_forcing  ="Near-surface forcing from GLDADS_NOAH025_15D forced by Priceton V2.2 climate forcing" 
   fAtt@LAI_forcing   = "AVHRR GIMMS3g V04"
   fAtt@Landcover_forcing = "IGBP MODIS 006"
   fAtt@Reference="Zhang, Y., Kong, D., Gan, R., Chiew, F.H.S., McVicar, T.R., Zhang, Q., and Yang, Y.. (2019) Coupled estimation of 500m and 8-day resolution global evapotranspiration and gross primary production in 2002-2017.Remote Sens. Environ. 222, 165-182, https://doi:10.1016/j.rse.2018.12.031"
   fAtt@Conventions   = "None"
;   fAtt@creation_date = systemfunc ("date")
   fileattdef(fout, fAtt)      ; copy file attributes

   ; write variables of the file
   ;========
   fout->Ei=Ei
   fout->Pi=Pi
   fout->landcover=landcover
   fout->LAI=LAI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
