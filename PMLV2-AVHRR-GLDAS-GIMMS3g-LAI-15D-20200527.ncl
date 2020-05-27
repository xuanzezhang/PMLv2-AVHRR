
; ****************************************************************************************
; * PML_V2 (Penman-Monteith-Leuning) model 
; * This code was written by Xuanze Zhang (xuanzezhang@igsnrr.ac.cn)
; * The code was translated from DD. Kong's javascript (Zhang et al.,Remote Sens. Environ., 2019)
; * @reference
; * 1. Zhang, Y., Kong, D., Gan, R., Chiew, F.H.S., McVicar, T.R., Zhang, Q., and 
; *     Yang, Y.. (2019) Coupled estimation of 500m and 8-day resolution global 
; *     evapotranspiration and gross primary production in 2002-2017. 
; *     Remote Sens. Environ. 222, 165-182, https://doi:10.1016/j.rse.2018.12.031 
; * 2. Kong, D., Zhang, Y., Gu, X., & Wang, D. (2019). A robust method
; *     for reconstructing global MODIS EVI time series on the Google Earth Engine.
; *     *ISPRS Journal of Photogrammetry and Remote Sensing*, *155*(May), 13–24.
; *     https://doi.org/10.1016/j.isprsjprs.2019.06.014
; * 3. Gan, R., Zhang, Y., Shi, H., Yang, Y., Eamus, D., Cheng, L., Chiew, F.H.S., 
; *     Yu, Q., 2018. Use of satellite leaf area index estimating evapotranspiration 
; *     and gross assimilation for Australian ecosystems. Ecohydrology e1974. 
; *     https://doi.org/10.1002/eco.1974
; * 4. Zhang, Y., Peña-Arancibia, J.L., McVicar, T.R., Chiew, F.H.S., Vaze, J., 
; *     Liu, C., Lu, X., Zheng, H., Wang, Y., Liu, Y.Y., Miralles, D.G., Pan, M. (2016), 
; *     Multi-decadal trends in global terrestrial evapotranspiration and its 
; *     components. Scientific Reports, 6(1).
; * 5. Zhang, Y., R. Leuning, L. B. Hutley, J. Beringer, I. McHugh, and J. P. Walker (2010), 
; *     Using long‐term water balances to parameterize surface conductances and 
; *     calculate evaporation at 0.05° spatial resolution, Water Resour. Res., 
; *     46, W05512, doi:10.1029/2009WR008716.
; * 6. Leuning, R., Y. Q. Zhang, A. Rajaud, H. Cleugh, and K. Tu (2008), 
; *     A simple surface conductance model to estimate regional evaporation using 
; *     MODIS leaf area index and the Penman-Monteith equation, Water Resour. Res., 
; *     44, W10419, doi:10.1029/2007WR006562. 
; ******************************************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
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

f_Albedo=addfile("GLASS_Albedo_0.05deg.nc","r")
Albedo=tofloat(f_Albedo->ABD_WSA_shortwave)
Albedo=Albedo * 0.0001  

Albedo=where(ismissing(Albedo),0.,Albedo)
;Albedo=where(landcover.le.0,Albedo@_FillValue,Albedo)

f_Emiss=addfile("GLASS_Emiss_0.05deg.nc","r")
Emiss=tofloat(f_Emiss->BBE)
Emiss=Emiss * 0.0001  

Emiss=where(ismissing(Emiss),0.98,Emiss)
;Emiss=where(landcover.le.0,Emiss@_FillValue,Emiss)

f_GLDAS=addfile("GLDAS_Forcing_0.05deg.nc","r")
u10=f_GLDAS->Wind  ;; m s-1
prcp=f_GLDAS->Rainf  ;; kg m-2 s-1
Tavg=f_GLDAS->Tair   ;; K
q=f_GLDAS->Qair     ;;  kg/kg
p=f_GLDAS->Psurf    ;; Pa
Rs=f_GLDAS->SWdown  ;; W m-2
Rln=f_GLDAS->LWdown  ;; W m-2

f_Tmax=addfile("GLDAS_Tmax_0.05deg.nc","r")
Tmax=f_Tmax->Tmax  ;; K

f_Tmin=addfile("GLDAS_Tmin_0.05deg.nc","r")
Tmin=f_Tmin->Tmin  ;; K

u2=u10*4.87/log(67.8*10-5.42)  ;;gldas wind height is 10m

prcp=prcp * 86400   ;kg/m2/s to mm/d

Tavg=Tavg - 273.15 ; from K to deg C
Tmin=Tmin - 273.15
Tmax=Tmax - 273.15
p=p*0.001  ;; from Pa to kPa

Ca_in=asciiread("global_mean_CO2_in_ppm.txt",1,"float")
Ca=new((/nlat,nlon/),float)  ;; ppm or mol mol-1
Ca=Ca_in

Ca@_FillValue=-9999.
LAI@_FillValue=-9999.
Albedo@_FillValue=-9999.
Emiss@_FillValue=-9999.

LAI=where(ismissing(Tavg),LAI@_FillValue,LAI)
Albedo=where(ismissing(Tavg),Albedo@_FillValue,Albedo)
Emiss=where(ismissing(Tavg),Emiss@_FillValue,Emiss)

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
;** PML GLOBAL PARAMETERS 
    Gsc         = 0.0820 ; // solar constant in unit MJ m-2 min-1,
    as          = 0.25   ; // parameter Rs/Ra=as+bs*n/N; calibration from our solar radiation measurement
    bs          = 0.50   ; // parameter Rs/Ra=as+bs*n/N;
    alfa        = 0.23   ; // surface albedo of grass
    alfa_forest = 0.22   ; // surface albedo of forest
    alfa_crop   = 0.14   ; // surface albedo of crop

    kmar   = 0.40    ; // von Karman's constant 0.40 
    Zob    = 15.      ; // m, making sure higher than hc
    Cp     = 1.0164  ; // 4.2 * 0.242, specific heat at constant pressure, 1.013  [J g-1 0C-1]
    epsl   = 0.622   ; // ratio molecular weight of water vapour/dry air
    lambda_25 = 2500. ; // latent heat of vaporization, 2500 [J g-1]  at 25 degC

;** PML_v1 parameters for Gc
; * kQ     = 0.4488  ; // extinction coefficient
; * kA     = 0.7  ; // attenuation of net all-wave irradicance, typically about 0.6-0.8 (Denmend, 1976, Kelliher FM et al., (1995))
; * Q50    = 30      ; // the value of absorbed PAR when gs=gsx/2, W/m2
; * D0     = 0.7     ; // the value of VPD when stomtal conductance is reduced  kpa 
; * 
; * SEVEN OPTIMIZED PARAMETERS
; * 
; * Alpha  : initial photochemical efficiency, 0.02-0.08
; * Theta  : the initla slope of the slope of CO2 response curve[umol m-2 s-1]/[umol mol-1], 1
; * m      : Ball-Berry coefficient 2-20
; * Am_25  : the maximum catalytic capacity of Rubisco per unit leaf area at 25 degree
; * kQ     : the value of VPD when stomtal conductance is reduced 
; * kA     : extinction coefficient
; *
; * TWO INTERCEPTION PARAMETERS
; * S_sls  : specific canopy rainfall storage capacity per unit leaf area (mm)
; * fER0   : 
; * LAIref
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Initial parameter values for IGBP land cover classifications
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;PMLv2-AVHRR calibrated parameters using AVHRR LAI ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Alpha_raw = (/0.000, 0.029, 0.037, 0.037, 0.037, 0.029,\
        0.029, 0.029, 0.029, 0.029, 0.029, 0.029,\
        0.029, 0.029, 0.029, 0.000, 0.029, 0.001/);
Theta_raw = (/0.000, 0.067, 0.069, 0.069, 0.032, 0.040,\
        0.024, 0.024, 0.044, 0.069, 0.026, 0.069,\
        0.069, 0.040, 0.069, 0.000, 0.026, 0.000/);
m_raw = (/0.000, 4.563, 8.250, 8.250, 7.328, 8.355,\
        4.406, 4.406, 7.305, 9.211, 3.934, 6.805,\
        5.289, 8.355, 5.289, 0.000, 3.934, 0.000/);
Am_25_raw = (/0.000, 24.078, 20.359, 20.359, 16.313, 28.453,\
        18.766, 18.766, 27.320, 24.445, 29.559, 10.253,\
        22.565, 28.453, 22.565, 0.000, 29.559, 0.000/);
D0_raw = (/0.700, 0.841, 0.532, 0.532, 0.501, 0.552,\
        0.864, 0.864, 1.997, 0.661, 0.638, 2.000,\
        2.000, 0.552, 2.000, 0.700, 0.638, 0.700/);
kQ_raw = (/0.600, 0.746, 1.000, 1.000, 0.734, 0.386,\
        0.230, 0.230, 0.843, 0.996, 0.595, 0.780,\
        0.721, 0.386, 0.721, 0.600, 0.595, 0.600/);
kA_raw = (/0.700, 0.716, 0.899, 0.899, 0.899, 0.899,\
        0.888, 0.888, 0.899, 0.888, 0.900, 0.899,\
        0.899, 0.899, 0.899, 0.700, 0.900, 0.700/);
S_sls_raw = (/0.000, 0.116, 0.084, 0.084, 0.168, 0.198,\
        0.014, 0.014, 0.010, 0.022, 0.227, 0.010,\
        0.010, 0.198, 0.010, 0.000, 0.227, 0.000/);
fER0_raw = (/0.000, 0.272, 0.163, 0.163, 0.010, 0.256,\
        0.010, 0.010, 0.061, 0.170, 0.010, 0.156,\
        0.092, 0.256, 0.092, 0.000, 0.010, 0.000/);
VPDmin_raw = (/1.000, 1.493, 1.496, 1.496, 0.887, 0.711,\
        1.493, 1.493, 1.496, 0.664, 1.650, 1.499,\
        1.499, 0.711, 1.499, 1.000, 0.650, 1.000/);
VPDmax_raw = (/4.000, 6.500, 5.770, 5.770, 3.500, 3.500,\
        5.797, 5.797, 6.500, 5.188, 5.199, 6.500,\
        6.500, 3.500, 6.500, 4.000, 5.199, 4.000/);
;;not real values for LAIref currently
LAIref_raw = (/5.000, 5.000, 5.000, 5.000, 5.000, 5.000,\
        5.000, 5.000, 5.000, 5.000, 5.000, 5.000,\
        5.000, 5.000, 5.000, 5.000, 5.000, 5.000/);
;;Maximun stomatal conductance in m/s, make sure Ga/Gc~0
gsx_raw=1.e-3*(/50.00, 3.2, 3.8, 3.2, 4.3, 3.1,\
        2.4, 2.4, 1.9, 3.7, 2.3, 16.3,\
        5.2, 5.00, 5.2, 50.00, 0.50, 4.00/);
;;canopy height
hc_raw=(/0.01, 10., 10., 10., 10., 10.,\
        1.00, 1.00, 5.00, 5.00, 0.2, 1.00,\
        0.5, 10., 1.0, 0.01, 0.05, 0.1/);

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;* INPUT VARIABLES
; var Ca    //umol mol-1
; var q     // kg/kg;
; var p     // kPa
; var u2    // m/s
; var Tmax   // degC
; var Tmin   // degC
; var Tavg   // degC
; var Rln    // W/m2/s, not MJ/m2/d 
; var Rs     // W/m2/s
; var albedo // %
; var emiss  // %
; var LAI    // 0 - 
;*********************************************************************************************

;landcover=new((/nlat,nlon/),float)
;Albedo=new((/nlat,nlon/),float)
;Emiss=new((/nlat,nlon/),float)
;LAI=new((/nlat,nlon/),float)

;Ca=new((/nlat,nlon/),float)  ;; ppm or mol mol-1
;q=new((/nlat,nlon/),float)
;p=new((/nlat,nlon/),float)  ;;pressure, kPa
;u2=new((/nlat,nlon/),float) ;; wind, m s-1
;prcp=new((/nlat,nlon/),float) ;; precipitation, mm d-1
;Tmax=new((/nlat,nlon/),float)
;Tmin=new((/nlat,nlon/),float)
;Tavg=new((/nlat,nlon/),float)
;Rln=new((/nlat,nlon/),float)
;Rs=new((/nlat,nlon/),float) 

;;; for each PFTs from IGBP land cover 
hc=new((/nlat,nlon/),float)
Alpha=new((/nlat,nlon/),float)
Theta=new((/nlat,nlon/),float)
m=new((/nlat,nlon/),float)
Am=new((/nlat,nlon/),float)
D0=new((/nlat,nlon/),float)
kQ=new((/nlat,nlon/),float)
kA=new((/nlat,nlon/),float)
VPDmin=new((/nlat,nlon/),float)
VPDmax=new((/nlat,nlon/),float)
LAIref=new((/nlat,nlon/),float)
S_sls=new((/nlat,nlon/),float)
fER0=new((/nlat,nlon/),float)

;;;set init values

 do ipft=0,17
   Alpha=where(landcover.eq.ipft,Alpha_raw(ipft),Alpha)
   Theta=where(landcover.eq.ipft,Theta_raw(ipft),Theta)
   m=where(landcover.eq.ipft,m_raw(ipft),m)
   Am=where(landcover.eq.ipft,Am_25_raw(ipft),Am)
   D0=where(landcover.eq.ipft,D0_raw(ipft),D0)
   kQ=where(landcover.eq.ipft,kQ_raw(ipft),kQ)
   kA=where(landcover.eq.ipft,kA_raw(ipft),kA)
   LAIref=where(landcover.eq.ipft,LAIref_raw(ipft),LAIref)
   S_sls=where(landcover.eq.ipft,S_sls_raw(ipft),S_sls)
   fER0=where(landcover.eq.ipft,fER0_raw(ipft),fER0)
   VPDmin=where(landcover.eq.ipft,VPDmin_raw(ipft),VPDmin)
   VPDmax=where(landcover.eq.ipft,VPDmax_raw(ipft),VPDmax)
   Alpha=where(landcover.eq.ipft,Alpha_raw(ipft),Alpha)
   hc=where(landcover.eq.ipft,hc_raw(ipft),hc)
 end do
; print(Alpha)

;;;Step 1. calculate VPD,rou_a,gama, slop
  
  ;; 1.1. actual vapour pressure (ea)
  ea = q * p /(0.622 + 0.378 * q) 

  ;; 1.2. saturation vapor pressure in kPa with temperature in degC
  es_Tmax = 0.6108 * exp(17.27*Tmax/(Tmax+237.3))
  es_Tmin = 0.6108 * exp(17.27*Tmin/(Tmin+237.3))
  es_Tavg = 0.6108 * exp(17.27*Tavg/(Tavg+237.3))
  es      = 0.5 * (es_Tmax + es_Tmin)

  ;; 1.3. VPD
  VPD = es - ea  
  VPD = where(VPD.lt.0.001,0.001,VPD)
;  print(VPD)

  ;; 1.4. rou_a, gama, slop
  rou_a = 3846. * p / (Tavg + 273.15)
  lambda = lambda_25 - 2.2 * Tavg
  gama = Cp * p / (0.622 * lambda)
  slop = 4098 * es / (Tavg + 237.3)^2.0

;;;Step 2. calculate Rn, PAR 
  Stefan = 4.903e-9 ; // Stefan-Boltzmann constant [MJ K-4 m-2 day-1]
  Rns = (1.- Albedo) * Rs
  RLout = Emiss * Stefan * (Tavg + 273.15)^4.0/0.0864
  Rnl = Rln - RLout
  Rn = Rns + Rnl
  Rn = where(Rn.lt.0.,0.,Rn)  
  PAR = 0.45 * Rs

;;;Step 3. calculate Gc, GPP
  ;;3.1. Leuning f_vpd
  fvpd_gc = 1./ (1. + VPD / D0)
  fvpd = (VPDmax - VPD) / (VPDmax - VPDmin)  
  fvpd = where(fvpd.lt.0.,0.,fvpd)
  fvpd = where(fvpd.gt.1.,1.,fvpd)
;  print(fvpd)

  ;;3.2. Par_mol, fT2 
  PAR_mol = PAR * 4.57   ; // from [W m-2] to [umol m-2 s-1]
  fT2 = exp(0.031 * (Tavg - 25.)) / (1. + exp(0.115 * (Tavg - 41.))) 
  fT2 = where(fT2.gt.1.,1.,fT2)

  ;;3.3. P1, P2, P3, P4
  ;;To avoid P1,P2,P3,P4 become zero, we need to turn Am, Alpha, Theta to non-zero.
  Am    =where(Am.le.0,1.e-6,Am)
  Alpha =where(Alpha.le.0,1.e-6,Alpha) 
  Theta =where(Theta.le.0,1.e-6,Theta) 

  P1 = Am * Alpha * Theta * PAR_mol
  P2 = Am * Alpha * PAR_mol
  P3 = Am * Theta * Ca
  P4 = Alpha * Theta * PAR_mol * Ca / fT2
 
;  P1=where(landcover.eq.0.,P1@_FillValue,P1)
;  P2=where(landcover.eq.0.,P2@_FillValue,P2)
;  P3=where(landcover.eq.0.,P3@_FillValue,P3)
;  P4=where(landcover.eq.0.,P4@_FillValue,P4)

;  P1=where(landcover.eq.15,P1@_FillValue,P1)
;  P2=where(landcover.eq.15,P2@_FillValue,P2)
;  P3=where(landcover.eq.15,P3@_FillValue,P3)
;  P4=where(landcover.eq.15,P4@_FillValue,P4) 

  P1=where(P1.le.0,1.e-6,P1)
  P2=where(P2.le.0,1.e-6,P2)
  P3=where(P3.le.0,1.e-6,P3)
  P4=where(P4.le.0,1.e-6,P4)   

;  print(P1)
;  print(P2)
;  print(P3)
;  print(P4)

  ;;3.4. Ags, GPP, Gc
  Ags = Ca * P1 / (P2*kQ + P4*kQ) * (kQ*LAI + log((P2+P3+P4)/(P2 + P3*exp(kQ*LAI) + P4)))  ;;; umol m-2 s-1
  Ags=where(landcover.le.0.or.landcover.eq.15,1.e-6,Ags)
  Ags=where(ismissing(Tavg),Ags@_FillValue,Ags)  ;; make sure values on sea are _FillValue

  GPP = 1.0368 * Ags * fvpd   ;; umol m-2 s-1

  Gc  = m/Ca * Ags * 1.6 * fvpd_gc  ; 1.6 = conductance of water / conductance of CO2 (mol m-2 s-1)
  Gc = Gc *1.e-2 / (0.446 * (273/(273+Tavg)) * (p/101.3))  ;;// Convert from mol m-2 s-1 to cm s-1 to m s-1
  Gc = where(Gc.lt.1.e-6,1.e-6,Gc)
;  print(Ags)


;;;Step 4. calculate ET = Es + Eca + Ecr + Ei
  ;; 4.1. Ga 
  ;; Aerodynamic conductance (Leuning, 2008, Eq.13, doi:10.1029/2007WR006562)
  d = hc * 0.64
  zom = hc * 0.13
  zoh = zom * 0.1
  uz = log(67.8 * Zob - 5.42)/4.87 * u2
  Ga = uz * kmar * kmar / (log((Zob-d)/zom) * log((Zob-d)/zoh))

  ;; 4.2. ET_water for water&ice 
  ;; Heat from equilibrium evaporation (LEeq)
  Eeq = slop / (slop+gama) * Rn / lambda * 86.4   ;;; 86400*1.e-3 from W/m2 to mm d-1
  Eeq = where(Eeq.lt.0.0001,0.0001,Eeq)
  ;; Penman Monteith potential ET
  Evp = (gama/(slop+gama))*((6430 * (1 + 0.536*u2) * VPD)/lambda)
  Evp = where(Evp.lt.0.0001,0.0001,Evp)
  mask_water = where(landcover.eq.0.or.landcover.eq.15,1,0)
  ET_water = (Eeq + Evp) * mask_water
  
  ;; 4.3. Ecr, Eca, Ec
  ;; Transpiration from plant cause by radiation water transfer
  Tou = exp(-kA * LAI) ;
  Ecr = slop/gama * Rn * (1.- Tou) /(slop/gama + 1.+ Ga/Gc) / lambda * 86.4    ;; mm d-1
  Ecr = where(LAI.le.0.,0.,Ecr)
  ;; Transpiration from plant cause by aerodynamic water transfer
  Eca = (rou_a * Cp * Ga * VPD/gama) /(slop/gama+ 1.+ Ga/Gc) / lambda * 86.4  ;; mm d-1
  Eca = where(LAI.le.0.,0.,Eca) 
  ;; Transpiration from plant
  Ec = Ecr + Eca

  ;; 4.5. Ei, Pi
  fveg = 1. - exp(-LAI/LAIref)
  Sveg = S_sls * LAI
  fER = fER0 * fveg
;  print(fER)
  fveg = where(fveg.le.0,0.0001,fveg)
  fER = where(fER.le.0,0.0001,fER)
  prcp_wet = -log(1.- fER0) / fER / fveg

  ;;Intercepted Evaporation (Ei)
  Ei = where((prcp - prcp_wet).ge.0.,(fveg * prcp_wet + fER * (prcp - prcp_wet)),fveg * prcp)
  Pi = prcp - Ei
  Pi = where(Pi.lt.0.,0.,Pi)

  ;; 4.6. Es_eq,Es
  ;; Soil evaporation at equilibrium
  Es_eq = slop/gama * Rn * Tou / (slop/gama+1.) / lambda * 86.4    ;; mm d-1  
  Es_eq = where(Es_eq.le.0.,1.e-6,Es_eq)
  fval_soil = prcp/Es_eq
  fval_soil = where(fval_soil.gt.1.,1.,fval_soil)
  fval_soil = where(fval_soil.lt.0.,0.,fval_soil)
;  fval_soil = smth9_Wrap(fval_soil,0.5,-0.25,True)
  ;; Soil evaporation ; mm d-1
  Es = fval_soil * Es_eq

  ;; 4.7. ET
  ;; actual evopotranspiration (ET, mm d-1) by PML-V2
  ET = Es + Eca + Ecr + Ei 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  print(GPP)
;  print(ET)
   copy_VarCoords(landcover,GPP)
   copy_VarCoords(landcover,Ags)
   copy_VarCoords(landcover,fvpd)
   copy_VarCoords(landcover,Gc)
   copy_VarCoords(landcover,Ga)
   copy_VarCoords(landcover,P1)
   copy_VarCoords(landcover,P2)
   copy_VarCoords(landcover,P3)
   copy_VarCoords(landcover,P4)
   copy_VarCoords(landcover,ET)
   copy_VarCoords(landcover,Es)
   copy_VarCoords(landcover,Ec)
   copy_VarCoords(landcover,Eca)
   copy_VarCoords(landcover,Ecr)
   copy_VarCoords(landcover,Ei)
   copy_VarCoords(landcover,ET_water)
   copy_VarCoords(landcover,Es_eq)
   copy_VarCoords(landcover,fval_soil)
   copy_VarCoords(landcover,Pi)
   copy_VarCoords(landcover,LAI)
   copy_VarCoords(landcover,VPD)

   GPP@long_name="Gross Primary Productivity"
   GPP@units="umol m-2 s-1"
   Ags@long_name="Gross Assimilation Rate without VPD constraint"
   Ags@units="umol m-2 s-1"
   fvpd@long_name="Coefficient of VPD constraint"
   fvpd@units="-"
   Gc@long_name="Canopy stomatal conductance"
   Gc@units="m s-1"
   Ga@long_name="Aerodynamic conductance"
   Ga@units="m s-1"

   ET@long_name="Evapotranspiration"
   ET@units="mm d-1"
   Es@long_name="Soil evaporation"
   Es@units="mm d-1"
   Ec@long_name="Vegetation transpiration"
   Ec@units="mm d-1"
   Eca@long_name="Transpiration from plant cased by aerodynamic water transfer"
   Eca@units="mm d-1"
   Ecr@long_name="Transpiration from plant cased by radiation water transfer"
   Ecr@units="mm d-1"
   Ei@long_name="Interception from vegetation canopy"
   Ei@units="mm d-1"
   ET_water@long_name="Evaporation from water body,snow and ice"
   ET_water@units="mm d-1"
   Es_eq@long_name="Equilibrium evaporation"
   Es_eq@units="mm d-1"
   fval_soil@long_name="Fraction for soil evaporation"
   fval_soil@units="-" 
   Pi@long_name="Precipitation into soil--the difference of Prcp and Ei"
   Pi@units="mm d-1"
   LAI@long_name="Leaf area index"
   LAI@units="m-2 m-2" 
   VPD@long_name="Vapor pressure deficit"
   VPD@units="kPa"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Output in NetCDF format
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;===================================================================
   ; explicitly declare file definition mode. Improve efficiency.
   ;===================================================================
   setfileoption("nc","Format","NetCDF4Classic")

   system("rm -rf output_of_PMLV2.0_NCL_IGBP_GLDAS_AVHRR_15D.nc")
   fout=addfile("output_of_PMLV2.0_NCL_IGBP_GLDAS_AVHRR_15D.nc","c")

   ; create global attributes of the file
   ;===================================================================
   fAtt               = True            ; assign file attributes
   fAtt@title         = "Output of PML-V2 in NCL"
   fAtt@Climate_forcing  ="Near-surface forcing from GLDADS_NOAH025_15D forced by Priceton V2.2 climate forcing" 
   fAtt@LAI_forcing   = "AVHRR GIMMS3g V04"
   fAtt@Albedo_forcing   = "AVHRR GLASS V04"
   fAtt@Emissitivity_forcing   = "AVHRR GLASS V04"
   fAtt@Landcover_forcing = "IGBP MODIS 006"
   fAtt@Reference="Zhang, Y., Kong, D., Gan, R., Chiew, F.H.S., McVicar, T.R., Zhang, Q., and Yang, Y.. (2019) Coupled estimation of 500m and 8-day resolution global evapotranspiration and gross primary production in 2002-2017.Remote Sens. Environ. 222, 165-182, https://doi:10.1016/j.rse.2018.12.031"
   fAtt@Conventions   = "None"
   fAtt@creation_date = systemfunc ("date")
   fileattdef(fout, fAtt)      ; copy file attributes

   ; write variables of the file
   ;========
   fout->GPP=GPP
   fout->Ags=Ags
   fout->fvpd=fvpd
   fout->Gc=Gc
   fout->Ga=Ga
; fout->P1=P1
; fout->P2=P2
; fout->P3=P3
; fout->P4=P4
   fout->ET=ET
   fout->Es=Es
   fout->Ec=Ec
   fout->Eca=Eca
   fout->Ecr=Ecr
   fout->Ei=Ei
   fout->ET_water=ET_water
   fout->Es_eq=Es_eq
   fout->fval_soil= fval_soil
   fout->Pi=Pi
   fout->landcover=landcover
   fout->LAI=LAI
   fout->VPD=VPD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
