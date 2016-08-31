;+
;NAME
;    HISTO
;
;DESCRIPTION
;    This is a tailored wrappper procedure for the HISTO_WRAP
;    procedure. It loads the best trial data and sorts it into
;    the maximum number of bins possible (32 -- likely corresponds
;    to the resolution of the sampling). Graphs the resulting
;    histogram of the signal data and the corresponding averaged
;    power spectrum.
;
;OUTPUT
;    Graphs the histogram and averaged power spectrum.
;
;CALLING SEQUENCE
;    histo
;__________________________________________________________________
;-

pro histo
; 6_2_take5.sav is the best data file we have for this exercise
  restore, '6_2_take5.sav', DESCRIPTION=desc
  
  print, desc

  dat = data.samples
  samp = data.nsp
  ps = make_array(n_elements(dat[*, 0, 0]), value=0)
  for i=0,samp-1 do begin
     ft = FFT(complex(dat[*, 0, i], dat[*, 1, i]), /center)
     ps = ps + ft*conj(ft)
  endfor
  avg_ps = ps/samp
  

  histo_wrap, dat, min(dat), max(dat), 32, edges, centers, hx
  
  trange = (findgen(16000)-8000)/data.fsamp_mhz
  frange = (findgen(16000)-8000)*data.fsamp_mhz/16000

  psopen, 'Histogram.ps', xsize=12, ysize=8, /color, /inches
  !p.multi = [0, 1, 2]
  plot, centers, hx, psym=10, color=!black, background=!white, $
        title='Histogram', xtitle='Amplitude', ytitle='Occurances (#)', $
        charsize=1.5
  plot, frange, avg_ps, psym=-4, color=!black, background=!white, $
        title='Spectrum', xtitle='Frequency (MHz)', $
        ytitle='Power', charsize=1.5
  psclose
end
