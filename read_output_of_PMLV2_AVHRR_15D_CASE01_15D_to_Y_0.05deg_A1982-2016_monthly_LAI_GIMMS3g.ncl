
begin

year=ispan(1982,2016,1)
month=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
nyear=dimsizes(year)

do iy=0,nyear-1
path="/mnt/g/xzhang/AVHRR_Forcing_0.05deg/LAI_GIMMS3g_0.05deg_15D/"+year(iy)+"/"
files=systemfunc("ls "+path+"GIMMS3g_V04_15D_A"+year(iy)+"*0.05deg.nc")
nfiles=dimsizes(files)
print(files)

f=addfiles(files,"r")
print(f)

;---Read "pottmp" in "join" mode and print a summary of the variable
ListSetType (f, "join") 

data_in=f[:]->LAI  ;; m2 m-2 
data=tofloat(data_in)
copy_VarCoords(data_in,data)
delete(data_in)
printVarSummary(data)
data!0="time"
data&time=fspan(1,12.5,24)

data=data * 0.001 
data@units="m2 m-2"

time=ispan(1,12,1)
time@units="month"
ndim=dimsizes(data)
data_out=new((/12,ndim(1),ndim(2)/),typeof(data))
data_out!0="time"
data_out&time=time
data_out!1="latitude"
data_out&latitude=data&latitude
data_out!2="longitude"
data_out&longitude=data&longitude

do im=0,11
id=im*2
data_out(im,:,:)=dim_avg_n(data(id:id+1,:,:),0)
end do

copy_VarAtts(data,data_out)

;===================================================================
; explicitly declare file definition mode. Improve efficiency.
;===================================================================
;setfileoption("nc","Format","NetCDF4Classic")

system("rm -rf LAI_of_AVHRR_GIMMS3g_15D_monthly_A"+year(iy)+"_0.05deg.nc")
fileout="LAI_of_AVHRR_GIMMS3g_15D_monthly_A"+year(iy)+"_0.05deg.nc"
fout=addfile(fileout,"c")

   ; create global attributes of the file
   ;===================================================================
   fAtt               = True            ; assign file attributes
   fAtt@title         = "AVHRR GIMMS3g V04"
   fAtt@Conventions   = "None"
   ;fAtt@creation_date = systemfunc ("date")
   fileattdef(fout, fAtt)      ; copy file attributes

fout->LAI=data_out

end do


end
