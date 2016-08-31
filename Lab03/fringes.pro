;+
;
;-

function len, arr
  return, n_elements(arr)
end


function ff, ha, dec
  wl = 0.03;0.02968
  B = 15.
  fringes = (B/wl)*cos(dec*!dtor)*cos(ha*!dtor)
  return, fringes
end

pro ffss
  arr = make_array(181, 91, value=0)
  for i=0,180 do begin
     for j=0,90 do begin
        arr[i, j] = ff(i-90, j)
     endfor
  endfor
  print, n_elements(arr[*, 0])
  print, n_elements(arr[0, *])
;  window, 0
  plot, findgen(181)-90, findgen(90), /nodata, color=!white, $
        background=!black, xtitle='Hour Angle', ytitle='Declination', $
        title='Fringe Frequencies by HA and Dec'
  contour, arr, findgen(181)-90, findgen(91), /fill, nlevels=20, $
           /overplot
;  window, 1
;  plot, arr[*, 0], findgen(n_elements(arr[*, 0]))
;  window, 2
;  plot, findgen(n_elements(arr[0, *])), arr[90, *]
end


pro localfringe
  restore, 'sundatafinal.sav'
  lsts = str.lst
  for i=0,len(str)-1 do if lsts[i] gt 12 then lsts[i] -= 24
  ras = str.ra
  v = str.volts
  v -= mean(v)
  qew = 506.
  qns = 33.
  ha = lsts - ras
  harads = (ha)*!pi/12.
  cosha = cos(harads)
  sinha = sin(harads)
  frs = qew*cosha - qns*sinha
  !p.multi=[0,1,1]
  ps_ch, 'locfringe.ps', /defaults, /color, /inch, xsize=11, ysize=8
  plot, ha, frs*(2*!pi/(24.*3600.)), title='Local Fringe Frequency', $
        color=!black, background=!white, charsize=1.5, $
        xtitle='Hour Angle (hours)', ytitle='Frequency (Hz)'
  ps_ch, /close
end







pro ffs, dec, ttl
  ha = float(findgen(181)-90)
  decs = findgen(91)*!dtor
  freqs = (ff(float(dec), ha))*(2.*!pi/(3600.*24.))
  plot, ha*(24./360.), freqs, color=!black, $
        background=!white, title=ttl+' Prediction', $
        xtitle='Hour Angle (Hours)', ytitle='Frequency (Hz)'
end

;-----------------------------------------------------

function qew, bew, dec, wl
  coeff = float(bew)/float(wl)
  fn = cos(float(dec)*!dtor)
  ans = coeff*fn
  return, ans
end

function qns, bns, dec, wl, L
  coeff = float(bns)/float(wl)
  latfn = sin(float(L)*!dtor)
  fn = cos(float(dec)*!dtor)
  ans = coeff*fn*latfn
  return, ans
end

function framp, bew, bns, dec, wl, L, ha, A, B
  q1 = qew(bew, dec, wl)
  q2 = qns(bns, dec, wl, L)
  vtg = q1*sin(ha) + q2*cos(ha)
  inner = 2*!pi*vtg
  f_ha = A*cos(inner) + B*sin(inner)
  return, f_ha
end

pro dothething
  restore, 'sun_3_27_hh1_chart.sav'
  lsts = str.lst
  for i=0,n_elements(lsts)-1 do begin
     if lsts[i] lt 12 then lsts[i] += 24
  endfor
  ha = (lsts - str.ra) - 24
  v = str.volts
  v -= mean(v)
  v -= mean(v)
  !p.multi = [0,2,2]
  n = 1000
  aa = (findgen(n)-n/2.)/float(n)
  squares = []
  for i=0,n-1 do begin
     f = framp(17., 1, 0., 0.03, 22., (ha*360./24.)*!dtor, aa[i], 0)
     sqs = (f - v)^2.
     S = total(sqs)
     squares = [squares, S]
  endfor
;  print, n_elements(v)
;  plot, aa, squares, psym=-4
;  print, where(aa eq min(aa))
  ft1 = FFT(v, /center)
  ft2 = FFT(f, /center)
  ps1 = ft1*conj(ft1)
  ps2 = ft2*conj(ft2)
  ran = findgen(n_elements(ps1))-n_elements(ps1)/2
  cap = 6.*10.^(-13)
  cap2 = 1500
  print, where(ps2 gt 0.9*max(ps2))
;  for i=0,16353 do begin
;     ft1[i] = 0
;  endfor
;  for i=19149,n_elements(ft1)-1 do begin
;     ft1[i] = 0
;  endfor
;  print, len(ft1)
;  print, len(ft2)
;  vrev = FFT(ft1, /center, /inverse)
;  psvrev = vrev*conj(vrev)
  ps_ch, 'F_ha_example.ps', /defaults, /inch, xsize=13, ysize=8, /color
  plot, ha, v, title='Observed Sun Data', $
        background=!white, color=!black
  plot, ha, v, title='Observed Sun Data - Zoomed', $
        background=!white, color=!black, $
        xrange=[4.5, 5.5], yrange=[-0.01, 0.01]

;  plot, ran, real_part(ft1), title='O Data - PS', $
;        xrange = [-cap2, cap2];, yrange = [0, cap]
;  plot, ran, ps1, title='O Data - PS', $
;        xrange = [-cap2, cap2], yrange = [0, cap]
  plot, ha, f*0.0001, title='Predicted Sun Data', $
        yrange = [-0.0002, 0.0002], symsize=0.5, $
        color=!black, background=!white
  plot, ha, -f*0.0001, title='Predicted Sun Data - Zoomed', $
        yrange = [-0.0002, 0.0002], symsize=0.5, $
        color=!black, background=!white, $
        xrange=[4.5, 5.5]

  ps_ch, /close
;  plot, ran, ps2, title='Prediction - PS', $
;        xrange = [-cap2, cap2]
end
