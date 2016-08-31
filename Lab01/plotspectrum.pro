;+
;_____________________________________________________________________________
;NAME:     PLOTSPECTRUM
;
;DESCRIPTION:
;          This procedure plots the power spectrum, and optionally,
;          the voltage spectra, of a signal versus time. It is 
;          designed for use with the GETSAMPLE procedure.
;
;CALLING SEQUENCE: 
;          plotspectrum, data, div, frequency(, name, /MYTITLE,
;          /NOLINE, /VOLTAGE)
;
;INPUTS:
;          DATA expects the 2D 4xN array output of GETSAMPLE.
;
;          DIV expects the DIV argument passed to GETSAMPLE.
;
;          FREQUENCY expects the signal frequency. This is purely for
;          recordkeeping purposes. FREQUENCY can be any data type, but
;          is most useful as an integer or string.
;
;OPTIONAL INPUTS:
;          NAME should be a string containing the inteded title of the
;          plot. NAME is only used if the MYTITLE keyword is invoked.
;
;          XRANGE corresponds to XRANGE in the PLOT procedure.
;
;          YRANGE corresponds to YRANGE in the PLOT procedure.
;
;KEYWORDS:
;          MYTITLE should be used if the plot's title should be NAME
;          rather than a title containing the frequency and sample
;          rate. If MYTITLE is used, FREQUENCY can be assigned to
;          junk text; it no longer matters.
;
;          NOLINE will remove the lines from the plots and use point
;          markers only.
;
;          VOLTAGE will also plot the real and imaginary voltage
;          spectra.
;          Note: If VOLTAGE is used, !P.MULTI must be adjusted
;          ***outside*** of this procedure to accomodate two extra
;          plots! This procedure does *not* adjust !P.MULTI.
;
;
;Example:
;
;IDL> my_data = getsample(10, 1024)
;IDL> plotspectrum, my_data, 10, 1000000, 'My Graph', /MYTITLE,
;     /NOLINE, /VOLTAGE, yrange=[-50, 50]
;
;
;_____________________________________________________________________________
;-

pro plotspectrum, data, div, frequency, $
                  name, MYTITLE = custom, NOLINE = no_line, VOLTAGE = vs, $
                  xrange=xrange, yrange=yrange
  frequency_axis = data[*, 3]
  spectrum = data[*, 2]
  power = spectrum * conj(spectrum)
  real_vs = real_part(spectrum)
  im_vs = imaginary(spectrum)
  vsamp = (62.5/div) * (10.^6)
  frequency_megahz = frequency_axis/(10.^6)
  freq_str = strtrim(string(frequency), 1)+' Hz'
  vsamp_str = strtrim(string(vsamp), 1)+' Hz'
  if (keyword_set(custom) AND (n_elements(name) NE 0)) then begin
     title = name
  endif else title = 'Power Spectrum: Frequency = '+freq_str+' // Sample Frequency = '+vsamp_str
  if keyword_set(no_line) then sym = 4 else sym = -4
  if keyword_set(xrange) then pxrange = xrange else pxrange = !null
  if keyword_set(yrange) then pyrange = yrange else pyrange = !null
  plot, frequency_megahz, power, psym=sym, background=!white, $
        color=!black, title=title, xtitle='Frequency (MHz)', $
        ytitle='Power', charsize=1.5, xrange=pxrange, yrange=pyrange
  if keyword_set(vs) then begin
     plot, frequency_megahz, real_vs, psym=sym, background=!white, $
           color=!black, title='Real Voltage Spectrum', xtitle='Frequency (MHz)', $
           ytitle='Voltage', charsize=1.5, xrange=pxrange, yrange=pyrange
     plot, frequency_megahz, im_vs, psym=sym, background=!white, $
           color=!black, title='Imaginary Voltage Spectrum', xtitle='Frequency (MHz)', $
           ytitle='Voltage', charsize=1.5, xrange=pxrange, yrange=pyrange
  endif
end
