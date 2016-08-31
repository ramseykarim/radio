;+
;NAME: PRINTDATETIME
;
;Prints the full date and time given the output of CALDAT.
;-


pro printdatetime, jdate
  caldat, jdate, m, d, y, hr, min, sec
  hr = hr - 8
  if hr lt 0 then d = d - 1
  if hr lt 1 then hr = 24 + hr
  if hr gt 13 then begin
     hr = hr - 12
     half = 'PM'
  endif else begin
     half = 'AM'
  endelse
  leading_zero_sec = ''
  if sec lt 10 then leading_zero_sec = '0'
  leading_zero_min = ''
  if min lt 10 then leading_zero_min = '0'
  m = strtrim(string(m), 2)
  d = strtrim(string(d), 2)
  y = strtrim(string(y), 2)
  hr = strtrim(string(hr), 2)
  min = strtrim(string(min), 2)
  sec = strtrim(string(round(sec)), 2)
  print, 'DATE TAKEN: ',m,'/',d,'/',y
  print, 'TIME TAKEN: ', hr, ':', leading_zero_min, min, ':', $
         leading_zero_sec,sec, ' ', half, ' Pacific Time'
end
