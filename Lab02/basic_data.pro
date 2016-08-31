;+
;NAME
;     TAKENEWDATA
;
;DESCRIPTION
;     Takes 50 sets of data from the Horn at 6.25 MHz and stores it and other
;     relevant information (including date and time) in a data
;     structure. All measurement variables are predetermined.
;
;OUTPUT
;     Saves the data structure in a .sav file.
;
;CALLING SEQUENCE
;     takenewdata
;__________________________________________________________________
;
;NAME
;     USEOLDDATA
;
;DESCRIPTION
;     Using a .sav file created in TAKENEWDATA, plots the
;     power spectrum of the data. The procedure averages the sets of 
;     data through two different methods: a true average across the
;     points in the spectra and the median of each point in the
;     spectra sets. Both spectra are plotted for comparison.
;
;OUTPUT
;     Graphs the mean spectra and the median spectra.
;
;CALLING SEQUENCE
;     useolddata
;__________________________________________________________________
;
;NAME
;     BOTH
;
;DESCRIPTION
;     Wrapper procedure that runs both procedures.
;
;CALLING SEQUENCE
;     both
;__________________________________________________________________
;-


pro takenewdata

  div = 10
  nsp = 50

  getpico, '2V', div, nsp, tseries, $
           /dual, fsmpl=fsamp_mhz, vmult=vmult


lst_now = LSTNOW()
julian_now = SYSTIME(/julian, /utc)

data = {samples:tseries, fsamp_mhz:fsamp_mhz, vmult:vmult, $
        nsp:nsp, lst:lst_now, julian:julian_now}

save, data, filename='6_2.sav', $ 
      DESCRIPTION='VARIABLES: DATA. METHODS: samples, fsamp_mhz, vmult, nsp, lst, julian'
end





pro useolddata

  restore, '6_2_take5.sav', DESCRIPTION=desc
  print, '------------------'
  print, 'DESCRIPTION OF 6_2.sav:    ', desc
  print, '------------------'

  N = 1024
  
  nsamples = data.vmult*data.samples[0:N-1, *, *]

  fsamp = data.fsamp_mhz * 10.^6
  ps = []

  for i=0,data.nsp-1 do begin
     real_pt = nsamples[*, 0, i]
     imaginary_pt = nsamples[*, 1, i]
     comp_sig = complex(real_pt, imaginary_pt)
     ft = FFT(comp_sig, /center)
     ps = [[ps], [ft*conj(ft)]]
  end
  
  ps1 = mean(ps, dimension=2)
  ps2 = median(ps, dimension=2)

  n_centered = findgen(N)-(N/2)
  trange = (n_centered)/fsamp
  frange = (n_centered)*(fsamp/N)

  !p.multi = [0,1,2]
  plot, frange/10.^6, ps1, psym=-4, title='Spectrum: Mean', charsize=2, $
        xtitle='Freq (MHz)', ytitle='Power', color=!orange, background=!gray

  plot, frange/10.^6, ps2, psym=-4, title='spectrum: Median', charsize=2, $
        xtitle='Freq (MHz)', ytitle='Power', color=!orange, background=!gray


  print, 'LST:    ', data.lst
  print, 'JULIAN: ', data.julian


  printdatetime, data.julian
end

pro both
  takenewdata
  useolddata
end
