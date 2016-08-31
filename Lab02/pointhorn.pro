;+
;NAME
;    ANALYZE
;
;DESCRIPTION
;    Built for the data structures used to record the data taken
;    from the Horn when it was pointed at (l, b) = (120, 0) rather
;    than the previous .sav file convention of 3D arrays.
;    The program averages the data via the MEAN method and does
;    all the calibration done in other procedures. It uses the single
;    value of T_sys,coldsky that was generated from 6000x8192 elements,
;    so the calibration is fairly accurate for the scope of the
;    project. The data is saved in a data structure containing the
;    data itself and the corresponding frequency array so that the
;    .sav file is optimized for plotting.
;
;INPUT
;    N:
;    The usual number of samples per sample set.
;
;    SAMP:
;    The usual number of sample sets over which to average.
;
;OUTPUT
;     Saves the calibrated spectrum as part of a data structure in a
;     .sav file.
;
;CALLING SEQUENCE
;     analyze, N, SAMP
;____________________________________________________________________
;NAME
;     SHOW
;
;DESCRIPTION
;     Uses the saved data from ANALYZE and plots some useful diagrams.
;     Most importantly, uses outputs from the UGDOPPLER program to
;     graph the spectrum against a 21cm line redshift axis so that the
;     velocities of the various sources of the line become evident.
;
;INPUT
;     NAME:
;     The name of the file to graph, in string form. Expects the
;     output of ANALYZE, as it is a data structure with certain
;     methods.
;
;OUTPUT
;     Graphs the calibrated line against both barycentric and LSR
;     velocities.
;
;CALLING SEQUENCE
;     show, name
;____________________________________________________________________
;-

pro analyze, N, samp
  div = 8
  restore, 'HornOFF2457444.5.sav'
  data_struc_off = data
  offdat = data_struc_off.spec[0:N-1, *, 0:samp-1]
  ps_off = []
  print, 'OFFLINE RESTORED'

  for i=0,samp-1 do begin
     ftf = FFT(complex(offdat[*, 0, i], offdat[*, 1, i]), /center)
     ps_off = [[ps_off], [(ftf * conj(ftf))]]
     if i mod 20 eq 0 then print, 100*float(i)/float(samp)
  endfor

  restore, 'HornON2457444.5.sav'
  data_struc_on = data
  ondat = data_struc_on.spec[0:N-1, *, 0:samp-1]
  ps_on = []
  print, 'ONLINE RESTORED'

  for i=0,samp-1 do begin
     ftn = FFT(complex(ondat[*, 0, i], ondat[*, 1, i]), /center)
     ps_on = [[ps_on], [(ftn * conj(ftn))]]
     if i mod 20 eq 0 then print, 100*float(i)/float(samp)
  endfor

  fsamp = 62.5/div
  frange = (findgen(N) - N/2)*(fsamp/N)

  ps_on = mean(ps_on, dimension=2)
  ps_off = mean(ps_off, dimension=2)
  shape = ps_on/ps_off

  restore, 'tsysN4096SAMP6000.sav'
  cal_shape = (shape - 1)*tsys
  plot, frange, cal_shape, title='Pointing the Horn', $
        xtitle='Freq (MHz)', ytitle='Intensity (K)'

  data = {spec:cal_shape, range:frange}
  save, data, filename='BestDataMEAN.sav', description='VAR: data'

end

pro show, name
  restore, name
  spectrum = data.spec
  frange = data.range + 1420.0
  fo = 1420.4
  df = frange - fo
  c = 3 * 10.^5
  vrange = -(df/fo)*c
  !p.multi = [0, 1, 2]
;  pk = where(spectrum eq max(spectrum))
;;;;;EXTRA PLOTS; NOT NECESSARY BUT HELPFUL MAYBE
;  plot, frange, spectrum, title='Pointing the Horn', $
;        xtitle='Freq (MHz)', ytitle='Intensity (K)', $
;        background = !cyan, color=!black, charsize=2
;  plot, vrange, spectrum, title='WRT Us', $
;        xtitle=textoidl('Velocity (km/s)'), $
;        ytitle=textoidl('Intensity (K)'), yrange=[0, 150], $
;        background = !cyan, color=!black, charsize=2;, xrange=[-10.^5, 10.^5]
;  oplot, [0, 0], [0, 150], color=!red

; THESE ARE FROM *UGDOPPLER*
  baryvel = 23.7270
  lsrvel = 20.9041
  vr_b = vrange-baryvel
  w = 100.
  bg = !white
  clr = !black
  mrkr = !red
  plot, vr_b, spectrum, title='WRT Barycentric Velocity', $
        xtitle=textoidl('Velocity (km/s)'), $
        ytitle=textoidl('Intensity (K)'), yrange=[0, 2*w], $
        background = bg, color=clr, charsize=2, xrange=[-2*w, 2*w]
; Optional overplot markers at x=0:
;  oplot, [0, 0], [0, 150], color=mrkr
  vr_l = vrange-lsrvel
  plot, vr_l, spectrum, title='WRT Local Standard of Rest', $
        xtitle=textoidl('Velocity (km/s)'), $
        ytitle=textoidl('Intensity (K)'), yrange=[0, 2*w], $
        background = bg, color=clr, charsize=2, xrange=[-2*w, 2*w]
;  oplot, [0, 0], [0, 150], color=mrkr
end
