;+
;_____________________________________________________________________________
;NAME:     PLOTSIGNAL
;
;DESCRIPTION:
;          This procedure plots signal versus time. It is designed for
;          use with the GETSAMPLE procedure.
;
;CALLING SEQUENCE: 
;          plotsignal, data, div, frequency(, name, /MYTITLE, /NOLINE)
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
;
;
;Example:
;
;IDL> my_data = getsample(10, 1024)
;IDL> plotsignal, my_data, 10, 1000000, 'My Graph', /MYTITLE, /NOLINE, xrange=[0,5]
;
;
;_____________________________________________________________________________
;-

pro plotsignal, data, div, frequency, $
                name, MYTITLE=custom, NOLINE=no_line, $
                xrange=xrange, yrange=yrange
  time_axis = data[*, 1]
  signal = data[*, 0]
  vsamp = (62.5/div) * (10.^6)
  time_mcs = time_axis*(10.^6)
  freq_str = strtrim(string(frequency), 1)+' Hz'
  vsamp_str = strtrim(string(vsamp), 1)+' Hz'
  if (keyword_set(custom) AND (n_elements(name) NE 0)) then begin
     title = name
  endif else title = 'Signal Data: Frequency = '+freq_str+' // Sample Frequency = '+vsamp_str
  if keyword_set(no_line) then sym = 4 else sym = -4
  if keyword_set(xrange) then pxrange = xrange else pxrange = !null
  if keyword_set(yrange) then pyrange = yrange else pyrange = !null
  plot, time_mcs, signal, psym=sym, background=!white, $
        color=!black, title=title, xtitle='Time (microseconds)', $
        ytitle='Voltage (V)', charsize=1.5, $
        xrange = pxrange, yrange = pyrange
end
