#!/bin/bash

ROOT=/mnt/f/PMLV2-AVHRR/
WORKDIR=$ROOT/RUN_PML2.0_NCL_GIMMS3g_LAI_15D_CASE01
DRIVER=$WORKDIR/PMLV2-AVHRR-GLDAS-GIMMS3g-LAI-15D-20200808.ncl
OUTDIR=$ROOT/OUTPUT_PMLV2.0_NCL/PML2.0_NCL_GIMMS3g_LAI_15D_CASE01
mkdir -p ${OUTDIR}

####################################################################
Startyr=1982
Endyr=2000

month=("01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12")
half=("a" "b")
#####################################################################
echo "copy Global CO2 files ...."
ln -sf $ROOT/Global_Monthly_CO2_Forcing .

echo "copy IGBP MODIS Land Cover files ...."
ln -sf $ROOT/IGBP_Forcing_0.05deg/IGBP_MODIS_0.05deg .

echo "copy GLDAS forcing files ...."
ln -sf $ROOT/GLDAS_Forcing_0.05deg/GLDAS_NOAH025_15D .

echo "copy AVHRR forcing files ...."
ln -sf $ROOT/AVHRR_Forcing_0.05deg/Albedo_GLASS_0.05deg_15D .
ln -sf $ROOT/AVHRR_Forcing_0.05deg/BBE_GLASS_0.05deg_15D .
ln -sf $ROOT/AVHRR_Forcing_0.05deg/LAI_GIMMS3g_0.05deg_15D .

cp -p IGBP_MODIS_0.05deg/IGBP_MODIS_MCD12C1_Majority_Land_Cover_Type_1_2001_0.05deg.nc IGBP_Land_Cover_0.05deg.nc
####################################################################
  yr=${Startyr}
  while [ ${yr} -le ${Endyr} ]
  do
    #cp -p IGBP_MODIS_0.05deg/IGBP_MODIS_MCD12C1_Majority_Land_Cover_Type_1_${yr}_0.05deg.nc IGBP_Land_Cover_0.05deg.nc
    mkdir -p ${OUTDIR}/${yr}
    i=0
    while [ $i -le 11 ]
    do
      j=0
      while [ $j -le 1 ]
      do 
      echo running on ${yr}${month[i]}${half[j]} ...
      ln -sf Global_Monthly_CO2_Forcing/${yr}/global_monthly_co2_${yr}${month[i]}.txt global_mean_CO2_in_ppm.txt
      ln -sf GLDAS_NOAH025_15D/${yr}/GLDAS_NOAH025_15D_A${yr}${month[i]}${half[j]}_0.05deg.nc GLDAS_Forcing_0.05deg.nc
      ln -sf GLDAS_NOAH025_15D/${yr}/GLDAS_NOAH025_15D_A${yr}${month[i]}${half[j]}_0.05deg.Tmax.nc GLDAS_Tmax_0.05deg.nc
      ln -sf GLDAS_NOAH025_15D/${yr}/GLDAS_NOAH025_15D_A${yr}${month[i]}${half[j]}_0.05deg.Tmin.nc GLDAS_Tmin_0.05deg.nc
      ln -sf Albedo_GLASS_0.05deg_15D/${yr}/GLASS02B05_V04_15D_A${yr}${month[i]}${half[j]}_0.05deg.nc GLASS_Albedo_0.05deg.nc
      ln -sf BBE_GLASS_0.05deg_15D/${yr}/GLASS03B01_V04_15D_A${yr}${month[i]}${half[j]}_0.05deg.nc GLASS_Emiss_0.05deg.nc
      ln -sf LAI_GIMMS3g_0.05deg_15D/${yr}/GIMMS3g_V04_15D_A${yr}${month[i]}${half[j]}_0.05deg.nc GIMMS3g_LAI_0.05deg.nc
      ncl $DRIVER 2>&1 >>log.${yr}.txt
      mv output_of_PMLV2.0_NCL_IGBP_GLDAS_AVHRR_15D.nc $OUTDIR/${yr}/output_of_PMLV2.0_IGBP_GLDAS_NOAH_AVHRR_GIMMS3g_15D_A${yr}${month[i]}${half[j]}_0.05deg.nc
      rm -f global_mean_CO2_in_ppm.txt
      rm -f GLDAS_Forcing_0.05deg.nc
      rm -f GLDAS_Tmax_0.05deg.nc
      rm -f GLDAS_Tmin_0.05deg.nc
      rm -f GLASS_Albedo_0.05deg.nc
      rm -f GLASS_Emiss_0.05deg.nc
      rm -f GIMMS3g_LAI_0.05deg.nc

      j=`expr $j + 1`
      done

    i=`expr $i + 1`
    done
  yr=`expr $yr + 1`
  done

#####################################################################
