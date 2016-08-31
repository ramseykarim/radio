;+
;
;-

pro viewspectra_online

  restore, 'ondata.sav'
  print, 'Data restored: ondata.sav'
  samp = 1000
  N = 8192
  data = ondata[0:samp-1, 0:N-1]

  
  vsamp = (6.25/8.)*10.^6

  div = 8
  fsamp = (62.5/div)*10.^6
  ranges = (findgen(N) - N/2)
  trange = ranges/fsamp
  frange = ranges*fsamp/N
  
  ps_sets= []

  for i=0,samp-1 do begin
     print, strtrim(string(100.*float(i)/float(samp)), 1)+' % Complete'
     ft = FFT(data[i, *], /center)
     ps_sets = [ps_sets, ft*conj(ft)]
  endfor

  help, ps_sets
  
  
  ps_tot1 = mean(ps_sets, DIMENSION=1)
  ps_tot = transpose(ps_tot1)
  

  plot, frange, ps_tot, psym=-4, title='ONLINE', xtitle='Freq (Hz)', $
        ytitle='Power', yrange=[0, 0.05]

end

pro viewspectra_offline

  restore, 'offdata.sav'
  print, 'Data Restored: offdata.sav'
  samp = 1000
  N = 8192
  data = offdata[0:samp-1, 0:N-1]

  
  vsamp = (6.25/8.)*10.^6

  div = 8
  fsamp = (62.5/div)*10.^6
  ranges = (findgen(N) - N/2)
  trange = ranges/fsamp
  frange = ranges*fsamp/N
  
  ps_sets= []

  for i=0,samp-1 do begin
     print, strtrim(string(100*float(i)/float(samp)), 1)+' % Complete'
     ft = FFT(data[i, *], /center)
     ps_sets = [ps_sets, ft*conj(ft)]
  endfor

  help, ps_sets
  
  
  ps_tot1 = mean(ps_sets, DIMENSION=1)
  ps_tot = transpose(ps_tot1)
  

  plot, frange, ps_tot, psym=-4, title='OFFLINE', xtitle='Freq (Hz)', $
        ytitle='Power', yrange=[0, 0.05]

end


pro doit
  !p.multi = [0, 1, 2]
  psopen, 'on_off.ps', xsize=10, ysize=8, /inches, /color
  viewspectra_online
  viewspectra_offline
  psclose
end
