
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

Startyr=1982
Endyr=2016

year=ispan(Startyr,Endyr,1)
nyear=Endyr-Startyr+1

myStartyr=1982
myEndyr=2016
myyear=ispan(myStartyr,myEndyr,1)
mynyear=myEndyr-myStartyr+1

refStartyr=1982
refEndyr=1991

 model=(/"GLASS"/)
 nmodel=dimsizes(model)

varname=(/"LAI"/)
varname_mean=(/"mean"/)
varname_refm=(/"refm"/)
varname_anom=(/"anom"/)
varname_stdv=(/"stdv"/)
varname_trnd=(/"trnd"/)
varname_prob=(/"prob"/)

nvar=dimsizes(varname)

 do ivar= 0,nvar-1
   print(varname(ivar))

 do imodel= 0, nmodel -1

   FilePath="./annual_LAI_0.05deg/"

   OutFileNameAnn="Climatological_statistics_of_annual_"+varname(ivar)+"_of_AVHRR_"+model(imodel)+"_15D_annual_A"+myStartyr+"-"+myEndyr+"_0.05deg.nc"

   files=systemfunc("ls "+FilePath+varname(ivar)+"_of_AVHRR_"+model(imodel)+"_15D_annual_A*0.05deg.nc")
   nfiles=dimsizes(files)
   print(files)

   f=addfiles(files,"r")
   print(f)
   ;---Read "pottmp" in "join" mode and print a summary of the variable
   ListSetType (f, "join")
   data_cf_ann=f[:]->$varname(ivar)$
   data_cf_ann!0="time"
   data_cf_ann&time=year
   data_cf_ann@long_name = varname(ivar)
   data_cf_ann@missing_value=data_cf_ann@_FillValue

   latitude=data_cf_ann&latitude
   longitude=data_cf_ann&longitude
   nlat=dimsizes(latitude)
   nlon=dimsizes(longitude)

   data_cf_ann_ref=new((/nlat,nlon/),typeof(data_cf_ann))
   data_cf_ann_ref!0="latitude"
   data_cf_ann_ref!1="longitude"
   data_cf_ann_ref&latitude=latitude
   data_cf_ann_ref&longitude=longitude
   data_cf_ann_ref@units=data_cf_ann@units
   data_cf_ann_ref@_FillValue=data_cf_ann@_FillValue
   data_cf_ann_ref@missing_value=data_cf_ann@missing_value
   data_cf_ann_ref@long_name="reference 30-year mean value of "+data_cf_ann@long_name
   data_cf_ann_ref@desciption="data averaged over "+refStartyr+"-"+refEndyr

   data_cf_ann_avg=new((/nlat,nlon/),typeof(data_cf_ann))
   data_cf_ann_avg!0="latitude"
   data_cf_ann_avg!1="longitude"
   data_cf_ann_avg&latitude=latitude
   data_cf_ann_avg&longitude=longitude
   data_cf_ann_avg@units=data_cf_ann@units
   data_cf_ann_avg@_FillValue=data_cf_ann@_FillValue
   data_cf_ann_avg@missing_value=data_cf_ann@missing_value
   data_cf_ann_avg@long_name="Mean of "+data_cf_ann@long_name
   data_cf_ann_avg@desciption="data averaged over "+myStartyr+"-"+myEndyr

   data_cf_ann_std=new((/nlat,nlon/),typeof(data_cf_ann))
   data_cf_ann_std!0="latitude"
   data_cf_ann_std!1="longitude"
   data_cf_ann_std&latitude=latitude
   data_cf_ann_std&longitude=longitude
   data_cf_ann_std@units=data_cf_ann@units
   data_cf_ann_std@_FillValue=data_cf_ann@_FillValue
   data_cf_ann_std@missing_value=data_cf_ann@missing_value
   data_cf_ann_std@long_name="Stddev of "+data_cf_ann@long_name

   data_cf_ann_trd=new((/nlat,nlon/),typeof(data_cf_ann))
   data_cf_ann_trd!0="latitude"
   data_cf_ann_trd!1="longitude"
   data_cf_ann_trd&latitude=latitude
   data_cf_ann_trd&longitude=longitude
   data_cf_ann_trd@units=data_cf_ann@units+"/year"
   data_cf_ann_trd@_FillValue=data_cf_ann@_FillValue
   data_cf_ann_trd@missing_value=data_cf_ann@missing_value
   data_cf_ann_trd@long_name="Trend of "+data_cf_ann@long_name
   data_cf_ann_trd@desciption="regression coefficient from ncl regCeof_n over "+myStartyr+"-"+myEndyr

   data_cf_ann_prb=new((/nlat,nlon/),typeof(data_cf_ann))
   data_cf_ann_prb!0="latitude"
   data_cf_ann_prb!1="longitude"
   data_cf_ann_prb&latitude=latitude
   data_cf_ann_prb&longitude=longitude
   data_cf_ann_prb@units="-"
   data_cf_ann_prb@_FillValue=data_cf_ann@_FillValue
   data_cf_ann_prb@missing_value=data_cf_ann@missing_value
   data_cf_ann_prb@long_name="probability in trend of "+data_cf_ann@long_name
   data_cf_ann_prb@desciption="probability from ncl regCeof_n over "+myStartyr+"-"+myEndyr

   data_cf_ann_ano=new((/mynyear,nlat,nlon/),typeof(data_cf_ann))
   data_cf_ann_ano!0="year"
   data_cf_ann_ano!1="latitude"
   data_cf_ann_ano!2="longitude"
   data_cf_ann_ano&year=myyear
   data_cf_ann_ano&latitude=latitude
   data_cf_ann_ano&longitude=longitude
   data_cf_ann_ano@units=data_cf_ann@units
   data_cf_ann_ano@_FillValue=data_cf_ann@_FillValue
   data_cf_ann_ano@missing_value=data_cf_ann@missing_value
   data_cf_ann_ano@long_name=data_cf_ann@long_name

   data_cf_ann_avg=dim_avg_n(data_cf_ann({myStartyr:myEndyr},:,:),0)
   data_cf_ann_ref=dim_avg_n(data_cf_ann({refStartyr:refEndyr},:,:),0)
   data_cf_ann_ano=data_cf_ann({myStartyr:myEndyr},:,:) - conform_dims(dimsizes(data_cf_ann_ano),data_cf_ann_ref,(/1,2/))
   data_cf_ann_std=dim_stddev_n(data_cf_ann_ano,0)

   ;;;;;Calculate trend in data
   rc=regCoef_n(myyear,data_cf_ann_ano,0,0)
   tval = onedtond(rc@tval , dimsizes(rc))
   df   = onedtond(rc@nptxy, dimsizes(rc)) - 2
   b = tval    ; b must be same size as tval (and df)
   b = 0.5
   prob = betainc(df/(df+tval^2),df/2.0,b)       ; prob(nlat,nlon)

   rc@_FillValue=1e+30
   rc@missing_value=1e+30
   prob@_FillValue=1e+30
   prob@missing_value=1e+30

   rc@_FillValue=data_cf_ann@_FillValue
   rc@missing_value=data_cf_ann@missing_value
   prob@_FillValue=data_cf_ann@_FillValue
   prob@missing_value=data_cf_ann@missing_value

   data_cf_ann_avg=where(data_cf_ann_avg.eq.0,data_cf_ann_avg@_FillValue,data_cf_ann_avg)
   data_cf_ann_ref=where(data_cf_ann_ref.eq.0,data_cf_ann_ref@_FillValue,data_cf_ann_ref)
   data_cf_ann_std=where(data_cf_ann_std.eq.0,data_cf_ann_std@_FillValue,data_cf_ann_std)
   data_cf_ann_trd=where(data_cf_ann_trd.eq.0,data_cf_ann_trd@_FillValue,data_cf_ann_trd)
   data_cf_ann_prb=where(data_cf_ann_prb.eq.0,data_cf_ann_prb@_FillValue,data_cf_ann_prb)

   data_cf_ann_trd=(/rc/)
   data_cf_ann_prb=(/prob/)
   delete(rc)
   delete(tval)
   delete(df)
   delete(b)
   delete(prob)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;===================================================================
  ; explicitly declare file definition mode. Improve efficiency.
  ;===================================================================
   setfileoption("nc","Format","NetCDF4Classic")

   system("rm -f "+OutFileNameAnn)
   fout=addfile(OutFileNameAnn,"c")

   ;create global attributes of the file
   ;===================================================================
   fAtt               = True            ; assign file attributes
   fAtt@title         = "AVHRR "+model(imodel)
   fAtt@Conventions   = "None"
   fAtt@creation_date = systemfunc ("date")
   fileattdef(fout, fAtt)      ; copy file attributes

   fout->$varname_mean(ivar)$=data_cf_ann_avg
   fout->$varname_refm(ivar)$=data_cf_ann_ref
   fout->$varname_anom(ivar)$=data_cf_ann_ano
   fout->$varname_stdv(ivar)$=data_cf_ann_std
   fout->$varname_trnd(ivar)$=data_cf_ann_trd
   fout->$varname_prob(ivar)$=data_cf_ann_prb

   delete(f)
   delete(latitude)
   delete(longitude)
   delete(data_cf_ann)
   delete(data_cf_ann_avg)
   delete(data_cf_ann_ref)
   delete(data_cf_ann_ano)
   delete(data_cf_ann_std)
   delete(data_cf_ann_trd)
   delete(data_cf_ann_prb)

 end do
 end do

end
