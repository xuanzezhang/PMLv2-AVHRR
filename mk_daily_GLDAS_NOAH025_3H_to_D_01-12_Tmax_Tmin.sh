
inpath="GLDAS_NOAH025_3H.2.0"
outpath="GLDAS_NOAH025_D.2.0"

Startyr=1982
Endyr=2014

nday=366

yr=${Startyr}

while [ $yr -le ${Endyr} ]
do
  mkdir -p $outpath/$yr/01
  mkdir -p $outpath/$yr/02
  mkdir -p $outpath/$yr/03
  mkdir -p $outpath/$yr/04
  mkdir -p $outpath/$yr/05
  mkdir -p $outpath/$yr/06
  mkdir -p $outpath/$yr/07
  mkdir -p $outpath/$yr/08
  mkdir -p $outpath/$yr/09
  mkdir -p $outpath/$yr/10
  mkdir -p $outpath/$yr/11
  mkdir -p $outpath/$yr/12


  iday=32
  while [ $iday -le 366 ]
  do
     num=1
     while [ $num -le 9 ]
     do
     ncra -y max -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}010$num.*.nc4  $outpath/$yr/01/GLDAS_NOAH025_D.A${yr}010$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}010$num.*.nc4  $outpath/$yr/01/GLDAS_NOAH025_D.A${yr}010$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}020$num.*.nc4  $outpath/$yr/02/GLDAS_NOAH025_D.A${yr}020$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}020$num.*.nc4  $outpath/$yr/02/GLDAS_NOAH025_D.A${yr}020$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}030$num.*.nc4  $outpath/$yr/03/GLDAS_NOAH025_D.A${yr}030$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}030$num.*.nc4  $outpath/$yr/03/GLDAS_NOAH025_D.A${yr}030$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}040$num.*.nc4  $outpath/$yr/04/GLDAS_NOAH025_D.A${yr}040$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}040$num.*.nc4  $outpath/$yr/04/GLDAS_NOAH025_D.A${yr}040$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}050$num.*.nc4  $outpath/$yr/05/GLDAS_NOAH025_D.A${yr}050$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}050$num.*.nc4  $outpath/$yr/05/GLDAS_NOAH025_D.A${yr}050$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}060$num.*.nc4  $outpath/$yr/06/GLDAS_NOAH025_D.A${yr}060$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}060$num.*.nc4  $outpath/$yr/06/GLDAS_NOAH025_D.A${yr}060$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}070$num.*.nc4  $outpath/$yr/07/GLDAS_NOAH025_D.A${yr}070$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}070$num.*.nc4  $outpath/$yr/07/GLDAS_NOAH025_D.A${yr}070$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}080$num.*.nc4  $outpath/$yr/08/GLDAS_NOAH025_D.A${yr}080$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}080$num.*.nc4  $outpath/$yr/08/GLDAS_NOAH025_D.A${yr}080$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}090$num.*.nc4  $outpath/$yr/09/GLDAS_NOAH025_D.A${yr}090$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}090$num.*.nc4  $outpath/$yr/09/GLDAS_NOAH025_D.A${yr}090$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}100$num.*.nc4  $outpath/$yr/10/GLDAS_NOAH025_D.A${yr}100$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}100$num.*.nc4  $outpath/$yr/10/GLDAS_NOAH025_D.A${yr}100$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}110$num.*.nc4  $outpath/$yr/11/GLDAS_NOAH025_D.A${yr}110$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}110$num.*.nc4  $outpath/$yr/11/GLDAS_NOAH025_D.A${yr}110$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}120$num.*.nc4  $outpath/$yr/12/GLDAS_NOAH025_D.A${yr}120$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}120$num.*.nc4  $outpath/$yr/12/GLDAS_NOAH025_D.A${yr}120$num.020.Tmin.nc4

     num=`expr $num + 1`
     done

     num=10
     while [ $num -le 31 ]
     do
     ncra -y max -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}01$num.*.nc4  $outpath/$yr/01/GLDAS_NOAH025_D.A${yr}01$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}01$num.*.nc4  $outpath/$yr/01/GLDAS_NOAH025_D.A${yr}01$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}02$num.*.nc4  $outpath/$yr/02/GLDAS_NOAH025_D.A${yr}02$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}02$num.*.nc4  $outpath/$yr/02/GLDAS_NOAH025_D.A${yr}02$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}03$num.*.nc4  $outpath/$yr/03/GLDAS_NOAH025_D.A${yr}03$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}03$num.*.nc4  $outpath/$yr/03/GLDAS_NOAH025_D.A${yr}03$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}04$num.*.nc4  $outpath/$yr/04/GLDAS_NOAH025_D.A${yr}04$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/0${iday}/GLDAS_NOAH025_3H.A${yr}04$num.*.nc4  $outpath/$yr/04/GLDAS_NOAH025_D.A${yr}04$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}04$num.*.nc4  $outpath/$yr/04/GLDAS_NOAH025_D.A${yr}04$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}04$num.*.nc4  $outpath/$yr/04/GLDAS_NOAH025_D.A${yr}04$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}05$num.*.nc4  $outpath/$yr/05/GLDAS_NOAH025_D.A${yr}05$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}05$num.*.nc4  $outpath/$yr/05/GLDAS_NOAH025_D.A${yr}05$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}06$num.*.nc4  $outpath/$yr/06/GLDAS_NOAH025_D.A${yr}06$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}06$num.*.nc4  $outpath/$yr/06/GLDAS_NOAH025_D.A${yr}06$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}07$num.*.nc4  $outpath/$yr/07/GLDAS_NOAH025_D.A${yr}07$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}07$num.*.nc4  $outpath/$yr/07/GLDAS_NOAH025_D.A${yr}07$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}08$num.*.nc4  $outpath/$yr/08/GLDAS_NOAH025_D.A${yr}08$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}08$num.*.nc4  $outpath/$yr/08/GLDAS_NOAH025_D.A${yr}08$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}09$num.*.nc4  $outpath/$yr/09/GLDAS_NOAH025_D.A${yr}09$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}09$num.*.nc4  $outpath/$yr/09/GLDAS_NOAH025_D.A${yr}09$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}10$num.*.nc4  $outpath/$yr/10/GLDAS_NOAH025_D.A${yr}10$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}10$num.*.nc4  $outpath/$yr/10/GLDAS_NOAH025_D.A${yr}10$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}11$num.*.nc4  $outpath/$yr/11/GLDAS_NOAH025_D.A${yr}11$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}11$num.*.nc4  $outpath/$yr/11/GLDAS_NOAH025_D.A${yr}11$num.020.Tmin.nc4
     ncra -y max -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}12$num.*.nc4  $outpath/$yr/12/GLDAS_NOAH025_D.A${yr}12$num.020.Tmax.nc4
     ncra -y min -v Tair_f_inst $inpath/$yr/${iday}/GLDAS_NOAH025_3H.A${yr}12$num.*.nc4  $outpath/$yr/12/GLDAS_NOAH025_D.A${yr}12$num.020.Tmin.nc4
     num=`expr $num + 1`
     done

  iday=`expr $iday + 1`
  done

  yr=`expr $yr + 1`
done
