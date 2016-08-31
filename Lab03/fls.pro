;+
;NAME
;     FLS
;
;DESCRIPTION
;     FLS: Fringe Least Squares. Given the output of
;     STARTCHART1 during an interferometry tracking of some
;     object, unpacks the data and fits either the baseline or
;     the declination to the data using a combination of trigonometry
;     and a least squares fit.
;
;CALLING SEQUENCE
;
;-

pro fls, n, nl, m, ml, bew, bns
  restore, 'OrionData.sav'
  length = n_elements(str)
  v = str.volts
  v -= mean(v)
  lsts = str.lst
  for i=0,n_elements(lsts)-1 do if lsts[i] gt 12 then lsts[i] -= 24
  latitude = 37.8732
  wavelength = 0.02968

  ; For Orion
  ra = ten(5, 35, 17.3)*15.
  o_dec = ten(5, 23, 28)*(-1)
  precess, ra, o_dec, 2000, 2016
  ra /= 15.
  ; For the Sun
;  ra = str.ra
;  ft = FFT(v, /center)
;  ps = conj(ft)*ft
;  ha = (lsts - ra);*(!pi/12.)
;  timespan = (ha[-1] - ha[0])*3600.
;  fsamp = length/timespan
;  frange = (findgen(length)-float(length)/2.)*fsamp/length
;  ps_ch, 'Sunndataplots.ps', /color, /defaults, xsize=11, ysize=8, /inch
;  !p.multi=[0,1,2]
;  plot, ha, v, title='Raw Sun Signal', color=!black, background=!white, $
;        xtitle='Hour Angle (hours)', ytitle='Voltage (V)', $
;        charsize=1.3
;  yr = 3*10.^(-9.)
;  print, length
;  arnd = 16400
;  insd = 150
;  halfway = round(length/2.)
;  ftfiltered = ft
;  for i=0,arnd-1 do ftfiltered[i]=0
;  for i=length-arnd,length-1 do ftfiltered[i]=0
;  for i=halfway-insd,halfway+insd do ftfiltered[i]=0
;  psfiltered = conj(ftfiltered)*ftfiltered
;  smth = 15
;  vfilt = FFT(smooth(ftfiltered, smth), /center, /inverse)
;  plot, ha, vfilt, title='Filtered Orion Signal', color=!black, background=!white, $
;        xtitle='Hour Angle (hours)', ytitle='Voltage (V)', $
;        charsize=1.3
;  plot, frange, smooth(ps, 25), $
;        title='Raw Sun Data Power Spectrum', color=!black, background=!white, $
;        xtitle='Frequency (Hz)', ytitle='Power (arbitrary units)', $
;        charsize=1.3, yrange=[0, yr], xrange=[-0.1,0.1]
;  plot, frange, smooth(psfiltered, smth), $
;        title='Filtered Orion Data Power Spectrum', color=!black, background=!white, $
;        xtitle='Frequency (Hz)', ytitle='Power (arbitrary units)', $
;        charsize=1.3, yrange=[0, yr], xrange=[-0.1,0.1]
;  ps_ch, /close
;  stop


  startqew = n[0]
  endqew = n[1]
  lqew = endqew - startqew
  startqns = m[0]
  endqns = m[1]
  lqns = endqns - startqns
  qew = float(findgen(nl+1)*float(lqew)/float(nl) + startqew)
  qns = float(findgen(ml+1)*float(lqns)/float(ml) + startqns)

  initstruc = {squares, rss:0., alpha:[[0.,0.],[0.,0.]]}
  bfls = replicate(initstruc, nl+1, ml+1)

  sinha = sin(ha)
  cosha = cos(ha)
  y = transpose(v)
  twopi = 2*!pi
  for i=0,nl do begin
     stri = strtrim(string(100*i/float(nl)), 1)
     for j=0,ml do begin
        vtg = float(qew[i])*sinha + float(qns[j])*cosha
        twopivtg = twopi*vtg
        xa = cos(twopivtg)
        xb = sin(twopivtg)
        x = [transpose(xa), transpose(xb)]
        xt = [[xa], [xb]]
        alpha = xt ## x
        beta = xt ## y
        coeffs = invert(alpha) ## beta
        yp = x ## coeffs
        resvec = y - yp
        sumres = transpose(resvec) ## resvec
        bfls[i, j].rss = sumres
        bfls[i, j].alpha = alpha
     endfor
        print, 'Step ', stri
  endfor
  minpoint = array_indices(bfls.rss, where(bfls.rss eq min(bfls.rss)))
  ewcoord = minpoint[0]
  nscoord = minpoint[1]
  ew = qew[ewcoord]
  ns = qns[nscoord]
  strew = strtrim(string(ew), 1)
  strns = strtrim(string(ns), 1)
  print, 'Q EW: ', strew
  print, 'Q NS: ', strns
  bew = ew*wavelength/cos(o_dec*!dtor)
  bns = ns*wavelength/(cos(o_dec*!dtor)*sin(latitude*!dtor))
  print, 'EW Baseline: ',strtrim(string(bew), 1)
  print, 'NS Baseline: ',strtrim(string(bns), 1)

  bestalpha = bfls[ewcoord, nscoord].alpha
  bestrss = min(bfls.rss)
  covmat = invert(bestalpha)
  covmat *= (1./(length - 2.))*bestrss
  print, 'Qew error: ',sqrt(covmat[0,0])
  print, 'Qew error: ',sqrt(covmat[1,1])
  savestuff = {rssarr:bfls, alpha:bestalpha, modcov:covmat, qew:qew, qns:qns}
  save, savestuff, filename='leaststuff.sav', $
        description='SAVESTUFF: rssarr, alpha, modcov, qew, qns'



  loadct, 3
;  ps_ch, 'LLSPlotZoom.ps', /color, /defaults, xsize=10, ysize=8, /inch
  contour, bfls.rss, qew, qns, /fill, nlevels=60, $
           title='BRUTE FORCE LEAST SQUARES', $
           xtitle='Q EW', ytitle='Q NS', charsize=2
  legend, [textoidl('Q_{EW} = '+strew), textoidl('Q_{NS} = '+strns)], $
          position=[.7,.9], textcolors=[0, 0], outline_color=0, $
          charsize=2, /normal
;  ps_ch, /close


end

pro doit
  ew = 0
  ns = 0
  fls, [504,510], 300, [28,36], 400, ew, ns
end

pro graphit
  restore, 'leaststuff.sav'
  !p.multi=[0,1,1]
  bfls = savestuff.rssarr
  a = savestuff.alpha
  qew = savestuff.qew
  qns = savestuff.qns
;  c = savestuff.modcov
;  csq= sqrt(c)
;  dec = -1*ten(5, 22, 54)*!dtor
;  cosdec=cos(dec)
;  wavelength = 0.02968
;  slat = sin(!dtor*37.8732)
  minpoint = array_indices(bfls.rss, where(bfls.rss eq min(bfls.rss)))
  ewcoord = minpoint[0]
  nscoord = minpoint[1]
  ew = qew[ewcoord]
  ns = qns[nscoord]
  strew = strtrim(string(ew), 1)
  strns = strtrim(string(ns), 1)
;  ewerr = csq[0,0]
;  nserr = csq[1,1]
;  bew = ew*wavelength/cosdec
;  bns = ns*wavelength/(cosdec*slat)
;  print, bew
;  print, bns
;  bewerr = ewerr*wavelength/cosdec
;  bnserr = nserr*wavelength/(cosdec*slat)
;  print, 'QEW: ', sqrt(ewerr)
;  print, 'QNS: ', sqrt(nserr)
;  print, 'BEW: ',sqrt(bewerr)
;  print, 'BNS: ',sqrt(bnserr)
  

;  ps_ch, 'TESTLLS1.ps', /color, /defaults, xsize=11, ysize=11, /inch
  psopen, 'TESTLLS1.ps', xsize=12, ysize=12, /color, /inch
  loadct, 3

  contour, bfls.rss, qew, qns, /fill, nlevels=60, $
           title='BRUTE FORCE LEAST SQUARES', $
           xtitle='Q EW', ytitle='Q NS', charsize=1.5, $
           position=[0.07, 0.07, 0.85, 0.91]
  colorbar, /vertical, xrange = [0,1], position=[0.9, 0.21, 0.93, 0.81], $
            title=textoidl('\Sigma s^{2} (\cdot 10^{-5})'), $
            crange=(10.^5.)*[min(bfls.rss), max(bfls.rss)], $
            charsize=1.3, /overplot
  legend, [textoidl('Q_{EW} = '+strew), textoidl('Q_{NS} = '+strns)], $
          position=[.5,.89], textcolors=[0, 0], outline_color=0, $
          charsize=2, /normal
  psclose
;  ps_ch, /close
end


;===============================================
;===============================================


pro sunrad
  restore, 'sundatafinal.sav'
  str = str[860:*]
  l = n_elements(str)
  v = str.volts
  v -= mean(v)
  lsts = str.lst
  ras = str.ra
  dec = str.dec
  latitude = 37.8732
  wavelength = 0.02968
  cosdec = cos(dec*!dtor)
  qew = (15.1/wavelength)*cosdec
  qns = (1.5/wavelength)*cosdec*sin(latitude*!dtor)
  
  ft = FFT(v, /center)
  ps = ft*conj(ft)
;  !p.multi = [0,1,1]
  for i=0,n_elements(lsts)-1 do if lsts[i] gt 12 then lsts[i] -= 24
  ha = lsts - ras
  harad = ha*(!pi/12.)
  fsamp = l/((ha[-1]-ha[0])*3600.)
  frange = (findgen(l)-float(l)/2)*fsamp/l
  print, fsamp

  ; Recreate best fit of Fr(ha)
  y = transpose(v)
  sinha = sin(harad)
  cosha = cos(harad)
  vtg = qew*sinha + qns*cosha
  twopi = 2*!pi
  twopivtg = twopi*vtg
  xa = cos(twopivtg)
  xb = sin(twopivtg)
  x = [transpose(xa), transpose(xb)]
  xt = [[xa], [xb]]
  coeffs = invert(xt ## x) ## xt ## y
  fitcol = x ## coeffs
  fitted = transpose(fitcol)
  fitft = FFT(fitted, /center)
  fitps = fitft*conj(fitft)

  ; Create local fringe frequency array
  locfs = make_array(l, value=0)
  for i=0,l-1 do begin
     locf = qew[i]*cosha[i] - qns[i]*sinha[i]
     locfs[i] = locf
  endfor
  locfs_hz = locfs*twopi/(24.*3600.)

  ; Fit modulated theoretical Sun data
  ; to observed data and match zeros
  r = (findgen(6)/float(5))*0.005 + 0.002
  n = 1000
  ps_ch, 'Mods.ps', /defaults, /color, /inches, xsize=9, ysize=12
  !p.multi=[0,2,3]
  for i=0,5 do begin
  curr = r[i];0.005
  integral = make_array(l, value=0)
  for j=-n,n do begin
     firstterm = (1 - (float(j)/n)^2.)^.5
     insidesecond = twopi*(float(j)/n)*curr*locfs
     secondterm = cos(insidesecond)
     integral += (firstterm*secondterm)
  endfor
  integral *= curr/float(n)
  strr = strtrim(string(curr), 1)
  plot, ha, integral, title='Modulation Function, R='+strr, charsize=1.8, $
        xtitle='Hour Angle (hours)', ytitle='Modulation Multiplier (arbitrary units)', $
        background=!white, color=!black
endfor
  ps_ch, /close
  stop

  modulated = integral*fitted*2.1*10.^4.
;  ps_ch, 'modsun1.ps', /defaults, /color, xsize=11, ysize=8, /inch
  plot, ha, v, /nodata, color=!black, background=!white, charsize=1.5, $
        title='Modulated Sun Data: Theory versus Observation (R = .005 rad)', $
        xrange=[-6,6], yrange=[-0.02, 0.02], xtitle='Hour Angle (hours)', $
        ytitle='Voltage (V, arbitrarily shifted)'
  oplot, ha, v+0.0025, color=!magenta
  oplot, ha+0.1, (-1*modulated)-0.0025, color=!forest
  oplot, [-4.4, -4.4], [-0.005, 0.005], color=!black, psym=-1
  oplot, [-3.5, -3.5], [-0.005, 0.005], color=!black, psym=-1
  oplot, [-2.4, -2.4], [-0.005, 0.005], color=!black, psym=-1
  oplot, [2.05, 2.05], [-0.005, 0.005], color=!black, psym=-1
  oplot, [3.1, 3.1], [-0.005, 0.005], color=!black, psym=-1
  oplot, [4.1, 4.1], [-0.005, 0.005], color=!black, psym=-1
  items = ['Observed Sun Data', 'Best Theoretical Prediction', 'Zeros']
  colors = [!magenta, !forest, !black]
  justblack = [!black, !black, !black]
  legend, items, outline_color=!black, textcolors=justblack, $
          colors=colors, position=[-5.5, 0.018], $
          charsize=2, linestyle=[0, 0, 0]
;  ps_ch, /close
end
