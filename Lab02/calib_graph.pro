;+
;NAME
;    VIEWSPECTRA
;
;DESCRIPTION
;    Restores a .sav file (designed for coldsky.sav and
;    standinfront.sav) containing data from the Horn,
;    turns the dual channel data into a complex signal,
;    takes the Fast Fourier Transform of each sample set,
;    and averages them using the MEAN function (which
;    has better success in most of our cases than does
;    MEDIAN). The resulting spectrum is plotted.
;
;INPUT
;    FILENAME:
;    The name, as a string, of the intended file to be
;    restored. The file must have its variable named
;    'data'.
;
;    N:
;    Number of desired samples per sample set. The FFT
;    works best with an N with a small sum of prime factors.
;
;    SAMP:
;    Number of desired sample sets over which to average.
;    More sets yields better accuracy but takes more time.
;
;    COLOR:
;    Desired graph color. Must be a plot-ready color code of
;    some kind. (E.g. '!green' or something)
;
;OUTPUT
;    Graphs the spectrum.
;
;CALLING SEQUENCE
;    viewspectra, filename, N, samp, color
;____________________________________________________________
;
;NAME
;    DOIT
;
;DESCRIPTION
;    Calls viewspectra on the calibration data (coldsky.sav and
;    standinfront.sav), graphs the two spectra, and saves the graph
;    and a .ps file.
;
;OUTPUT
;    Saves a .ps file called Standingvscold.ps.
;
;CALLING SEQUENCE
;    doit
;____________________________________________________________
;-

pro viewspectra, filename, N, samp, color

  restore, filename

;For coldsky and standinfront:  
;DATA INT = ARRAY[16000, 2, 1000]

  fsamp = (62.5/8)*10.^6
  ranges = (findgen(N)-N/2)
  frange = ranges*fsamp/N

  arr = data[0:N-1, *, 0:samp-1]
  
  comp_arr = complex(arr[*, 0, *], arr[*, 1, *])

  pss = []

  for i=0,samp-1 do begin
     ft = FFT(comp_arr[*, 0, i], /CENTER)
     pss = [[pss], [ft*conj(ft)]]
     print, strtrim(string(100.*float(i)/float(samp)))+' % Complete'
  endfor

  pss_tot = mean(pss, DIMENSION=2)

  oplot, frange/10.^6, pss_tot, COLOR=color

end


pro doit
  psopen, 'Standingvscold.ps', xsize=10, ysize=8, /inches, /color
  !p.multi=[0, 1, 1]
  plot, [-4, 4], [0, 0.3], /nodata, color=!black, background=!white, $
        title='Calibration Data from Horn (blue=cold, red=standing)', $
        xtitle='Freq (MHz)', ytitle='Power'
  viewspectra, 'coldsky.sav', 2048, 1000, !blue
  viewspectra, 'standinfront.sav', 2048, 1000, !red
  psclose
end
