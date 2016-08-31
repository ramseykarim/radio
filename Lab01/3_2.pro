;Batch file for 3.2


;Sampling at 6.25 MHz.
;Taking 9 data sets at signal frequencies = (0.1, 0.2, 0.3, ..., 0.9) * sample rate


pro threepointtwo

freq = 625000.0
div = 10
N = 16
volt = '1V'
i = 0


for i=1,9 do begin
   current_f = i * freq
   srs1_frq, current_f
   print, 'Frequency changed to ',strtrim(string(current_f), 1)
   wait, 3
   data = getsample(div, N, volt)
   print, 'Data taken'
   freq_string = strtrim(string(i), 1)
   psopen, '3_2Plot'+freq_string+'.ps', xsize=20, ysize=16, /inches, /color
   !p.multi = [0,1,2]
   plotsignal, data, div, current_f
   plotspectrum, data, div, current_f
   psclose
endfor

end
