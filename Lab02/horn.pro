;+
;Name:
;HORN
;
;Description:
;Takes data and saves it.
;
;Inputs:
;Name shoud be 'on' or 'off' but can include more
;Ra_Dec should be a two-element array of RA and Dec coordinates
;
;Calling Sequence:
;horn, name, ra_dec
;
;Example:
;IDL> horn, 'off', [1, 60]
;-

pro horn, name, ra_dec
  div = 8
  N = 100
  volt = '1V'
  dataaa = []
  for i=0,N-1 do begin
     getpico, volt, div, N, tseries, $
              /dual, fsmpl=fsamp, vmult=vmult
     dataaa = [[[dataaa]], [[tseries]]]
     print, strtrim(string(float(i)/N), 1)+' % COMPLETE'
  endfor
  jdate = systime(/julian, /utc)
  lstime = lstnow()
  dataaa = dataaa*vmult
  data = {spec:dataaa, jul:jdate, lst:lstime, div:div, fsamp:fsamp, $
         radec:ra_dec}
  desc = 'VARIABLE: data, METHODS: spec, jul, lst, div, fsamp, radec'
  print, 'JULIAN:  ',jdate
  caldat, jdate, m, d, yr, hr, min, sec
  printdatetime, m, d, yr, hr, min, sec
  fn = 'HornOn'+name+strtrim(string(jdate), 1)+'.sav'
  save, data, filename=fn, description=desc
  print, 'DATA SAVED/HACKED'
end
