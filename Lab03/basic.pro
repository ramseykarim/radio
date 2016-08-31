;+
;
;-

pro plotdata, file, xrng, yrng, smth=smth, deg=deg, verbose=verbose
  if keyword_set(verbose) then begin
     print, 'for both, xrange is good at 0.05'
     print, 'for sun, ~5.*10.^(-9)'
     print, 'for Orion, ~5.*10.^(-13)'
  endif
  restore, file
  data = str.volts
  times = str.lst
  for i=0,n_elements(times)-1 do begin
     if times[i] lt 12 then times[i] += 24
  endfor
  times -= times[0]

  ttl = 'Plotting '+file
  bg = !white
  clr = !black
;  !p.multi=[0,1,2]

  plot, times, data, title=ttl+' Signal', xtitle='Time (hrs)', $
        ytitle='Voltage (V)', symsize=0.5, $
        background=bg, color=clr

  timespan = (max(times) - min(times))*3600.
  ft = FFT(data, /center)
  ps = ft*conj(ft)
  N = n_elements(data)
  fsamp = 1./(timespan/float(N))
  frange = (findgen(N) - N/2)*fsamp/float(N)
  if keyword_set(smth) then ps = smooth(ps, deg)
  plot, frange, ps, xrange=[-xrng, xrng], yrange=[0, yrng], $
        title=ttl+' Spectrum', xtitle='Frequency (Hz)', $
        ytitle='Power', background=bg, color=clr

end

pro presets, arg
  if arg eq 1 then begin
     plotdata, 'SunData.sav', 0.05, (5.*10.^(-9))
  endif
  if arg eq 2 then begin
     plotdata, 'OrionData.sav', 0.05, (5.*10.^(-13)), /smth, deg=50
  endif
end

