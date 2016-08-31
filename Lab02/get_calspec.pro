;+
;NAME
;    GET_CALSPEC
;
;DESCRIPTION
;    Calls GET_SHAPE and GET_TSYS and comes up with a calibrated
;    spectrum that is saved in a .sav file. The calibrated spectrum
;    is in units of Kelvin.
;    GET_CALSPEC is essentially a wrapper procedure that calls the
;    two previously mentioned procedures on the same set of data and
;    then accesses their resulting .sav files in order to multiply
;    the line shape |T_line| by the calibration temperature
;    T_sys,coldsky.
;
;INPUT
;    N:
;    Number of desired samples per sample set. GET_SHAPE and GET_TSYS
;    will work most quickly with an N with a small sum of prime factors.
;
;    SAMP:
;    Number of desired sample sets to average over. More sets will
;    yield better accuracy but will take longer.
;
;OUTPUT
;    Graphs and saves the calibrated spectrum.
;
;CALLING SEQUENCE
;    get_calspec, N, samp
;_______________________________________________________________________
;-

pro get_calspec, N, samp

  strn = strtrim(string(N), 1)
  strsamp = strtrim(string(samp), 1)

  !p.multi = [0, 1, 2]

  get_shape, N, samp

  print, '-----------------------------------------'
  print, '---------- GET_SHAPE COMPLETE -----------'
  print, '-----------------------------------------'

  get_tsys, N, samp

  print, '-----------------------------------------'
  print, '---------- GET_TSYS COMPLETE ------------'
  print, '-----------------------------------------'

  restore, 'tsysN'+strn+'SAMP'+strsamp+'.sav', $
           description=desct
  print, 'T_SYS restored'
  print, desct
  restore, 'shapeN'+strn+'SAMP'+strsamp+'.sav', $
           description=descsh
  print, 'SHAPE restored'
  print, descsh

; Variables are tsys and shape

  calibrated_spec = (shape - 1)*tsys

  save, calibrated_spec, filename='CALIB_SPEC_N'+strn+'SAMP'+strsamp+'.sav', $
        description='VARIABLE: calibrated_spec, N = '+strn+', SAMP = '+strsamp+', div=8'

  frange_mhz = (findgen(N) - N/2)*(62.5/8)/N

  plot, frange_mhz, calibrated_spec, title='Calibrated Spectrum', $
        xtitle='Frequency (MHz)', ytitle='Signal Intensity (K)', $
        background=!white, color=!black, psym=-4, charsize=2



end

