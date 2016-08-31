;restore, FILENAME='3_5_Square.sav', DESCRIPTION=desc
;print, desc
;N = 256
;vsamp = 6240
;trange = (findgen(N) - (N/2))/(vsamp)


;frange = (findgen(N)-(N/2))*(vsamp/(N))
;frange_khz = frange/(1000.0)
;frange_mhz = frange/(1000000.0)

;dft, trange, current_dat, frange, current_dat_dft
;current_ps = current_dat_dft * conj(current_dat_dft)

;psopen, '3_6_Square_Spectra.ps', xsize=10, ysize=8, /inches, /color

;!p.multi = [0,1,3]
;plot, frange_khz, current_ps, title='Power Spectrum (Square Wave 62.4kHz)', $
;      xtitle='Frequency (kHz)', ytitle='Power', background=!white, $
;      color=!black, psym=-4, yrange=[0,400], charsize=2
;plot, frange_khz, real_part(current_dat_dft), title='Real Voltage Spectrum', $
;      xtitle='Frequency (kHz)', ytitle='Re(V)', background=!white, $
;      color=!black, psym=-4, charsize=2
;plot, frange_khz, imaginary(current_dat_dft), title='Imaginary Voltage Spectrum', $
;      xtitle='Frequency (kHz)', ytitle='Im(V)', background=!white, $
;      color=!black, psym=-4, charsize=2

;psclose

;
;  TIME FOR FILTERING YEEEEEAAAAAAAAAAHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
;--------------------------------------------------------------------

; -- dft power spec variable is 'current_ps', 256 elements

; frange ranges from -3072.00 to 3048.00
; first bunch of harmonics can be cut off on either side of ~ +/- 2000
;    elements 0:44, length-45:length-1
; second bunch, ~ +/- 1000
;    elements 0:86, length-87:length-1
; then +/- 500
;    elements 0:107, length-108:length-1
; then 200
;    elements 0:119, length-120:length-1

;plot, frange, current_ps, title='Power Spectrum (Square Wave 62.4kHz)', $
;      xtitle='Frequency (kHz)', ytitle='Power', background=!white, $
;      color=!black, psym=-4, yrange=[0,400], charsize=2


pro filter

  restore, FILENAME='3_5_Square.sav', DESCRIPTION=desc
  print, desc
  N = 256
  vsamp = 6240
  trange = (findgen(N) - (N/2))/(vsamp)
  

  frange = (findgen(N)-(N/2))*(vsamp/(N))
  frange_khz = frange/(1000.0)
  frange_mhz = frange/(1000000.0)

  dft, trange, current_dat, frange, current_dat_dft
  current_ps = current_dat_dft * conj(current_dat_dft)


  vs_filtered_1 = current_dat_dft
  vs_filtered_2 = current_dat_dft
  vs_filtered_3 = current_dat_dft
  vs_filtered_final = current_dat_dft
  
  len = N
  a = 44
  b = 86
  c = 107
  d = 122

  for i=0,a do begin
     vs_filtered_1[i] = 0
  endfor

  for i=(len - (a + 1)),(len - 1) do begin
     vs_filtered_1[i] = 0
  endfor

  for i=0,b do begin
     vs_filtered_2[i] = 0
  endfor

  for i=(len - (b + 1)),(len - 1) do begin
     vs_filtered_2[i] = 0
  endfor

  for i=0,c do begin
     vs_filtered_3[i] = 0
  endfor

  for i=(len - (c + 1)),(len - 1) do begin
     vs_filtered_3[i] = 0
  endfor

  for i=0,d do begin
     vs_filtered_final[i] = 0
  endfor

  for i=(len - (d + 1)),(len - 1) do begin
     vs_filtered_final[i] = 0
  endfor

  !p.multi = [0,1,5]
;  plot, frange, current_ps, title='Power Spectrum (Square Wave 62.4kHz)', $
;        xtitle='Frequency (kHz)', ytitle='Power', background=!white, $
;        color=!black, psym=-4, yrange=[0,400], charsize=2
;  plot, frange, vs_filtered_1, title='Power Spectrum (Square Wave 62.4kHz)', $
;        xtitle='Frequency (kHz)', ytitle='Power', background=!white, $
;        color=!black, psym=-4, yrange=[0,400], charsize=2
;  plot, frange, vs_filtered_2, title='Power Spectrum (Square Wave 62.4kHz)', $
;        xtitle='Frequency (kHz)', ytitle='Power', background=!white, $
;        color=!black, psym=-4, yrange=[0,400], charsize=2
;  plot, frange, vs_filtered_3, title='Power Spectrum (Square Wave 62.4kHz)', $
;        xtitle='Frequency (kHz)', ytitle='Power', background=!white, $
;        color=!black, psym=-4, yrange=[0,400], charsize=2
;  plot, frange, vs_filtered_final, title='Power Spectrum (Square Wave 62.4kHz)', $
;        xtitle='Frequency (kHz)', ytitle='Power', background=!white, $
;        color=!black, psym=-4, yrange=[0,400], charsize=2

  dft, frange, current_dat_dft, trange, original, /inverse
  dft, frange, vs_filtered_1, trange, filtered1, /inverse
  dft, frange, vs_filtered_2, trange, filtered2, /inverse
  dft, frange, vs_filtered_3, trange, filtered3, /inverse
  dft, frange, vs_filtered_final, trange, filtered_final, /inverse

  psopen, '3_6_Fourier_Filtered_Square2.ps', xsize=20, ysize=12, /inches, /color

  plot, trange, original, title='FT->IFT Square Wave', $
        xtitle='Time (s)', ytitle='Voltage', background=!white, $
        color=!black, psym=-4, charsize=2, symsize=0.8
  plot, trange, filtered1, title='Filtered Square Wave - Slightly', $
        xtitle='Time (s)', ytitle='Voltage', background=!white, $
        color=!black, psym=-4, charsize=2, symsize=0.8
  plot, trange, filtered2, title='Filtered Square Wave - A Little More', $
        xtitle='Time (s)', ytitle='Voltage', background=!white, $
        color=!black, psym=-4, charsize=2, symsize=0.8
  plot, trange, filtered3, title='Filtered Square Wave - A Bit More', $
        xtitle='Time (s)', ytitle='Voltage', background=!white, $
        color=!black, psym=-4, charsize=2, symsize=0.8
  plot, trange, filtered_final, title='Filtered Square Wave - Filtered So Much', $
        xtitle='Time (s)', ytitle='Voltage', background=!white, $
        color=!black, psym=-4, charsize=2, symsize=0.8

  psclose

end
