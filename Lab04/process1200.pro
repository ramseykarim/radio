;+
;
;-

function gettsys, nd, hot, cold
  hott = total(hot)
  coldt = total(cold)
  tsys = nd*coldt/(hott - coldt)
  return, tsys
end

function getshape, on, off
  shape = on/off
  return, shape
end

function getcalspec, shape, t
  calspec = (shape - 1)*t
  return, calspec
end

pro remmax, arr
  maxcoord = where(arr eq max(arr))
  nextright = maxcoord + 1
  nextleft = maxcoord - 1
  nearavg = (arr[nextright] + arr[nextleft])/2.
  arr[maxcoord] = nearavg
end

pro process1200

  restore, 'offline1200.sav'
  coldfst = fst
  restore, 'calib1200.sav'
  hotfst = fst

  cold_xx_spct_avg = coldfst.spct_avg[*,0]
  cold_yy_spct_avg = coldfst.spct_avg[*,1]
  hot_xx_spct_avg = hotfst.spct_avg[*,0]
  hot_yy_spct_avg = hotfst.spct_avg[*,1]
  
  remmax, cold_xx_spct_avg
  remmax, cold_yy_spct_avg

  ;
;  !p.multi = [0,2,2]
;  plot, cold_xx_spct_avg, title='cold xx'
;  plot, hot_xx_spct_avg, title='hot xx'
;  plot, cold_yy_spct_avg, title='cold yy'
;  plot, hot_yy_spct_avg, title='hot yy'
;  stop
  
  nd_xx = 145
  nd_yy = 30

  tsys_xx = gettsys(nd_xx, hot_xx_spct_avg, cold_xx_spct_avg)
  tsys_yy = gettsys(nd_yy, cold_yy_spct_avg, hot_yy_spct_avg)
  
  ;
;  print, 'xx',tsys_xx
;  print, 'yy',tsys_yy
;  stop


  restore, 'data1200.sav'
  datafst = fst
  data_xx_spct_avg = datafst.spct_avg[*,0]
  data_yy_spct_avg = datafst.spct_avg[*,1]
  
  freq0 = datafst.freq_rf_chnl0
  freq8191 = datafst.freq_rf_chnl8191
  freqrange = freq8191 - freq0
  frange = (findgen(8192)/8192.)*freqrange + freq0
  frange_MHz = frange/(10.^6.)

  shape_xx = getshape(data_xx_spct_avg, cold_xx_spct_avg)
  shape_yy = getshape(data_yy_spct_avg, cold_yy_spct_avg)

  calspec_xx = getcalspec(shape_xx, tsys_xx)
  calspec_yy = getcalspec(shape_yy, tsys_yy)

  !p.multi = [0,1,1]
;  plot, calspec_xx
;  plot, calspec_yy
  
  calspec = (calspec_xx + calspec_yy)/2.

  plot, frange_MHz, calspec, title='avg', $
        xtitle='Frequency (MHz)', ytitle='Power (arbitrary)'
end
